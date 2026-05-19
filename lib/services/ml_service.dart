import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/disease_database.dart';
import '../models/ml_config.dart';
import '../models/ml_result.dart';

export '../models/ml_result.dart';

// ---------------------------------------------------------------------------
// MLService — singleton TFLite wrapper
// ---------------------------------------------------------------------------
class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isModelLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        MlConfig.modelAssetPath,
        options: InterpreterOptions()..threads = MlConfig.interpreterThreads,
      );

      final raw = await rootBundle.loadString(MlConfig.labelsAssetPath);
      _labels = raw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      _isLoaded = true;
    } catch (_) {
      _isLoaded = false;
    }
  }

  Future<MLResult?> classify(File imageFile) async {
    if (!_isLoaded || _interpreter == null) return null;

    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      decoded = img.bakeOrientation(decoded);

      final resized = img.copyResize(
        decoded,
        width: MlConfig.inputSize,
        height: MlConfig.inputSize,
        interpolation: img.Interpolation.linear,
      );

      final input = _buildInputTensor(resized);
      final output = [List<double>.filled(_labels.length, 0.0)];
      _interpreter!.run(input, output);

      final probs = output[0];
      final topIndices = _topKIndices(probs, MlConfig.topK);
      if (topIndices.isEmpty) return null;

      final topIndex = topIndices.first;
      final topScore = probs[topIndex];

      final predictions = <PredictionCandidate>[];
      for (final index in topIndices) {
        final disease = mlDiseaseMap[index] ??
            mlDiseaseMap[MlConfig.backgroundClassIndex]!;
        predictions.add(
          PredictionCandidate(
            classIndex: index,
            disease: disease,
            confidence: probs[index],
            rawLabel: index < _labels.length ? _labels[index] : 'unknown',
          ),
        );
      }

      final isBackground = topIndex == MlConfig.backgroundClassIndex;
      final rawLabel =
          topIndex < _labels.length ? _labels[topIndex] : 'unknown';
      final disease = mlDiseaseMap[topIndex] ??
          mlDiseaseMap[MlConfig.backgroundClassIndex]!;

      return MLResult(
        disease: disease,
        confidence: topScore,
        rawLabel: rawLabel,
        classIndex: topIndex,
        topPredictions: predictions,
        isBackground: isBackground,
      );
    } catch (_) {
      return null;
    }
  }

  /// Builds `[1, H, W, 3]` float32 tensor using [MlConfig.normalization].
  List<List<List<List<double>>>> _buildInputTensor(img.Image resized) {
    final size = MlConfig.inputSize;
    return List.generate(
      1,
      (_) => List.generate(
        size,
        (y) => List.generate(
          size,
          (x) {
            final pixel = resized.getPixel(x, y);
            return _normalizePixel(pixel);
          },
        ),
      ),
    );
  }

  List<double> _normalizePixel(img.Pixel pixel) {
    switch (MlConfig.normalization) {
      case MlNormalization.zeroToOne:
        return [
          pixel.r / 255.0,
          pixel.g / 255.0,
          pixel.b / 255.0,
        ];
      case MlNormalization.minusOneToOne:
        return [
          (pixel.r / 127.5) - 1.0,
          (pixel.g / 127.5) - 1.0,
          (pixel.b / 127.5) - 1.0,
        ];
    }
  }

  List<int> _topKIndices(List<double> probs, int k) {
    final indices = List<int>.generate(probs.length, (i) => i);
    indices.sort((a, b) => probs[b].compareTo(probs[a]));
    return indices.take(k).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
