import '../models/scan_analytics_summary.dart';
import '../models/scan_result.dart';
import '../utils/ml_confidence.dart';

class AiInsight {
  final String title;
  final String message;
  final String iconName;

  const AiInsight({
    this.title = 'AI Insight',
    required this.message,
    this.iconName = 'insights',
  });
}

/// Rule-based agricultural insights derived from scan history.
class AiInsightsService {
  static const _fungalKeywords = [
    'blight',
    'rust',
    'mildew',
    'mold',
    'scab',
    'rot',
    'anthracnose',
    'cercospora',
    'leaf spot',
  ];

  static List<AiInsight> generate(List<ScanResult> scans) {
    if (scans.isEmpty) {
      return const [
        AiInsight(
          message:
              'No scan data available yet. Complete leaf scans to unlock '
              'personalized AI agricultural insights and trend analysis.',
          iconName: 'eco',
        ),
      ];
    }

    final summary = ScanAnalyticsSummary.fromScans(scans);
    final insights = <AiInsight>[];

    if (summary.healthyPercent >= 65) {
      insights.add(
        AiInsight(
          message:
              'Recent scans indicate generally healthy crop conditions. '
              'Continue regular monitoring and maintain current cultivation practices.',
          iconName: 'check_circle',
        ),
      );
    }

    final fungalScans = scans.where(_isFungalDisease).toList();
    if (fungalScans.length >= 2 &&
        fungalScans.length >= scans.length * 0.25) {
      final cropCounts = <String, int>{};
      for (final s in fungalScans) {
        cropCounts[s.displayCrop] = (cropCounts[s.displayCrop] ?? 0) + 1;
      }
      final topCrop = _topKey(cropCounts) ?? 'your crops';
      insights.add(
        AiInsight(
          message:
              'Frequent fungal detections observed in $topCrop crops. '
              'Consider improving airflow, avoiding overhead irrigation, and '
              'reducing leaf moisture during humid periods.',
          iconName: 'water_drop',
        ),
      );
    }

    final lowConfidence = scans
        .where((s) => s.confidenceLevel == ConfidenceLevel.low)
        .length;
    if (lowConfidence >= 2 && lowConfidence / scans.length >= 0.2) {
      insights.add(
        AiInsight(
          message:
              'Several low-confidence scans detected. Encourage clearer leaf '
              'imaging with even lighting and a single leaf filling the frame '
              'for improved diagnosis accuracy.',
          iconName: 'photo_camera',
        ),
      );
    }

    final highSeverity = scans
        .where((s) => s.severity.toLowerCase() == 'high' && !ScanAnalyticsSummary.isHealthyScan(s))
        .length;
    if (highSeverity >= 2 && highSeverity / scans.length >= 0.3) {
      insights.add(
        AiInsight(
          message:
              'Multiple high-severity disease detections recorded. Prioritize '
              'isolation of affected plants and apply recommended treatments promptly.',
          iconName: 'warning',
        ),
      );
    }

    ScanResult? topDiseaseScan;
    if (summary.topDisease != null) {
      for (final s in scans) {
        if (s.diseaseName == summary.topDisease) {
          topDiseaseScan = s;
          break;
        }
      }
    }
    if (summary.topCrop != null &&
        summary.topCropCount >= scans.length * 0.4 &&
        topDiseaseScan != null &&
        !ScanAnalyticsSummary.isHealthyScan(topDiseaseScan)) {
      insights.add(
        AiInsight(
          message:
              '${summary.topDisease} is the most frequent finding on '
              '${summary.topCrop} scans. Review crop-specific prevention '
              'steps in the disease reference guide.',
          iconName: 'agriculture',
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        AiInsight(
          message:
              'Your scan portfolio shows mixed crop health signals. Keep '
              'logging scans weekly to strengthen trend detection and '
              'field recommendations.',
          iconName: 'trending_up',
        ),
      );
    }

    return insights.take(4).toList();
  }

  static bool _isFungalDisease(ScanResult scan) {
    if (ScanAnalyticsSummary.isHealthyScan(scan)) return false;
    final name = scan.diseaseName.toLowerCase();
    return _fungalKeywords.any(name.contains);
  }

  static String? _topKey(Map<String, int> counts) {
    String? key;
    var max = 0;
    for (final e in counts.entries) {
      if (e.value > max) {
        max = e.value;
        key = e.key;
      }
    }
    return key;
  }
}
