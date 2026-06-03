import 'package:hive/hive.dart';

part 'user_preferences_model.g.dart';

@HiveType(typeId: 1)
class UserPreferencesModel extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool autoPlayOnOpen;

  @HiveField(2)
  bool showMoodHistory;

  @HiveField(3)
  String preferredSource;

  @HiveField(4)
  int moodScanIntervalSeconds;

  UserPreferencesModel({
    this.isDarkMode = true,
    this.autoPlayOnOpen = true,
    this.showMoodHistory = true,
    this.preferredSource = 'youtube',
    this.moodScanIntervalSeconds = 30,
  });
}