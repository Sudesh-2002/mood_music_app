import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/mood_constants.dart';
import '../models/mood_history_model.dart';

class MoodHistoryDataSource {
  static const _boxName = 'mood_history';

  static final MoodHistoryDataSource _instance =
      MoodHistoryDataSource._internal();
  factory MoodHistoryDataSource() => _instance;
  MoodHistoryDataSource._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    Hive.registerAdapter(MoodHistoryModelAdapter());
    await Hive.openBox<MoodHistoryModel>(_boxName);
    _initialized = true;
  }

  Future<void> saveMood({
    required MoodLabel mood,
    required double confidence,
    String? songPlayed,
  }) async {
    final box = Hive.box<MoodHistoryModel>(_boxName);
    final entry = MoodHistoryModel(
      id: const Uuid().v4(),
      moodName: mood.name,
      confidence: confidence,
      detectedAt: DateTime.now(),
      songPlayed: songPlayed,
    );
    await box.put(entry.id, entry);

    if (box.length > 100) {
      final keys = box.keys.toList();
      await box.delete(keys.first);
    }
  }

  List<MoodHistoryModel> getHistory({int limit = 50}) {
    final box = Hive.box<MoodHistoryModel>(_boxName);
    final all = box.values.toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return all.take(limit).toList();
  }

  Map<MoodLabel, int> getMoodCounts() {
    final box = Hive.box<MoodHistoryModel>(_boxName);
    final counts = <MoodLabel, int>{};
    for (final m in MoodLabel.values) counts[m] = 0;
    for (final entry in box.values) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> clearHistory() async {
    final box = Hive.box<MoodHistoryModel>(_boxName);
    await box.clear();
  }
}