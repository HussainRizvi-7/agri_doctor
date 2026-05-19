import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/scan_analytics_summary.dart';
import '../models/scan_result.dart';
import '../services/ai_insights_service.dart';
import '../services/analytics_service.dart';
import '../services/database_service.dart';
import 'scan_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const _firstEventTimeout = Duration(seconds: 22);
  static const _maxAutoRetries = 1;

  final _databaseService = DatabaseService();
  final _analytics = AnalyticsService();

  StreamSubscription<List<ScanResult>>? _subscription;
  Timer? _watchdog;

  List<ScanResult> _scans = [];
  bool _loading = true;
  bool _showError = false;
  int _autoRetries = 0;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _analytics.logAnalyticsScreenOpened().catchError((_) {});
    _analytics.logScreenView('AI Insights & Analytics').catchError((_) {});
    _startListening();
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _startListening({bool manualRetry = false}) {
    _watchdog?.cancel();
    _subscription?.cancel();

    if (manualRetry) {
      _autoRetries = 0;
    }

    final generation = ++_loadGeneration;
    debugPrint('[Analytics] loading started (retry=$_autoRetries)');

    setState(() {
      _loading = true;
      _showError = false;
    });

    _subscription = _databaseService.getScanHistory().listen(
      (data) {
        if (!mounted || generation != _loadGeneration) return;
        _watchdog?.cancel();

        final sanitized = ScanAnalyticsSummary.sanitizeScans(data);
        debugPrint('[Analytics] scan count=${sanitized.length}');

        final summary = ScanAnalyticsSummary.fromScans(sanitized);
        debugPrint(
          '[Analytics] chart generation ready: '
          'healthy=${summary.healthyCount}, '
          'diseases=${summary.diseaseCounts.length}, '
          'weekly=${summary.weeklyActivity.length}',
        );

        setState(() {
          _scans = sanitized;
          _loading = false;
          _showError = false;
          _autoRetries = 0;
        });
      },
      onError: (Object error) {
        if (!mounted || generation != _loadGeneration) return;
        debugPrint('[Analytics] Firebase error: $error');
        _handleLoadFailure(generation);
      },
    );

    _watchdog = Timer(_firstEventTimeout, () {
      if (!mounted || generation != _loadGeneration || !_loading) return;
      debugPrint('[Analytics] first event slow — scheduling retry');
      _handleLoadFailure(generation);
    });
  }

  void _handleLoadFailure(int generation) {
    if (!mounted || generation != _loadGeneration) return;

    if (_autoRetries < _maxAutoRetries) {
      _autoRetries++;
      debugPrint('[Analytics] auto-retry $_autoRetries/$_maxAutoRetries');
      _startListening();
      return;
    }

    setState(() {
      _loading = false;
      _showError = true;
    });
  }

  Future<void> _onRefresh() async {
    _autoRetries = 0;
    _startListening(manualRetry: true);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('AI Insights & Analytics'),
        leading: const BackButton(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _scans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 14),
            Text(
              'Loading analytics…',
              style: TextStyle(color: Color(0xFF1B5E20), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_showError && _scans.isEmpty) {
      return _ErrorState(onRetry: () => _startListening(manualRetry: true));
    }

    final summary = ScanAnalyticsSummary.fromScans(_scans);
    final insights = AiInsightsService.generate(_scans);
    final isEmpty = summary.totalScans == 0;

    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _HeroBanner(totalScans: summary.totalScans),
          if (isEmpty) ...[
            const SizedBox(height: 20),
            _EmptyOnboardingState(onScan: _openScan),
          ] else ...[
            const SizedBox(height: 16),
            _SummaryGrid(summary: summary),
            const SizedBox(height: 20),
            _SectionTitle('AI Insights', Icons.psychology_outlined),
            const SizedBox(height: 10),
            ...insights.map(_InsightCard.new),
            const SizedBox(height: 20),
            _SectionTitle('Health Distribution', Icons.pie_chart_outline),
            const SizedBox(height: 10),
            _HealthyPieChart(summary: summary),
            const SizedBox(height: 20),
            if (summary.diseaseCounts.isNotEmpty) ...[
              _SectionTitle('Top Detected Diseases', Icons.bar_chart),
              const SizedBox(height: 10),
              _DiseaseBarChart(counts: summary.diseaseCounts),
              const SizedBox(height: 20),
            ],
            _SectionTitle('Weekly Scan Activity', Icons.show_chart),
            const SizedBox(height: 10),
            _WeeklyTrendChart(buckets: summary.weeklyActivity),
          ],
        ],
      ),
    );
  }

  void _openScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final int totalScans;

  const _HeroBanner({required this.totalScans});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                'AI-Powered Field Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            totalScans > 0
                ? 'Insights derived from $totalScans on-device scan${totalScans == 1 ? '' : 's'}.'
                : 'Start scanning leaves to unlock personalized agricultural insights.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final ScanAnalyticsSummary summary;

  const _SummaryGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.document_scanner_outlined,
                label: 'Total Scans',
                value: '${summary.totalScans}',
                subtitle: summary.totalScans == 1 ? 'scan recorded' : 'scans recorded',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.speed,
                label: 'Avg AI Confidence',
                value: summary.totalScans > 0
                    ? summary.averageConfidenceLabel
                    : '—',
                subtitle: 'model certainty',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.eco_outlined,
                label: 'Healthy',
                value: summary.totalScans > 0
                    ? '${summary.healthyPercent.round()}%'
                    : '—',
                subtitle: '${summary.healthyCount} scans',
                accent: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.coronavirus_outlined,
                label: 'Diseased',
                value: summary.totalScans > 0
                    ? '${summary.diseasedPercent.round()}%'
                    : '—',
                subtitle: '${summary.diseasedCount} scans',
                accent: const Color(0xFFE65100),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.biotech_outlined,
                label: 'Top Disease',
                value: summary.topDisease ?? '—',
                subtitle: summary.topDiseaseCount > 0
                    ? '${summary.topDiseaseCount} detections'
                    : 'no data',
                compactValue: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.agriculture_outlined,
                label: 'Top Crop',
                value: summary.topCrop ?? '—',
                subtitle: summary.topCropCount > 0
                    ? '${summary.topCropCount} scans'
                    : 'no data',
                compactValue: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color? accent;
  final bool compactValue;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    this.accent,
    this.compactValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFF2E7D32);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: compactValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compactValue ? 14 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final AiInsight insight;

  const _InsightCard(this.insight);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7).withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(insight.iconName),
                color: const Color(0xFF2E7D32), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(String name) {
    switch (name) {
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'water_drop':
        return Icons.water_drop_outlined;
      case 'photo_camera':
        return Icons.photo_camera_outlined;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'agriculture':
        return Icons.agriculture;
      case 'trending_up':
        return Icons.trending_up;
      case 'eco':
        return Icons.eco_outlined;
      default:
        return Icons.psychology_outlined;
    }
  }
}

