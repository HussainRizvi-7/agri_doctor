/// Plant disease model used across ML results, reference browser, and history.
class Disease {
  final String name;
  final String description;
  final String solution;
  final String iconEmoji;
  final String severity;
  final String color;

  const Disease({
    required this.name,
    required this.description,
    required this.solution,
    required this.iconEmoji,
    required this.severity,
    required this.color,
  });

  /// First actionable line from [solution], for summary cards.
  String get primaryRecommendation {
    for (final line in solution.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('•')) return trimmed.substring(1).trim();
      return trimmed;
    }
    return 'Follow the recommended solutions below.';
  }

  bool get isHealthy => severity == 'None' && name.toLowerCase().contains('healthy');
}
