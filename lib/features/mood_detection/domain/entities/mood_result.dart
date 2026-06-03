import '../../../../core/constants/mood_constants.dart';

class MoodResult {
  final MoodLabel mood;
  final double confidence;
  final Map<MoodLabel, double> allScores;
  final DateTime detectedAt;
  final bool noFaceDetected;

  const MoodResult({
    required this.mood,
    required this.confidence,
    required this.allScores,
    required this.detectedAt,
    this.noFaceDetected = false,
  });

  // Only reliable if face detected AND confidence >= 35%
  bool get isReliable => !noFaceDetected && confidence >= 0.35;

  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(0)}%';

  @override
  String toString() =>
      'MoodResult(mood: ${mood.displayName}, confidence: $confidencePercent, noFace: $noFaceDetected)';
}