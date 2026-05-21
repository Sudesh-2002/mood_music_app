import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String pinHash; // SHA-256 hash of PIN

  @HiveField(3)
  final List<String> musicSources; // ['spotify','youtube','local']

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool hasCompletedOnboarding;

  UserModel({
    required this.id,
    required this.name,
    required this.pinHash,
    required this.musicSources,
    required this.createdAt,
    this.hasCompletedOnboarding = false,
  });
}