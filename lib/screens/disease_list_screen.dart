// ============================================================
// FILE: screens/disease_list_screen.dart
// PURPOSE: Display all diseases using ListView.builder
// CONCEPT: ListView.builder, List<Disease>, OOP, Navigator
// ============================================================

import 'package:flutter/material.dart';
import '../models/disease.dart';
import 'result_screen.dart';

/// DiseaseListScreen — Shows all diseases in a scrollable list.
/// Uses ListView.builder for efficient rendering.
class DiseaseListScreen extends StatelessWidget {
  const DiseaseListScreen({super.key});

  // Helper: Convert hex string to Flutter Color
  Color _hexToColor(String hex) {
    final String cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  // Helper: Get severity color using if-else
  Color _getSeverityColor(String severity) {
    if (severity == 'High') {
      return const Color(0xFFC62828);
    } else if (severity == 'Medium') {
      return const Color(0xFFE65100);
    } else if (severity == 'None') {
      return const Color(0xFF2E7D32);
    } else {
      return const Color(0xFFF9A825);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Diseases 📋'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // ---- Top Info Banner ----
          _buildInfoBanner(),

          // ---- Disease Count Label ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.list_alt,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${diseaseList.length} diseases found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),

          // ---- ListView.builder for Disease List ----
          // This is the key Flutter concept: efficient list rendering
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              // Total number of items = length of diseaseList
              itemCount: diseaseList.length,
              // Builder function creates each list item on demand
              itemBuilder: (BuildContext context, int index) {
                // Get the Disease object at current index
                Disease currentDisease = diseaseList[index];

                // Return a Card widget for each disease
                return _buildDiseaseCard(context, currentDisease, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Top info banner
  // ----------------------------------------------------------------
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
      child: Row(
        children: [
          const Icon(Icons.medical_information, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Disease Encyclopedia',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Tap any disease card to view full details & solutions',
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
  // WIDGET: Individual disease card in the list
  // ----------------------------------------------------------------
  Widget _buildDiseaseCard(
    BuildContext context,
    Disease disease,
    int index,
  ) {
    // Resolve colors for this disease
    final Color diseaseColor = _hexToColor(disease.color);
    final Color severityColor = _getSeverityColor(disease.severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        // On tap: navigate to ResultScreen, passing this disease
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(disease: disease),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: diseaseColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: diseaseColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              // ---- Left: Emoji + Number ----
              Column(
                children: [
                  // Disease emoji in colored circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: diseaseColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      disease.iconEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Index number badge
                  Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // ---- Middle: Disease Info ----
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease name
                    Text(
                      disease.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: diseaseColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Short description (first 70 chars)
                    Text(
                      disease.description.length > 75
                          ? '${disease.description.substring(0, 75)}...'
                          : disease.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Severity chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: severityColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '⚠ Severity: ${disease.severity}',
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

              const SizedBox(width: 10),

              // ---- Right: Arrow icon ----
              Icon(
                Icons.arrow_forward_ios,
                color: diseaseColor.withOpacity(0.6),
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}