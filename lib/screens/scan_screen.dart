import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_picker_service.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import '../services/ml_service.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  ImageSource? _imageSource;
  bool _isAnalyzing = false;

  final _imagePickerService = ImagePickerService();
  final _databaseService = DatabaseService();
  final _analytics = AnalyticsService();
  final _mlService = MLService(); // singleton — model already loaded by main()

  // Pulse animation for the analyze button
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Pick image from camera or gallery
  // ----------------------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    if (_isAnalyzing) return;

    try {
      final File? file = source == ImageSource.camera
          ? await _imagePickerService.pickFromCamera()
          : await _imagePickerService.pickFromGallery();

      if (file != null && mounted) {
        setState(() {
          _selectedImage = file;
          _imageSource = source;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Check permissions.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ----------------------------------------------------------------
  // Analyze the selected image using TFLite ML model
  // ----------------------------------------------------------------
  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _isAnalyzing) return;

    // Guard: model failed to load at startup
    if (!_mlService.isModelLoaded) {
      _showError('ML model is not available. Please restart the app.');
      return;
    }

    setState(() => _isAnalyzing = true);

    final MLResult? result = await _mlService.classify(_selectedImage!);

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    // ── Error: inference returned null (decode failure, etc.)
    if (result == null) {
      _showError('Analysis failed. Please try again with a clearer photo.');
      return;
    }

    // ── Edge case: model sees no plant leaf
    if (result.isBackground) {
      _showError(
        'No plant leaf detected. Please take a closer, clearer photo of a leaf.',
      );
      return;
    }

    // ── Low confidence warning (still navigate, but user is informed)
    if (result.isLowConfidence && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Low confidence (${result.confidencePercent}). '
            'Result may be inaccurate — try a clearer photo.',
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Capture values before navigating
    final localPath = _selectedImage!.path;
    final source = _imageSource == ImageSource.camera ? 'camera' : 'gallery';

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          disease: result.disease,
          confidence: result.confidence,
          historyLocalPath: localPath,
        ),
      ),
    );

    _analytics
        .logScanPerformed(result.disease.name, result.disease.severity)
        .catchError((_) {});

    // Save to Realtime Database in background (non-blocking)
    _databaseService.saveScan(
      mlResult: result,
      scanSource: source,
      localImagePath: localPath,
    ).catchError((_) {});
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ----------------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Leaf 📸'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInstructionBanner(),
            const SizedBox(height: 24),
            _buildImagePreviewArea(),
            const SizedBox(height: 20),
            _buildPickerButtons(),
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              _buildChangePhotoLink(),
            ],
            if (_selectedImage != null) ...[
              const SizedBox(height: 20),
              _buildAnalyzeButton(),
            ],
            const SizedBox(height: 28),
            _buildHowItWorksSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Instruction banner
  // ----------------------------------------------------------------
  Widget _buildInstructionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Capture or Upload a Leaf',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take a clear photo of the leaf and tap Analyze.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Image preview area (placeholder or real image with analyze overlay)
  // ----------------------------------------------------------------
  Widget _buildImagePreviewArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedImage != null
                ? const Color(0xFF2E7D32)
                : const Color(0xFFA5D6A7),
            width: _selectedImage != null ? 2 : 1.5,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or placeholder
            if (_selectedImage == null)
              _buildPlaceholder()
            else
              Image.file(_selectedImage!, fit: BoxFit.cover),

            // Analyzing overlay
            if (_isAnalyzing) _buildAnalyzingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_outlined,
            size: 52,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'No image selected',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Use the buttons below to capture\nor pick a leaf photo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Analyzing Leaf...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Processing image',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Camera / Gallery buttons
  // ----------------------------------------------------------------
  Widget _buildPickerButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSourceButton(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSourceButton(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isAnalyzing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Change photo text link
  // ----------------------------------------------------------------
  Widget _buildChangePhotoLink() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedImage = null;
          _imageSource = null;
        }),
        child: const Text(
          '✕  Remove photo',
          style: TextStyle(
            fontSize: 13,
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Analyze button (visible only after image is selected)
  // ----------------------------------------------------------------
  Widget _buildAnalyzeButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _isAnalyzing ? null : _analyzeImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: _isAnalyzing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.biotech, size: 22),
          label: Text(
            _isAnalyzing ? 'Analyzing...' : 'Analyze Leaf',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // How it works
  // ----------------------------------------------------------------
  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 8),
              Text(
                'How Detection Works',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Take or upload a clear leaf photo'),
          _buildStep('2', 'Tap "Analyze Leaf" to begin'),
          _buildStep('3', 'System processes the image'),
          _buildStep('4', 'Disease identified — solutions displayed'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
