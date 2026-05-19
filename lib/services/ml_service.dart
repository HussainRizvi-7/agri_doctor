import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/disease.dart';
import '../models/disease_database.dart';

// ---------------------------------------------------------------------------
// MLResult — returned by MLService.classify()
// ---------------------------------------------------------------------------
class MLResult {
  final Disease disease;
  final double confidence; // 0.0–1.0
  final String rawLabel;
  final bool isBackground;

  const MLResult({
    required this.disease,
    required this.confidence,
    required this.rawLabel,
    this.isBackground = false,
  });

  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  bool get isLowConfidence => confidence < 0.60;
}

// ---------------------------------------------------------------------------
// MLService — singleton TFLite wrapper
// ---------------------------------------------------------------------------
class MLService {
  // Singleton so main() loads once and every screen reuses the same instance
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  static const int _inputSize = 200; // model input: [1, 200, 200, 3] confirmed via flatbuffer analysis
  static const int _backgroundLabelIndex = 38;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isModelLoaded => _isLoaded;

  // -------------------------------------------------------------------------
  // loadModel — called once from main() before runApp()
  // -------------------------------------------------------------------------
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/model.tflite',
        options: InterpreterOptions()..threads = 2,
      );

      final raw = await rootBundle.loadString('assets/model/labels.txt');
      _labels = raw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      _isLoaded = true;
    } catch (_) {
      _isLoaded = false;
      // App continues without ML; ScanScreen shows an error on analysis.
    }
  }

  // -------------------------------------------------------------------------
  // classify — runs inference on a single image file
  //
  // Normalization: pixels scaled to [0.0, 1.0].
  // If the model used MobileNetV2's built-in preprocess_input ([-1, 1]),
  // replace the normalization lines with:
  //   (pixel.r / 127.5) - 1.0
  // -------------------------------------------------------------------------
  Future<MLResult?> classify(File imageFile) async {
    if (!_isLoaded || _interpreter == null) return null;

    try {
      // 1 ── Decode image bytes
      final bytes = await imageFile.readAsBytes();
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      // Correct EXIF rotation so camera photos are always upright
      decoded = img.bakeOrientation(decoded);

      // 2 ── Resize to model input dimensions
      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.linear,
      );

      // 3 ── Build input tensor: shape [1, 200, 200, 3], float32 in [0, 1]
      final input = List.generate(
        1,
        (_) => List.generate(
          _inputSize,
          (y) => List.generate(
            _inputSize,
            (x) {
              final pixel = resized.getPixel(x, y);
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            },
          ),
        ),
      );

      // 4 ── Prepare output tensor: shape [1, numLabels]
      final output = [List<double>.filled(_labels.length, 0.0)];

      // 5 ── Run inference (blocking — already on background isolate via compute)
      _interpreter!.run(input, output);

      // 6 ── Find the highest-probability class
      final probs = output[0];
      int topIndex = 0;
      double topScore = 0.0;
      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > topScore) {
          topScore = probs[i];
          topIndex = i;
        }
      }

      // 7 ── Map index → Disease using the full disease database
      final isBackground = topIndex == _backgroundLabelIndex;
      final rawLabel =
          topIndex < _labels.length ? _labels[topIndex] : 'unknown';
      final disease =
          mlDiseaseMap[topIndex] ?? mlDiseaseMap[_backgroundLabelIndex]!;

      return MLResult(
        disease: disease,
        confidence: topScore,
        rawLabel: rawLabel,
        isBackground: isBackground,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
