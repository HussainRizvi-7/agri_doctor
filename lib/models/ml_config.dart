/// Central configuration for the on-device TFLite plant disease model.
///
/// ## Dataset & model assumptions
/// - Trained on PlantVillage-style crops (apple, tomato, corn, etc.).
/// - 39 output classes including index [backgroundClassIndex] for non-leaf images.
/// - Input tensor: `[1, inputSize, inputSize, 3]` float32.
///
/// ## Preprocessing (validated with test_images/diagnose_model.py)
/// - Resize to [inputSize]×[inputSize] (bilinear).
/// - RGB channels normalized with [normalization] (use `zeroToOne`, not MobileNet [-1,1]).
///
/// ## Replacing the model safely
/// 1. Replace `assets/model/model.tflite` and `assets/model/labels.txt`.
/// 2. Update [classCount], [backgroundClassIndex], and [inputSize] if the new model differs.
/// 3. Update `mlDiseaseMap` in `disease_database.dart` so indices match `labels.txt`.
/// 4. Re-run `test_images/diagnose_model.py` to confirm normalization.
/// 5. Do not change UI code — only this file and `ml_service.dart` preprocessing.
library;

/// Pixel normalization applied before inference.
enum MlNormalization {
  /// `pixel / 255.0` — correct for the bundled model.
  zeroToOne,

  /// `(pixel / 127.5) - 1.0` — MobileNet-style; not used by current model.
  minusOneToOne,
}

abstract final class MlConfig {
  // ── Assets ──────────────────────────────────────────────────────────────
  static const String modelAssetPath = 'assets/model/model.tflite';
  static const String labelsAssetPath = 'assets/model/labels.txt';

  // ── Tensor geometry ─────────────────────────────────────────────────────
  static const int inputSize = 200;
  static const int inputChannels = 3;
  static const int classCount = 39;
  static const int backgroundClassIndex = 38;

  // ── Preprocessing ───────────────────────────────────────────────────────
  static const MlNormalization normalization = MlNormalization.zeroToOne;

  // ── Confidence thresholds (0.0–1.0) ─────────────────────────────────────
  static const double highConfidenceThreshold = 0.85;
  static const double mediumConfidenceThreshold = 0.60;

  /// Below this top-1 score, show alternative predictions in the UI.
  static const double showAlternativesBelowConfidence = 0.92;

  /// Number of ranked predictions to compute after inference.
  static const int topK = 3;

  // ── Interpreter ─────────────────────────────────────────────────────────
  static const int interpreterThreads = 2;

  /// Advisory disclaimer shown on detection results.
  static const String aiDisclaimer =
      'AI predictions are advisory and should be verified by agricultural '
      'experts when necessary.';

  /// Tips when no leaf is detected or confidence is low.
  static const List<String> retakePhotoTips = [
    'Use bright, even lighting (natural daylight works best).',
    'Fill the frame with a single leaf on a plain background.',
    'Hold the camera steady to avoid blur.',
    'Avoid shadows, fingers, and non-plant objects in the shot.',
  ];
}
