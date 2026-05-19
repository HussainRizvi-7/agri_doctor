// ============================================================
// FILE: screens/tips_screen.dart
// PURPOSE: BONUS FEATURE — Show farmer tips using Cards
// CONCEPT: StatelessWidget, Lists, Icons, Cards
// ============================================================

import 'package:flutter/material.dart';

/// TipItem class — Simple OOP class to hold a single tip's data
class TipItem {
  final String title;       // Short title of the tip
  final String description; // Detailed explanation
  final IconData icon;      // Icon to display
  final Color color;        // Accent color for the card

  // Constructor
  TipItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// TipsScreen — Displays farming tips in styled cards
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  // ----------------------------------------------------------------
  // DATA: List of TipItem objects (List + OOP)
  // ----------------------------------------------------------------
  static final List<TipItem> farmerTips = [
    TipItem(
      title: 'Water Regularly & Wisely',
      description:
          'Water your crops early in the morning to reduce evaporation. '
          'Use drip irrigation for water efficiency. Avoid over-watering '
          'as it can cause root rot and fungal diseases.',
      icon: Icons.water_drop,
      color: const Color(0xFF1565C0),
    ),
    TipItem(
      title: 'Use Certified Seeds',
      description:
          'Always purchase seeds from certified and trusted suppliers. '
          'Certified seeds are disease-free, have higher germination rates, '
          'and are often resistant to common pests and diseases.',
      icon: Icons.spa,
      color: const Color(0xFF2E7D32),
    ),
    TipItem(
      title: 'Monitor Crops Weekly',
      description:
          'Walk through your fields at least once a week. Look for unusual '
          'spots, discoloration, wilting, or pest signs. Early detection '
          'of disease saves your entire crop from major loss.',
      icon: Icons.visibility,
      color: const Color(0xFF6A1B9A),
    ),
    TipItem(
      title: 'Rotate Your Crops',
      description:
          'Do not grow the same crop in the same field every season. '
          'Crop rotation breaks disease and pest cycles, improves soil '
          'fertility, and reduces the need for pesticides.',
      icon: Icons.rotate_right,
      color: const Color(0xFFE65100),
    ),
    TipItem(
      title: 'Use Organic Fertilizers',
      description:
          'Incorporate compost and organic matter into your soil. '
          'Organic fertilizers improve soil structure, promote beneficial '
          'microbes, and provide slow-release nutrients for healthier crops.',
      icon: Icons.eco,
      color: const Color(0xFF558B2F),
    ),
    TipItem(
      title: 'Control Weeds Early',
      description:
          'Remove weeds before they flower and spread seeds. Weeds '
          'compete for nutrients, water, and sunlight. They also serve '
          'as hosts for pests and diseases that can infect your crops.',
      icon: Icons.grass,
      color: const Color(0xFF00695C),
    ),
    TipItem(
      title: 'Store Harvest Properly',
      description:
          'Use clean, dry storage facilities for harvested produce. '
          'Improper storage leads to post-harvest losses due to mold, '
          'insects, and moisture damage. Check stored grains regularly.',
      icon: Icons.warehouse,
      color: const Color(0xFF8D6E63),
    ),
  ];

  // ----------------------------------------------------------------
  // BUILD METHOD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Tips 🌟'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // ---- Hero Banner ----
          _buildHeroBanner(),

          // ---- Tips List ----
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: farmerTips.length,
              itemBuilder: (context, index) {
                return _buildTipCard(farmerTips[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Hero banner at top
  // ----------------------------------------------------------------
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Farming Tips',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${farmerTips.length} expert tips for better yields',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Individual tip card
  // ----------------------------------------------------------------
  Widget _buildTipCard(TipItem tip, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: tip.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: tip.color.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Left: Number + Icon ----
              Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: tip.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(tip.icon, color: tip.color, size: 26),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tip ${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: tip.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // ---- Right: Title + Description ----
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: tip.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tip.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}