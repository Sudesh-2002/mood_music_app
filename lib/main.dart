import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/local_auth_datasource.dart';
import 'features/mood_detection/data/datasources/mood_history_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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