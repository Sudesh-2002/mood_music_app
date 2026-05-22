import 'package:hive/hive.dart';
import '../../../../core/constants/mood_constants.dart';

part 'mood_history_model.g.dart';

@HiveType(typeId: 2)
class MoodHistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String moodName; // stored as string

  @HiveField(2)
  final double confidence;

  @HiveField(3)
  final DateTime detectedAt;

  @HiveField(4)
  final String? songPlayed;

  MoodHistoryModel({
    required this.id,
    required this.moodName,
    required this.confidence,
    required this.detectedAt,
    this.songPlayed,
  });

  MoodLabel get mood => MoodLabel.values.firstWhere(
        (m) => m.name == moodName,
        orElse: () => MoodLabel.neutral,
      );
}