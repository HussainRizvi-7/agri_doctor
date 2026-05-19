import 'package:flutter/foundation.dart';

import 'scan_result.dart';

/// Aggregated scan statistics for the AI Analytics Dashboard.
class ScanAnalyticsSummary {
  final int totalScans;
  final int healthyCount;
  final int diseasedCount;
  final double healthyPercent;
  final double diseasedPercent;
  final String? topDisease;
  final int topDiseaseCount;
  final String? topCrop;
  final int topCropCount;
  final double averageConfidence;
  final Map<String, int> diseaseCounts;
  final List<WeeklyScanBucket> weeklyActivity;

  const ScanAnalyticsSummary({
    required this.totalScans,
    required this.healthyCount,
    required this.diseasedCount,
    required this.healthyPercent,
    required this.diseasedPercent,
    this.topDisease,
    this.topDiseaseCount = 0,
    this.topCrop,
    this.topCropCount = 0,
    required this.averageConfidence,
    required this.diseaseCounts,
    required this.weeklyActivity,
  });

  static final empty = ScanAnalyticsSummary(
    totalScans: 0,
    healthyCount: 0,
    diseasedCount: 0,
    healthyPercent: 0,
    diseasedPercent: 0,
    averageConfidence: 0,
    diseaseCounts: const {},
    weeklyActivity: _emptyWeeklyBuckets(),
  );

  /// Drops invalid records so charts and insights never crash on bad data.
  static List<ScanResult> sanitizeScans(List<ScanResult> raw) {
    final cleaned = <ScanResult>[];
    for (final scan in raw) {
      try {
        if (scan.diseaseName.trim().isEmpty) continue;
        if (!scan.confidence.isFinite) continue;
        if (scan.confidence < 0) continue;
        cleaned.add(scan);
      } catch (e) {
        debugPrint('[Analytics] skipped malformed scan: $e');
      }
    }
    return cleaned;
  }

  static double safePercent(int part, int total) {
    if (total <= 0 || part < 0) return 0;
    final value = (part / total) * 100;
    if (!value.isFinite) return 0;
    return value.clamp(0, 100);
  }

  static double safeDouble(double value, {double fallback = 0}) {
    if (!value.isFinite) return fallback;
    return value;
  }

  static bool isHealthyScan(ScanResult scan) {
    if (scan.severity == 'None') return true;
    return scan.diseaseName.toLowerCase().contains('healthy');
  }

  factory ScanAnalyticsSummary.fromScans(List<ScanResult> scans) {
    scans = sanitizeScans(scans);
    if (scans.isEmpty) return ScanAnalyticsSummary.empty;

    var healthy = 0;
    var confidenceSum = 0.0;
    var confidenceCount = 0;
    final diseaseMap = <String, int>{};
    final cropMap = <String, int>{};

    for (final scan in scans) {
      if (isHealthyScan(scan)) {
        healthy++;
      }
      if (scan.confidence > 0) {
        confidenceSum += scan.confidence;
        confidenceCount++;
      }
      diseaseMap[scan.diseaseName] = (diseaseMap[scan.diseaseName] ?? 0) + 1;
      final crop = scan.displayCrop;
      cropMap[crop] = (cropMap[crop] ?? 0) + 1;
    }

    final total = scans.length;
    final diseased = total - healthy;

    String? topDisease;
    var topDiseaseCount = 0;
    for (final entry in diseaseMap.entries) {
      if (entry.value > topDiseaseCount) {
        topDisease = entry.key;
        topDiseaseCount = entry.value;
      }
    }

    String? topCrop;
    var topCropCount = 0;
    for (final entry in cropMap.entries) {
      if (entry.value > topCropCount) {
        topCrop = entry.key;
        topCropCount = entry.value;
      }
    }

    final sortedDiseases = diseaseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topDiseaseCounts = <String, int>{
      for (final e in sortedDiseases.take(5)) e.key: e.value,
    };

    return ScanAnalyticsSummary(
      totalScans: total,
      healthyCount: healthy,
      diseasedCount: diseased,
      healthyPercent: safePercent(healthy, total),
      diseasedPercent: safePercent(diseased, total),
      topDisease: topDisease,
      topDiseaseCount: topDiseaseCount,
      topCrop: topCrop,
      topCropCount: topCropCount,
      averageConfidence: safeDouble(
        confidenceCount > 0 ? confidenceSum / confidenceCount : 0,
      ),
      diseaseCounts: topDiseaseCounts,
      weeklyActivity: _buildWeeklyBuckets(scans),
    );
  }

  String get averageConfidenceLabel {
    if (totalScans == 0 || averageConfidence <= 0) return '—';
    final pct = safeDouble(averageConfidence) * 100;
    if (!pct.isFinite) return '—';
    return '${pct.round()}%';
  }

  int get healthyPercentRounded =>
      safePercent(healthyCount, totalScans).round();

  int get diseasedPercentRounded =>
      safePercent(diseasedCount, totalScans).round();

  static List<WeeklyScanBucket> _emptyWeeklyBuckets() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: 6 - i),
      );
      return WeeklyScanBucket(label: _weekdayShort(day.weekday), count: 0);
    });
  }

  static List<WeeklyScanBucket> _buildWeeklyBuckets(List<ScanResult> scans) {
    final now = DateTime.now();
    final buckets = <WeeklyScanBucket>[];

    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: i),
      );
      final label = _weekdayShort(day.weekday);
      final count = scans.where((s) {
        final d = DateTime(
          s.scannedAt.year,
          s.scannedAt.month,
          s.scannedAt.day,
        );
        return d == day;
      }).length;
      buckets.add(WeeklyScanBucket(label: label, count: count));
    }
    return buckets;
  }

  static String _weekdayShort(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }
}

class WeeklyScanBucket {
  final String label;
  final int count;

  const WeeklyScanBucket({required this.label, required this.count});
}
