import 'dart:io';
import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/database_service.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _databaseService = DatabaseService();

  // Incrementing this key forces the StreamBuilder to re-subscribe (pull-to-refresh)
  int _streamKey = 0;

  Future<void> _refresh() async {
    setState(() => _streamKey++);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Scan History'),
        leading: const BackButton(),
      ),
      body: StreamBuilder<List<ScanResult>>(
        key: ValueKey(_streamKey),
        stream: _databaseService.getScanHistory(),
        builder: (context, snapshot) {
          // ── Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          // ── Error
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final scans = snapshot.data ?? [];

          // ── Empty
          if (scans.isEmpty) {
            return _buildEmptyState();
          }

          // ── List
          return RefreshIndicator(
            color: const Color(0xFF2E7D32),
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: scans.length,
              itemBuilder: (context, index) =>
                  _ScanCard(
                    scan: scans[index],
                    onDelete: () => _confirmDelete(scans[index]),
                    onTap: () => _openResult(scans[index]),
                  ),
            ),
          );
        },
      ),
    );
  }

  // ── Navigate to ResultScreen using stored disease data
  void _openResult(ScanResult scan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          disease: scan.toDisease(),
          confidence: scan.confidence > 0 ? scan.confidence : null,
          historyLocalPath: scan.localImagePath,
        ),
      ),
    );
  }

  // ── Delete confirmation dialog
  void _confirmDelete(ScanResult scan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Scan?'),
        content: Text('Remove "${scan.diseaseName}" from your history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteScan(scan);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _deleteScan(ScanResult scan) {
    _databaseService.deleteScan(scan.id).catchError((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete scan. Try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // ── State widgets
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFA5D6A7).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history,
                  size: 64, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No scans yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your scan history will appear here\nafter you analyze a leaf photo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Could not load history',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection\nand try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
              label: const Text('Retry',
                  style: TextStyle(color: Color(0xFF2E7D32))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D32)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScanCard — individual history item
// ─────────────────────────────────────────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final ScanResult scan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ScanCard({
    required this.scan,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(scan.color);
    final severityColor = _severityColor(scan.severity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Thumbnail
              _Thumbnail(scan: scan, accentColor: color),
              const SizedBox(width: 14),

              // ── Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease name
                    Text(
                      scan.diseaseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1B5E20),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Severity + confidence row
                    Row(
                      children: [
                        _SeverityBadge(
                          label: scan.severity,
                          color: severityColor,
                        ),
                        const SizedBox(width: 8),
                        if (scan.confidence > 0)
                          Text(
                            '${(scan.confidence * 100).toStringAsFixed(1)}% confident',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Timestamp + source
                    Row(
                      children: [
                        Icon(
                          scan.scanSource == 'camera'
                              ? Icons.camera_alt_outlined
                              : Icons.photo_library_outlined,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(scan.scannedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_right,
                      color: color.withOpacity(0.5), size: 20),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF2E7D32);
    }
  }

  static Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red[700]!;
      case 'medium':
        return Colors.orange[700]!;
      case 'none':
        return Colors.green[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  static String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Thumbnail — network image → emoji fallback
// ─────────────────────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final ScanResult scan;
  final Color accentColor;

  const _Thumbnail({required this.scan, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 68,
        height: 68,
        child: scan.localImagePath != null
            ? Image.file(
                File(scan.localImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: accentColor.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(scan.diseaseEmoji, style: const TextStyle(fontSize: 30)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SeverityBadge
// ─────────────────────────────────────────────────────────────────────────────
class _SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
