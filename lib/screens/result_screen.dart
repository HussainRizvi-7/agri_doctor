// ============================================================
// FILE: screens/result_screen.dart
// PURPOSE: Display disease detection result with full details
// CONCEPT: StatelessWidget, OOP (receiving Disease object), Navigation
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/disease.dart';

/// ResultScreen — Shows the detected disease name, description & solution.
/// Receives a Disease object passed from ScanScreen or DiseaseListScreen.
class ResultScreen extends StatelessWidget {
  final Disease disease;
  final double? confidence;      // optional ML confidence score (0.0–1.0)
  final String? historyLocalPath; // local image path when re-opened from history

  const ResultScreen({
    super.key,
    required this.disease,
    this.confidence,
    this.historyLocalPath,
  });

  // ----------------------------------------------------------------
  // Helper: Convert hex color string to Flutter Color
  // ----------------------------------------------------------------
  Color _hexToColor(String hex) {
    // Remove '#' character and parse as integer
    final String cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  // ----------------------------------------------------------------
  // Helper: Get severity color based on severity string (if-else logic)
  // ----------------------------------------------------------------
  Color _getSeverityColor(String severity) {
    if (severity == 'High') {
      return const Color(0xFFC62828); // Red
    } else if (severity == 'Medium') {
      return const Color(0xFFE65100); // Orange
    } else if (severity == 'Low') {
      return const Color(0xFFF9A825); // Yellow
    } else {
      return const Color(0xFF2E7D32); // Green (None / Healthy)
    }
  }

  // ----------------------------------------------------------------
  // Helper: Get severity icon
  // ----------------------------------------------------------------
  IconData _getSeverityIcon(String severity) {
    if (severity == 'High') {
      return Icons.warning_rounded;
    } else if (severity == 'Medium') {
      return Icons.info_rounded;
    } else if (severity == 'None') {
      return Icons.check_circle;
    } else {
      return Icons.warning_amber_rounded;
    }
  }

  // ----------------------------------------------------------------
  // BUILD METHOD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Resolve the disease accent color
    final Color diseaseColor = _hexToColor(disease.color);
    final Color severityColor = _getSeverityColor(disease.severity);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Analysis Result 📊'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ---- Top Result Hero Card ----
            _buildResultHero(diseaseColor, severityColor),

            // ---- Body Content ----
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Scanned image (history re-open only) ----
                  if (historyLocalPath != null) ...[
                    _buildImagePreview(historyLocalPath!),
                    const SizedBox(height: 16),
                  ],

                  // ---- Description Card ----
                  _buildSectionCard(
                    icon: Icons.description,
                    title: 'About This Disease',
                    content: disease.description,
                    color: diseaseColor,
                  ),

                  const SizedBox(height: 16),

                  // ---- Solution Card ----
                  _buildSectionCard(
                    icon: Icons.healing,
                    title: 'Recommended Solutions',
                    content: disease.solution,
                    color: const Color(0xFF2E7D32),
                  ),

                  const SizedBox(height: 16),

                  // ---- Quick Actions ----
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // ---- Back to Home Button ----
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Pop back to scan screen
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Scan'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- Go to Disease List ----
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Pop all the way back to home
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(
                        Icons.home,
                        color: Color(0xFF2E7D32),
                      ),
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

  // ----------------------------------------------------------------
  // WIDGET: Scanned leaf image preview (history re-open)
  // ----------------------------------------------------------------
  Widget _buildImagePreview(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFE8F5E9),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  size: 40, color: Color(0xFFA5D6A7)),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Top hero section showing disease name + emoji
  // ----------------------------------------------------------------
  Widget _buildResultHero(Color diseaseColor, Color severityColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            diseaseColor,
            diseaseColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      child: Column(
        children: [
          // Emoji icon in circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              disease.iconEmoji,
              style: const TextStyle(fontSize: 52),
            ),
          ),

          const SizedBox(height: 16),

          // Disease name
          Text(
            disease.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Severity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSeverityIcon(disease.severity),
                  color: severityColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Severity: ${disease.severity}',
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Detection complete + optional confidence badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Detection Complete',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
              if (confidence != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(confidence! * 100).toStringAsFixed(1)}% confident',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Content section card (description / solution)
  // ----------------------------------------------------------------
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
            color: Colors.green.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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
          // Divider
          Divider(color: color.withOpacity(0.15), height: 1),
          const SizedBox(height: 12),
          // Content text
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

  // ----------------------------------------------------------------
  // WIDGET: Quick action chips
  // ----------------------------------------------------------------
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildActionChip(Icons.share, 'Share'),
            const SizedBox(width: 10),
            _buildActionChip(Icons.bookmark_border, 'Save'),
            const SizedBox(width: 10),
            _buildActionChip(Icons.print, 'Print'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}