import '../models/disease.dart';

class ScanResult {
  final String id;
  final String userId;
  final String diseaseName;
  final String diseaseEmoji;
  final String severity;
  final String color;
  final String description;
  final String solution;
  final double confidence;
  final String? localImagePath;
  final String scanSource;
  final DateTime scannedAt;

  const ScanResult({
    required this.id,
    required this.userId,
    required this.diseaseName,
    required this.diseaseEmoji,
    required this.severity,
    required this.color,
    required this.description,
    required this.solution,
    required this.confidence,
    this.localImagePath,
    required this.scanSource,
    required this.scannedAt,
  });

  /// Reconstructs a Disease so ResultScreen can be re-opened from history.
  Disease toDisease() => Disease(
        name: diseaseName,
        description:
            description.isNotEmpty ? description : 'No description available.',
        solution: solution.isNotEmpty ? solution : 'No solution recorded.',
        iconEmoji: diseaseEmoji,
        severity: severity,
        color: color,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'diseaseName': diseaseName,
        'diseaseEmoji': diseaseEmoji,
        'severity': severity,
        'color': color,
        'description': description,
        'solution': solution,
        'confidence': confidence,
        'localImagePath': localImagePath,
        'scanSource': scanSource,
        'scannedAt': scannedAt.millisecondsSinceEpoch,
      };

  factory ScanResult.fromMap(String id, Map<String, dynamic> map) {
    final tsRaw = map['scannedAt'];
    final scannedAt = tsRaw is int
        ? DateTime.fromMillisecondsSinceEpoch(tsRaw)
        : DateTime.now();

    return ScanResult(
      id: id,
      userId: map['userId'] as String? ?? '',
      diseaseName: map['diseaseName'] as String? ?? 'Unknown',
      diseaseEmoji: map['diseaseEmoji'] as String? ?? '🌿',
      severity: map['severity'] as String? ?? 'Unknown',
      color: map['color'] as String? ?? '#2E7D32',
      description: map['description'] as String? ?? '',
      solution: map['solution'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      localImagePath: map['localImagePath'] as String?,
      scanSource: map['scanSource'] as String? ?? 'unknown',
      scannedAt: scannedAt,
    );
  }
}
