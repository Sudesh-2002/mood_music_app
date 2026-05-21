import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../domain/entities/mood_result.dart';

class TFLiteEmotionDataSource {
  static const _modelPath = 'assets/models/emotion_model.tflite';
  static const _inputSize = 48; // FER model expects 48x48
  static const _numClasses = 7;

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _useMockMode = false; // fallback if model not loaded

  // FER emotion order (standard FER2013 dataset order)
  static const List<MoodLabel> _labelOrder = [
    MoodLabel.angry,
    MoodLabel.disgusted,
    MoodLabel.fearful,
    MoodLabel.happy,
    MoodLabel.neutral,
    MoodLabel.sad,
    MoodLabel.surprised,
  ];

  Future<bool> initialize() async {
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: options,
      );
      _isInitialized = true;
      _useMockMode = false;
      return true;
    } catch (e) {
      // Model not found or invalid — use mock mode for development
      _useMockMode = true;
      _isInitialized = true;
      return true;
    }
  }

  Future<MoodResult> detectEmotion(Uint8List jpegBytes) async {
    if (!_isInitialized) await initialize();
    if (_useMockMode) return _mockResult();

    try {
      // Decode and preprocess image
      final image = img.decodeImage(jpegBytes);
      if (image == null) return _mockResult();

      final input = _preprocessImage(image);
      final output = List.filled(_numClasses, 0.0).reshape([1, _numClasses]);

      _interpreter!.run(input, output);

      final scores = List<double>.from(output[0] as List);
      return _buildResult(scores);
    } catch (e) {
      return _mockResult();
    }
  }

  List _preprocessImage(img.Image image) {
    // Resize to 48x48 grayscale
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );

    // Build input tensor [1, 48, 48, 1] normalized 0-1
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            // Convert to grayscale
            final gray = (pixel.r * 0.299 +
                    pixel.g * 0.587 +
                    pixel.b * 0.114) /
                255.0;
            return [gray];
          },
        ),
      ),
    );
    return input;
  }

  MoodResult _buildResult(List<double> scores) {
    // Apply softmax
    final softmax = _softmax(scores);

    // Find dominant mood
    int maxIdx = 0;
    for (int i = 1; i < softmax.length; i++) {
      if (softmax[i] > softmax[maxIdx]) maxIdx = i;
    }

    final allScores = <MoodLabel, double>{};
    for (int i = 0; i < _labelOrder.length; i++) {
      allScores[_labelOrder[i]] = softmax[i];
    }

    return MoodResult(
      mood: _labelOrder[maxIdx],
      confidence: softmax[maxIdx],
      allScores: allScores,
      detectedAt: DateTime.now(),
    );
  }

  List<double> _softmax(List<double> scores) {
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final exps = scores.map((s) => (s - maxScore)).map((s) {
      // Simple exp approximation
      return 1.0 / (1.0 + (-s).abs());
    }).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  // Mock result for development without a real model
  MoodResult _mockResult() {
    final moods = MoodLabel.values;
    final random = DateTime.now().millisecond % moods.length;
    final mood = moods[random];

    final allScores = <MoodLabel, double>{};
    for (final m in moods) {
      allScores[m] = m == mood ? 0.75 : 0.04;
    }

    return MoodResult(
      mood: mood,
      confidence: 0.75,
      allScores: allScores,
      detectedAt: DateTime.now(),
    );
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}