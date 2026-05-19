// ============================================================
// FILE: screens/home_screen.dart
// PURPOSE: Main landing screen of Agri-Doctor app
// CONCEPT: StatelessWidget, Navigator.push, OOP usage
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scan_screen.dart';
import 'disease_list_screen.dart';
import 'tips_screen.dart';
import 'history_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---- AppBar ----
      appBar: AppBar(
        title: const Text('Agri-Doctor 🌾'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Scan History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => _showAboutDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),

      // ---- Body ----
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- Hero Banner Section ---
            _buildHeroBanner(),

            const SizedBox(height: 24),

            // --- Section Title ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What would you like to do?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Main Action Buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Button 1: Scan Leaf
                  _buildMainButton(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Scan Leaf',
                    subtitle: 'Detect disease from leaf image',
                    color: const Color(0xFF2E7D32),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScanScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Button 2: View Diseases
                  _buildMainButton(
                    context: context,
                    icon: Icons.local_hospital,
                    label: 'View Diseases',
                    subtitle: 'Browse all plant diseases',
                    color: const Color(0xFF388E3C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiseaseListScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Button 3: Farmer Tips (Bonus)
                  _buildMainButton(
                    context: context,
                    icon: Icons.lightbulb,
                    label: 'Farmer Tips 🌟',
                    subtitle: 'Best practices for healthy crops',
                    color: const Color(0xFF558B2F),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TipsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Quick Stats Section ---
            _buildStatsRow(),

            const SizedBox(height: 30),

            // --- Disclaimer Footer ---
            _buildFooter(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Hero Banner with gradient background
  // ----------------------------------------------------------------
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big leaf icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.eco,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Smart Plant\nDisease Detection',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Identify crop diseases instantly and get expert solutions',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 16),
          // Badge row
          Row(
            children: [
              _buildBadge('🌾 Wheat'),
              const SizedBox(width: 8),
              _buildBadge('🌿 Vegetables'),
              const SizedBox(width: 8),
              _buildBadge('🍃 Fruits'),
            ],
          ),
          const SizedBox(height: 12),
          // Logged-in user
          if (FirebaseAuth.instance.currentUser != null)
            Row(
              children: [
                const Icon(Icons.account_circle,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  FirebaseAuth.instance.currentUser!.email ?? '',
                  style:
                      TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Small badge chip widget
  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Large action button card
  // ----------------------------------------------------------------
  Widget _buildMainButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Stats row (visual statistics)
  // ----------------------------------------------------------------
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard('6+', 'Diseases\nDetected', Icons.bug_report),
          const SizedBox(width: 12),
          _buildStatCard('100%', 'Free to\nUse', Icons.star),
          const SizedBox(width: 12),
          _buildStatCard('5+', 'Farmer\nTips', Icons.lightbulb),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // WIDGET: Footer disclaimer
  // ----------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This version simulates AI detection using predefined logic. '
              'Final version will use TensorFlow Lite for real-time detection.',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // DIALOG: Sign out confirmation
  // ----------------------------------------------------------------
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService().signOut();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // DIALOG: About app dialog
  // ----------------------------------------------------------------
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.eco, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('About Agri-Doctor'),
          ],
        ),
        content: const Text(
          'Agri-Doctor is a smart plant disease detection app designed for farmers.\n\n'
          'Version: 1.0.0 (Lite)\n'
          'Built with: Flutter & Dart\n'
          'Project: Midterm Demo\n\n'
          'In the final version, real-time ML detection will be integrated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }
}