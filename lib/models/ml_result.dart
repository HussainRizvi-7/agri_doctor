import '../models/disease.dart';
import '../utils/ml_confidence.dart';

/// One ranked prediction from the TFLite model.
class PredictionCandidate {
  final int classIndex;
  final Disease disease;
  final double confidence;
  final String rawLabel;

  const PredictionCandidate({
    required this.classIndex,
    required this.disease,
    required this.confidence,
    required this.rawLabel,
  });

  ConfidenceLevel get confidenceLevel => MlConfidence.levelFor(confidence);
}

/// Full inference result including optional top-[k] alternatives.
class MLResult {
  final Disease disease;
  final double confidence;
  final String rawLabel;
  final int classIndex;
  final bool isBackground;
  final List<PredictionCandidate> topPredictions;

  const MLResult({
    required this.disease,
    required this.confidence,
    required this.rawLabel,
    required this.classIndex,
    required this.topPredictions,
    this.isBackground = false,
  });

  ConfidenceLevel get confidenceLevel => MlConfidence.levelFor(confidence);

  String get confidencePercent => MlConfidence.percentLabel(confidence);

  bool get isLowConfidence => confidenceLevel == ConfidenceLevel.low;

  bool get shouldShowAlternatives =>
      MlConfidence.shouldShowAlternatives(confidence) &&
      !isBackground &&
      topPredictions.length > 1;

  /// Alternates excluding the top-1 class (for UI).
  List<PredictionCandidate> get alternativePredictions =>
      topPredictions.where((p) => p.classIndex != classIndex).take(2).toList();
}
