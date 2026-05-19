import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/disease_catalog.dart';
import '../models/ml_config.dart';
import '../services/analytics_service.dart';
import '../services/database_service.dart';
import '../services/image_picker_service.dart';
import '../services/ml_service.dart';
import '../services/scan_image_storage.dart';
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
  bool _isLoadingImage = false;

  final _imagePickerService = ImagePickerService();
  final _databaseService = DatabaseService();
  final _analytics = AnalyticsService();
  final _mlService = MLService();

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _analytics.logScanStarted().catchError((_) {});
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

  Future<void> _pickImage(ImageSource source) async {
    if (_isAnalyzing || _isLoadingImage) return;

    setState(() {
      _isLoadingImage = true;
      _selectedImage = null;
      _imageSource = null;
    });

    try {
      final File? file = source == ImageSource.camera
          ? await _imagePickerService.pickFromCamera()
          : await _imagePickerService.pickFromGallery();

      if (!mounted) return;

      if (file == null) {
        setState(() => _isLoadingImage = false);
        return;
      }

      // Show path immediately so the preview area updates without waiting on I/O.
      setState(() {
        _selectedImage = file;
        _imageSource = source;
      });

      await Future<void>.delayed(Duration.zero);

      final exists = await file.exists();
      if (!mounted) return;

      setState(() => _isLoadingImage = false);

      if (!exists) {
        setState(() {
          _selectedImage = null;
          _imageSource = null;
        });
        _showMessage('Image file could not be read. Please try again.',
            isError: true);
        return;
      }

      debugPrint('[Scan] image ready for preview: ${file.path}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
          _selectedImage = null;
          _imageSource = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Check permissions.',
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _isAnalyzing) return;

    if (!_mlService.isModelLoaded) {
      _showMessage(
        'ML model is not available. Please restart the app.',
        isError: true,
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final MLResult? result = await _mlService.classify(_selectedImage!);

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      if (result == null) {
        _showAnalysisFailureDialog();
        return;
      }

      if (result.isBackground) {
        _analytics.logNoLeafDetected().catchError((_) {});
        _showNoLeafDialog();
        return;
      }

      final persistedPath =
          await ScanImageStorage.persistScanImage(_selectedImage!) ??
              _selectedImage!.path;
      final source =
          _imageSource == ImageSource.camera ? 'camera' : 'gallery';

      if (!mounted) return;

      if (result.isLowConfidence) {
        _analytics
            .logLowConfidenceScan(
              diseaseName: result.disease.name,
              crop: cropNameForMlIndex(result.classIndex),
              confidence: result.confidence,
            )
            .catchError((_) {});
        _showMessage(result.confidenceLevel.scanMessage, isWarning: true);
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            disease: result.disease,
            confidence: result.confidence,
            historyLocalPath: persistedPath,
            cropName: cropNameForMlIndex(result.classIndex),
            mlClassIndex: result.classIndex,
            alternativePredictions: result.shouldShowAlternatives
                ? result.alternativePredictions
                : const [],
            showLowConfidenceNotice: result.isLowConfidence,
          ),
        ),
      );

      _analytics
          .logDiseaseDetected(
            diseaseName: result.disease.name,
            crop: cropNameForMlIndex(result.classIndex),
            confidence: result.confidence,
          )
          .catchError((_) {});

      _databaseService
          .saveScan(
            mlResult: result,
            scanSource: source,
            localImagePath: persistedPath,
          )
          .catchError((_) {});
    } catch (_) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _showAnalysisFailureDialog();
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red[700]
            : isWarning
                ? Colors.orange[800]
                : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showNoLeafDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.nature_people_outlined, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Expanded(child: Text('No Valid Leaf Detected')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The model could not find a clear plant leaf in this image.',
            ),
            const SizedBox(height: 12),
            ...MlConfig.retakePhotoTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF2E7D32))),
                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  void _showAnalysisFailureDialog() {
    _showMessage(
      'Analysis failed. Please try again with a clearer, well-lit leaf photo.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isAnalyzing || _isLoadingImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Leaf'),
        leading: const BackButton(),
      ),
      body: AbsorbPointer(
        absorbing: isBusy,
        child: SingleChildScrollView(
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
              if (_selectedImage != null && !_isLoadingImage) ...[
                const SizedBox(height: 20),
                _buildAnalyzeButton(),
              ],
              const SizedBox(height: 28),
              _buildHowItWorksSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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
      child: const Row(
        children: [
          Icon(Icons.camera_alt, color: Colors.white, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture or Upload a Leaf',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Use one clear leaf photo for the most reliable AI result.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            if (_selectedImage == null && !_isLoadingImage)
              _buildPlaceholder()
            else if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
            if (_isLoadingImage) _buildImageLoadingOverlay(),
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
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
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
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildImageLoadingOverlay() {
    return Container(
      color: const Color(0xFFE8F5E9).withValues(alpha: 0.92),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Loading image…',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Preparing image for analysis',
            style: TextStyle(fontSize: 12, color: Color(0xFF558B2F)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing leaf image…',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Running on-device AI model',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

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

  bool get isBusy => _isAnalyzing || _isLoadingImage;

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Opacity(
        opacity: isBusy ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.08),
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
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
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
      ),
    );
  }

  Widget _buildChangePhotoLink() {
    return Center(
      child: GestureDetector(
        onTap: isBusy
            ? null
            : () => setState(() {
                  _selectedImage = null;
                  _imageSource = null;
                }),
        child: Text(
          'Remove photo',
          style: TextStyle(
            fontSize: 13,
            color: isBusy ? Colors.grey : Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ScaleTransition(
      scale: _isAnalyzing ? const AlwaysStoppedAnimation(1.0) : _pulseAnimation,
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _isAnalyzing ? null : _analyzeImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            disabledBackgroundColor: const Color(0xFF81C784),
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
            _isAnalyzing ? 'Analyzing…' : 'Analyze Leaf',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
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
                'Tips for Best Results',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...MlConfig.retakePhotoTips.take(3).map(
                (tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
