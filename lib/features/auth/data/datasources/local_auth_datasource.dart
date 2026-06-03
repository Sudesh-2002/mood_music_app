import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/user_preferences_model.dart';

class LocalAuthDataSource {
  // Singleton
  static final LocalAuthDataSource _instance = LocalAuthDataSource._internal();
  factory LocalAuthDataSource() => _instance;
  LocalAuthDataSource._internal();

  static const _userBox = 'users';
  static const _prefsBox = 'preferences';
  static const _sessionBox = 'session';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(UserPreferencesModelAdapter());
    await Hive.openBox<UserModel>(_userBox);
    await Hive.openBox<UserPreferencesModel>(_prefsBox);
    await Hive.openBox(_sessionBox);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<UserModel> register({
    required String name,
    required String pin,
    required List<String> musicSources,
  }) async {
    final box = Hive.box<UserModel>(_userBox);
    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      pinHash: _hashPin(pin),
      musicSources: musicSources,
      createdAt: DateTime.now(),
      hasCompletedOnboarding: true,
    );
    await box.put(user.id, user);
    await _saveSession(user.id);
    return user;
  }

  Future<UserModel?> signIn({
    required String name,
    required String pin,
  }) async {
    final box = Hive.box<UserModel>(_userBox);
    final pinHash = _hashPin(pin);
    final users = box.values.where(
      (u) =>
          u.name.toLowerCase() == name.toLowerCase() &&
          u.pinHash == pinHash,
    );
    if (users.isEmpty) return null;
    final user = users.first;
    await _saveSession(user.id);
    return user;
  }

  Future<void> _saveSession(String userId) async {
    final box = Hive.box(_sessionBox);
    await box.put('current_user_id', userId);
  }

  Future<UserModel?> getCurrentUser() async {
    final sessionBox = Hive.box(_sessionBox);
    final userId = sessionBox.get('current_user_id');
    if (userId == null) return null;
    final userBox = Hive.box<UserModel>(_userBox);
    return userBox.get(userId);
  }

  Future<void> signOut() async {
    final box = Hive.box(_sessionBox);
    await box.delete('current_user_id');
  }

  Future<void> updateMusicSources(List<String> sources) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final box = Hive.box<UserModel>(_userBox);
    final updated = UserModel(
      id: user.id,
      name: user.name,
      pinHash: user.pinHash,
      musicSources: sources,
      createdAt: user.createdAt,
      hasCompletedOnboarding: user.hasCompletedOnboarding,
    );
    await box.put(user.id, updated);
  }

  Future<bool> get isLoggedIn async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<UserPreferencesModel> getPreferences() async {
    final box = Hive.box<UserPreferencesModel>(_prefsBox);
    return box.get('prefs') ?? UserPreferencesModel();
  }

  Future<void> savePreferences(UserPreferencesModel prefs) async {
    final box = Hive.box<UserPreferencesModel>(_prefsBox);
    await box.put('prefs', prefs);
  }
}