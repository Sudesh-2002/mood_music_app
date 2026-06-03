import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../domain/entities/mood_result.dart';
import 'face_detection_datasource.dart';

class TFLiteEmotionDataSource {
  static const _modelPath = 'assets/models/emotion_model.tflite';
  static const _inputSize = 48;
  static const _numClasses = 7;

  static final _log = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _useMockMode = false;

  // FER2013 label order
  static const List<MoodLabel> _labelOrder = [
    MoodLabel.angry,      // 0
    MoodLabel.disgusted,  // 1
    MoodLabel.fearful,    // 2
    MoodLabel.happy,      // 3
    MoodLabel.sad,        // 4
    MoodLabel.surprised,  // 5
    MoodLabel.neutral,    // 6
  ];

  // Face detector instance
  final FaceDetectionDataSource _faceDetector = FaceDetectionDataSource();

  Future<bool> initialize() async {
    _log.i('[TFLite] Initializing emotion model from: $_modelPath');
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: options,
      );
      _interpreter!.allocateTensors();
      _faceDetector.initialize();
      _isInitialized = true;
      _useMockMode = false;
      _log.i('[TFLite] ✅ emotion_model.tflite loaded successfully — REAL MODEL ACTIVE');
      return true;
    } catch (e) {
      _useMockMode = true;
      _isInitialized = true;
      _faceDetector.initialize();
      _log.w(
        '[TFLite] ⚠️ Failed to load emotion_model.tflite — falling back to MOCK MODE\n'
        'Reason: $e',
      );
      return true;
    }
  }

  Future<MoodResult> detectEmotion(Uint8List jpegBytes) async {
    if (!_isInitialized) await initialize();

    _log.d('[TFLite] Running emotion detection | mode: ${_useMockMode ? "MOCK" : "REAL"}');

    final faceBytes = await _faceDetector.detectAndCropFace(jpegBytes);

    if (faceBytes == null) {
      _log.d('[TFLite] 🚫 No face detected in frame');
      return _noFaceResult();
    }

    _log.d('[TFLite] 👤 Face detected — cropped size: ${faceBytes.lengthInBytes} bytes');

    // Run mock or real model on cropped face
    if (_useMockMode) {
      _log.w('[TFLite] ⚠️ Returning MOCK result (real model not loaded)');
      return _mockResult();
    }

    try {
      final image = img.decodeImage(faceBytes);
      if (image == null) {
        _log.e('[TFLite] Failed to decode cropped face image');
        return _noFaceResult();
      }

      final input = _preprocessImage(image);
      final output =
          List.generate(1, (_) => List.filled(_numClasses, 0.0));

      _interpreter!.run(input, output);

      final scores = List<double>.from(output[0]);

      // Log raw scores for all 7 emotion classes
      final scoreLog = StringBuffer('[TFLite] 📊 Raw model scores:\n');
      for (int i = 0; i < _labelOrder.length; i++) {
        scoreLog.writeln('  ${_labelOrder[i].name.padRight(10)}: ${scores[i].toStringAsFixed(4)}');
      }
      _log.d(scoreLog.toString());

      final result = _buildResult(scores);
      _log.i(
        '[TFLite] 🎭 Detected emotion: ${result.mood.name.toUpperCase()} '
        '(confidence: ${(result.confidence * 100).toStringAsFixed(1)}%)',
      );
      return result;
    } catch (e) {
      _log.e('[TFLite] ❌ Inference error — falling back to mock result\nError: $e');
      return _mockResult();
    }
  }

  List _preprocessImage(img.Image image) {
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Convert to grayscale [1, 48, 48, 1] float32 tensor
    return [
      List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            final gray = (pixel.r * 0.299 +
                    pixel.g * 0.587 +
                    pixel.b * 0.114) /
                255.0;
            return [gray];
          },
        ),
      )
    ];
  }

  MoodResult _buildResult(List<double> scores) {
    final maxVal = scores.reduce((a, b) => a > b ? a : b);
    final exps = scores
        .map((s) => _expApprox(s - maxVal))
        .toList();
    final sumExp = exps.reduce((a, b) => a + b);
    final softmax = exps.map((e) => e / sumExp).toList();

    int maxIdx = 0;
    for (int i = 1; i < softmax.length; i++) {
      if (softmax[i] > softmax[maxIdx]) maxIdx = i;
    }

    // Log softmax probabilities
    final softmaxLog = StringBuffer('[TFLite] 📈 Softmax probabilities:\n');
    for (int i = 0; i < _labelOrder.length; i++) {
      final bar = '█' * (softmax[i] * 20).round();
      softmaxLog.writeln(
        '  ${_labelOrder[i].name.padRight(10)}: ${(softmax[i] * 100).toStringAsFixed(1).padLeft(5)}%  $bar',
      );
    }
    _log.d(softmaxLog.toString());

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

  double _expApprox(double x) {
    final clamped = x.clamp(-20.0, 20.0);
    return clamped >= 0
        ? 1.0 + clamped + clamped * clamped / 2
        : 1.0 / (1.0 - clamped + clamped * clamped / 2);
  }

  MoodResult _noFaceResult() {
    final allScores = <MoodLabel, double>{
      for (final m in MoodLabel.values) m: 1.0 / 7,
    };
    return MoodResult(
      mood: MoodLabel.neutral,
      confidence: 0.0,   // 0% confidence = no face
      allScores: allScores,
      detectedAt: DateTime.now(),
      noFaceDetected: true,
    );
  }

  MoodResult _mockResult() {
    final moods = MoodLabel.values;
    final idx = DateTime.now().millisecond % moods.length;
    final mood = moods[idx];
    final allScores = <MoodLabel, double>{
      for (final m in moods) m: m == mood ? 0.75 : 0.04,
    };
    return MoodResult(
      mood: mood,
      confidence: 0.75,
      allScores: allScores,
      detectedAt: DateTime.now(),
    );
  }

  void dispose() {
    _log.i('[TFLite] Disposing interpreter and face detector');
    _interpreter?.close();
    _faceDetector.dispose();
    _isInitialized = false;
  }
}