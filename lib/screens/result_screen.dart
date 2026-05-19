import 'dart:io';
import 'package:flutter/material.dart';
import '../models/disease.dart';
import '../models/ml_config.dart';
import '../models/ml_result.dart';
import '../services/scan_image_storage.dart';
import '../utils/ml_confidence.dart';

/// Displays ML scan results or reference details for a disease class.
class ResultScreen extends StatelessWidget {
  final Disease disease;
  final double? confidence;
  final String? historyLocalPath;
  final String? cropName;
  final int? mlClassIndex;
  final bool isReferenceView;
  final List<PredictionCandidate> alternativePredictions;
  final bool showLowConfidenceNotice;

  const ResultScreen({
    super.key,
    required this.disease,
    this.confidence,
    this.historyLocalPath,
    this.cropName,
    this.mlClassIndex,
    this.isReferenceView = false,
    this.alternativePredictions = const [],
    this.showLowConfidenceNotice = false,
  });

  bool get _isScanResult => confidence != null && !isReferenceView;

  Color _hexToColor(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'High':
        return const Color(0xFFC62828);
      case 'Medium':
        return const Color(0xFFE65100);
      case 'Low':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'High':
        return Icons.warning_rounded;
      case 'Medium':
        return Icons.info_rounded;
      case 'None':
        return Icons.check_circle;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _confidenceColor(double value) {
    switch (MlConfidence.levelFor(value)) {
      case ConfidenceLevel.high:
        return const Color(0xFF2E7D32);
      case ConfidenceLevel.medium:
        return const Color(0xFFF9A825);
      case ConfidenceLevel.low:
        return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final diseaseColor = _hexToColor(disease.color);
    final severityColor = _severityColor(disease.severity);
    final level =
        confidence != null ? MlConfidence.levelFor(confidence!) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(_isScanResult ? 'Detection Result' : 'Disease Details'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultHero(diseaseColor, severityColor),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showLowConfidenceNotice && _isScanResult) ...[
                    _buildNoticeBanner(
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFE65100),
                      title: 'Low confidence detection',
                      message:
                          'Please use a clearer leaf image. Results may be inaccurate.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (historyLocalPath != null &&
                      ScanImageStorage.isImageAvailable(historyLocalPath)) ...[
                    _buildImagePreview(historyLocalPath!),
                    const SizedBox(height: 16),
                  ],
                  _buildSummaryCard(diseaseColor, severityColor, level),
                  if (alternativePredictions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAlternativesCard(diseaseColor),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.description_outlined,
                    title: 'About This Condition',
                    content: disease.description,
                    color: diseaseColor,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.healing_outlined,
                    title: 'Recommended Solutions',
                    content: disease.solution,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 16),
                  _buildDisclaimer(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(_isScanResult ? 'Back to Scan' : 'Back'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home, color: Color(0xFF2E7D32)),
                      label: const Text(
                        'Go to Home',
                        style: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeBanner({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 200,
        child: Image.file(File(path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildResultHero(Color diseaseColor, Color severityColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [diseaseColor, diseaseColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(disease.iconEmoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 16),
          Text(
            _isScanResult ? 'Detected Disease' : 'Reference',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            disease.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          if (cropName != null) ...[
            const SizedBox(height: 8),
            Text(
              cropName!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_severityIcon(disease.severity),
                    color: severityColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  disease.isHealthy
                      ? 'Plant appears healthy'
                      : 'Severity: ${disease.severity}',
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    Color diseaseColor,
    Color severityColor,
    ConfidenceLevel? level,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isScanResult && confidence != null && level != null) ...[
            _buildSummaryRow(
              icon: Icons.biotech,
              label: 'Detected Disease',
              value: disease.name,
              valueColor: diseaseColor,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              icon: Icons.speed,
              label: 'Confidence Level',
              value:
                  '${MlConfidence.percentLabel(confidence!)} · ${level.label}',
              valueColor: _confidenceColor(confidence!),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confidence!.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: const Color(0xFFE8F5E9),
                color: _confidenceColor(confidence!),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              level.scanMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ] else if (mlClassIndex != null) ...[
            _buildSummaryRow(
              icon: Icons.tag,
              label: 'ML Class Index',
              value: '#$mlClassIndex',
              valueColor: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],
          _buildSummaryRow(
            icon: Icons.medical_services_outlined,
            label: 'Recommended Action',
            value: disease.primaryRecommendation,
            valueColor: severityColor,
            multiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesCard(Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 8),
              Text(
                'Other Possible Matches',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Shown when the model is not highly certain.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          ...alternativePredictions.map(
            (alt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(alt.disease.iconEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alt.disease.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    MlConfidence.percentLabel(alt.confidence),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
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

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              MlConfig.aiDisclaimer,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool multiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: multiline ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                  height: multiline ? 1.45 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: color.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
