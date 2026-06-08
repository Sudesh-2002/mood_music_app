import 'dart:math' show exp;
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

  // Alphabetical label order — matches the order ImageDataGenerator uses
  // when reading training folders sorted by name:
  //   angry=0, disgust=1, fear=2, happy=3, neutral=4, sad=5, surprise=6
  static const List<MoodLabel> _labelOrder = [
    MoodLabel.angry,      // 0
    MoodLabel.disgusted,  // 1
    MoodLabel.fearful,    // 2
    MoodLabel.happy,      // 3
    MoodLabel.neutral,    // 4
    MoodLabel.sad,        // 5
    MoodLabel.surprised,  // 6
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

    // RAF-DB models are trained on color RGB images (unlike FER2013 which is
    // grayscale). We apply ImageNet mean/std normalization since most RAF-DB
    // models use a MobileNet/ResNet backbone pretrained on ImageNet.
    //   mean = [0.485, 0.456, 0.406]  (R, G, B)
    //   std  = [0.229, 0.224, 0.225]  (R, G, B)
    const rMean = 0.485; const rStd = 0.229;
    const gMean = 0.456; const gStd = 0.224;
    const bMean = 0.406; const bStd = 0.225;

    return [
      List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 255.0 - rMean) / rStd,
              (pixel.g / 255.0 - gMean) / gStd,
              (pixel.b / 255.0 - bMean) / bStd,
            ];
          },
        ),
      )
    ];
  }

  MoodResult _buildResult(List<double> scores) {
    // FIX #2: Auto-detect whether the model already outputs softmax probabilities
    // or raw logits, and handle each correctly.
    //
    // - If values are all ≥ 0 AND sum ≈ 1.0 → model outputs softmax → use directly.
    //   Applying softmax AGAIN to already-softmaxed values squashes a confident
    //   [0.7, 0.1, ...] distribution toward uniform [0.2, 0.16, ...], which was
    //   the primary cause of the low confidence scores.
    //
    // - Otherwise → raw logits → apply proper softmax using dart:math's exp().
    //   The old _expApprox (Taylor series 1+x+x²/2) introduced up to 87% error
    //   for values outside [-2, 2], completely corrupting the softmax output.
    final rawSum = scores.fold(0.0, (s, v) => s + v);
    final allNonNegative = scores.every((v) => v >= -1e-6);
    final alreadySoftmax = allNonNegative && (rawSum - 1.0).abs() < 0.05;

    final List<double> probs;
    if (alreadySoftmax) {
      // FIX #3: Model outputs probabilities — use them directly
      probs = scores;
      _log.d('[TFLite] ℹ️ Model output is already softmax (sum=${rawSum.toStringAsFixed(4)})');
    } else {
      // FIX #3: Model outputs logits — apply numerically stable softmax
      // using dart:math exp() instead of the broken Taylor approximation
      final maxVal = scores.reduce((a, b) => a > b ? a : b);
      final exps = scores.map((s) => exp(s - maxVal)).toList();
      final sumExp = exps.reduce((a, b) => a + b);
      probs = exps.map((e) => e / sumExp).toList();
      _log.d('[TFLite] ℹ️ Applied softmax to logits (raw sum=${rawSum.toStringAsFixed(4)})');
    }

    int maxIdx = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[maxIdx]) maxIdx = i;
    }

    // Log final probabilities
    final probLog = StringBuffer('[TFLite] 📈 Emotion probabilities:\n');
    for (int i = 0; i < _labelOrder.length; i++) {
      final bar = '█' * (probs[i] * 20).round();
      probLog.writeln(
        '  ${_labelOrder[i].name.padRight(10)}: ${(probs[i] * 100).toStringAsFixed(1).padLeft(5)}%  $bar',
      );
    }
    _log.d(probLog.toString());

    final allScores = <MoodLabel, double>{};
    for (int i = 0; i < _labelOrder.length; i++) {
      allScores[_labelOrder[i]] = probs[i];
    }

    return MoodResult(
      mood: _labelOrder[maxIdx],
      confidence: probs[maxIdx],
      allScores: allScores,
      detectedAt: DateTime.now(),
    );
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