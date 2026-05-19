import '../models/ml_config.dart';

/// Confidence tier used across scan, result, and history UIs.
enum ConfidenceLevel {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case ConfidenceLevel.high:
        return 'High';
      case ConfidenceLevel.medium:
        return 'Medium';
      case ConfidenceLevel.low:
        return 'Low';
    }
  }

  String get scanMessage {
    switch (this) {
      case ConfidenceLevel.high:
        return 'High confidence detection.';
      case ConfidenceLevel.medium:
        return 'Moderate confidence. Consider a clearer photo if unsure.';
      case ConfidenceLevel.low:
        return 'Low confidence detection. Please use a clearer leaf image.';
    }
  }
}

abstract final class MlConfidence {
  static ConfidenceLevel levelFor(double confidence) {
    if (confidence >= MlConfig.highConfidenceThreshold) {
      return ConfidenceLevel.high;
    }
    if (confidence >= MlConfig.mediumConfidenceThreshold) {
      return ConfidenceLevel.medium;
    }
    return ConfidenceLevel.low;
  }

  static bool isLow(double confidence) =>
      levelFor(confidence) == ConfidenceLevel.low;

  static bool shouldShowAlternatives(double topConfidence) =>
      topConfidence < MlConfig.showAlternativesBelowConfidence;

  static String percentLabel(double confidence) =>
      '${(confidence * 100).toStringAsFixed(1)}%';
}
