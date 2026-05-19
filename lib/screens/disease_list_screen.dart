import 'package:flutter/material.dart';
import '../models/disease_catalog.dart';
import '../services/analytics_service.dart';
import 'result_screen.dart';

/// Reference encyclopedia for all ML-detectable plant disease classes.
class DiseaseListScreen extends StatelessWidget {
  const DiseaseListScreen({super.key});

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
      case 'None':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFF9A825);
    }
  }

  String _cropEmoji(String crop) {
    switch (crop) {
      case 'Apple':
        return '🍎';
      case 'Blueberry':
        return '🫐';
      case 'Cherry':
        return '🍒';
      case 'Corn':
        return '🌽';
      case 'Grape':
        return '🍇';
      case 'Orange':
        return '🍊';
      case 'Peach':
        return '🍑';
      case 'Pepper':
        return '🫑';
      case 'Potato':
        return '🥔';
      case 'Raspberry':
        return '🫐';
      case 'Soybean':
        return '🌱';
      case 'Squash':
        return '🥒';
      case 'Strawberry':
        return '🍓';
      case 'Tomato':
        return '🍅';
      default:
        return '🌿';
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = mlDiseasesGroupedByCrop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Reference'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.biotech, color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$mlDetectableClassCount classes · matches TensorFlow Lite model',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                for (final cropEntry in grouped.entries) ...[
                  _buildCropHeader(cropEntry.key, cropEntry.value.length),
                  ...cropEntry.value.map(
                    (entry) => _buildDiseaseCard(context, entry),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.menu_book, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plant Disease Encyclopedia',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Browse every class the AI can detect, organized by crop',
                  style: TextStyle(
                    color: Colors.white70,
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

  Widget _buildCropHeader(String crop, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        children: [
          Text(_cropEmoji(crop), style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(
            crop,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(BuildContext context, MlDiseaseEntry entry) {
    final disease = entry.disease;
    final diseaseColor = _hexToColor(disease.color);
    final severityColor = _severityColor(disease.severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            AnalyticsService()
                .logDiseaseDetailsOpened(
                  diseaseName: disease.name,
                  crop: entry.crop,
                )
                .catchError((_) {});
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  disease: disease,
                  cropName: entry.crop,
                  mlClassIndex: entry.mlIndex,
                  isReferenceView: true,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: diseaseColor.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: diseaseColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    disease.iconEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: diseaseColor,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Class ${entry.mlIndex} · ${entry.crop}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        disease.description.length > 90
                            ? '${disease.description.substring(0, 90)}...'
                            : disease.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: severityColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          disease.isHealthy
                              ? 'Healthy'
                              : 'Severity: ${disease.severity}',
                          style: TextStyle(
                            fontSize: 11,
                            color: severityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: diseaseColor.withValues(alpha: 0.7),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
