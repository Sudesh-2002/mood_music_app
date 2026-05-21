import '../../../../core/constants/mood_constants.dart';

class MoodResult {
  final MoodLabel mood;
  final double confidence; // 0.0 - 1.0
  final Map<MoodLabel, double> allScores;
  final DateTime detectedAt;

  const MoodResult({
    required this.mood,
    required this.confidence,
    required this.allScores,
    required this.detectedAt,
  });

  bool get isReliable => confidence >= 0.50;

  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(0)}%';

  @override
  String toString() =>
      'MoodResult(mood: ${mood.displayName}, confidence: $confidencePercent)';
}