class _HealthyPieChart extends StatelessWidget {
  final ScanAnalyticsSummary summary;

  const _HealthyPieChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.totalScans <= 0) {
      return const SizedBox.shrink();
    }

    final healthy =
        summary.healthyCount.toDouble().clamp(0.0, double.infinity).toDouble();
    final diseased =
        summary.diseasedCount.toDouble().clamp(0.0, double.infinity).toDouble();
    final healthyValue = healthy > 0 ? healthy : 0.001;
    final diseasedValue = diseased > 0 ? diseased : 0.001;

    return _ChartCard(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  PieChartSectionData(
                    value: healthyValue,
                    color: const Color(0xFF43A047),
                    title: '${summary.healthyPercentRounded}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 48,
                  ),
                  PieChartSectionData(
                    value: diseasedValue,
                    color: const Color(0xFFE65100),
                    title: '${summary.diseasedPercentRounded}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 44,
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendDot(
                  color: const Color(0xFF43A047),
                  label: 'Healthy',
                ),
                const SizedBox(height: 8),
                _LegendDot(
                  color: const Color(0xFFE65100),
                  label: 'Diseased',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiseaseBarChart extends StatelessWidget {
  final Map<String, int> counts;

  const _DiseaseBarChart({required this.counts});

  @override
  Widget build(BuildContext context) {
    final entries = counts.entries
        .where((e) => e.value > 0 && e.key.trim().isNotEmpty)
        .toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final chartMaxY =
        (maxY + 1).toDouble().clamp(1.0, double.infinity).toDouble();

    return _ChartCard(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final short = _shortLabel(entries[i].key);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      short,
                      style: TextStyle(fontSize: 9, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.toDouble(),
                    color: Color.lerp(
                      const Color(0xFF81C784),
                      const Color(0xFF1B5E20),
                      entries.length > 1 ? i / (entries.length - 1) : 0,
                    )!,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _shortLabel(String name) {
    final words = name.split(' ');
    if (words.length <= 2) return name;
    return '${words.first}\n${words.sublist(1).join(' ')}';
  }
}

class _WeeklyTrendChart extends StatelessWidget {
  final List<WeeklyScanBucket> buckets;

  const _WeeklyTrendChart({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final safeBuckets = buckets.isNotEmpty
        ? buckets
        : ScanAnalyticsSummary.empty.weeklyActivity;
    if (safeBuckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = safeBuckets.fold<int>(0, (m, b) => b.count > m ? b.count : m);
    final chartMaxY =
        (maxY + 1).toDouble().clamp(1.0, double.infinity).toDouble();

    return _ChartCard(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= safeBuckets.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    safeBuckets[i].label,
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < safeBuckets.length; i++)
                  FlSpot(
                    i.toDouble(),
                    safeBuckets[i]
                        .count
                        .toDouble()
                        .clamp(0.0, chartMaxY)
                        .toDouble(),
                  ),
              ],
              isCurved: true,
              color: const Color(0xFF2E7D32),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF2E7D32),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final double height;
  final Widget child;

  const _ChartCard({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}

class _EmptyOnboardingState extends StatelessWidget {
  final VoidCallback onScan;

  const _EmptyOnboardingState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFA5D6A7).withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights_outlined,
                size: 52, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No analytics data yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start scanning leaves to generate AI insights.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.45),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Start Scanning'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Could not load analytics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
              label: const Text('Retry',
                  style: TextStyle(color: Color(0xFF2E7D32))),
            ),
          ],
        ),
      ),
    );
  }
}
