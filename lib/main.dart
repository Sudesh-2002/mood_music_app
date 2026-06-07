import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/local_auth_datasource.dart';
import 'features/mood_detection/data/datasources/mood_history_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enables background playback + lock-screen media controls.
  // Wrapped in try-catch: a failure here must never block runApp.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.moodmusic.app.audio',
      androidNotificationChannelName: 'Mood Music',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  } catch (e) {
    debugPrint('[Audio] JustAudioBackground init failed (non-fatal): $e');
  }

  await Hive.initFlutter();
  await LocalAuthDataSource().init();
  await MoodHistoryDataSource().init();
  runApp(const MoodMusicApp());
}

class MoodMusicApp extends StatelessWidget {
  const MoodMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoodMusic',
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}