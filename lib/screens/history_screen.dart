import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/analytics_service.dart';
import '../services/database_service.dart';
import '../utils/ml_confidence.dart';
import 'result_screen.dart';
import 'scan_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _databaseService = DatabaseService();
  final _analytics = AnalyticsService();
  int _streamKey = 0;

  @override
  void initState() {
    super.initState();
    _analytics.logHistoryOpened().catchError((_) {});
  }

  Future<void> _refresh() async {
    setState(() => _streamKey++);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _openNewScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }

  void _openResult(ScanResult scan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          disease: scan.toDisease(),
          confidence: scan.confidence > 0 ? scan.confidence : null,
          historyLocalPath:
              scan.hasPersistedImage ? scan.localImagePath : null,
          cropName: scan.displayCrop,
          mlClassIndex: scan.mlClassIndex,
        ),
      ),
    );
  }

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
        stream: _databaseService.getScanHistory().timeout(
          const Duration(seconds: 12),
          onTimeout: (EventSink<List<ScanResult>> sink) {
            debugPrint('[HistoryScreen] history fetch timed out');
            sink.addError(
              TimeoutException('Timed out loading scan history'),
            );
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('[HistoryScreen] Firebase error: ${snapshot.error}');
            return _buildErrorState();
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          final scans = snapshot.data ?? [];

          if (scans.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: const Color(0xFF2E7D32),
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: scans.length,
              itemBuilder: (context, index) => _ScanCard(
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
                color: const Color(0xFFA5D6A7).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history,
                  size: 64, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No scan history yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your analyzed leaf scans will appear here.\nStart by scanning a leaf photo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openNewScan,
              icon: const Icon(Icons.camera_alt),
              label: const Text('New Scan'),
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
              'Check your internet connection and try again.',
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
    final level = scan.confidenceLevel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(scan: scan, accentColor: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.diseaseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1B5E20),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.displayCrop,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _SeverityBadge(
                          label: scan.severity,
                          color: severityColor,
                        ),
                        if (scan.confidence > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _confidenceBg(level),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${MlConfidence.percentLabel(scan.confidence)} · ${level.label}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _confidenceFg(level),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          scan.scanSource == 'camera'
                              ? Icons.camera_alt_outlined
                              : Icons.photo_library_outlined,
                          size: 13,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(scan.scannedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (!scan.hasPersistedImage &&
                            scan.localImagePath != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.image_not_supported_outlined,
                              size: 13, color: Colors.grey[400]),
                          const SizedBox(width: 2),
                          Text(
                            'Photo unavailable',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.chevron_right,
                      color: color.withValues(alpha: 0.5), size: 22),
                  const SizedBox(height: 12),
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

  static Color _confidenceBg(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return const Color(0xFFE8F5E9);
      case ConfidenceLevel.medium:
        return const Color(0xFFFFF8E1);
      case ConfidenceLevel.low:
        return const Color(0xFFFBE9E7);
    }
  }

  static Color _confidenceFg(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return const Color(0xFF2E7D32);
      case ConfidenceLevel.medium:
        return const Color(0xFFF9A825);
      case ConfidenceLevel.low:
        return const Color(0xFFE65100);
    }
  }

  static String _formatDateTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday · ${_time(dt)}';
    return '${dt.day}/${dt.month}/${dt.year} · ${_time(dt)}';
  }

  static String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _Thumbnail extends StatelessWidget {
  final ScanResult scan;
  final Color accentColor;

  const _Thumbnail({required this.scan, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final showImage = scan.hasPersistedImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 72,
        height: 72,
        child: showImage
            ? Image.file(
                File(scan.localImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(
                  icon: Icons.broken_image_outlined,
                  subtitle: 'Unavailable',
                ),
              )
            : _placeholder(
                icon: scan.localImagePath != null
                    ? Icons.image_not_supported_outlined
                    : Icons.eco_outlined,
                subtitle: scan.localImagePath != null ? 'No photo' : null,
              ),
      ),
    );
  }

  Widget _placeholder({required IconData icon, String? subtitle}) {
    return Container(
      color: accentColor.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(scan.diseaseEmoji, style: const TextStyle(fontSize: 26)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Icon(icon, size: 14, color: Colors.grey[500]),
          ],
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label == 'None' ? 'Healthy' : label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
