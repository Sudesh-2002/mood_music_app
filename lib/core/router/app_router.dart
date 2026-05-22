import 'package:go_router/go_router.dart';
import '../constants/mood_constants.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/login_page.dart';
import '../../features/onboarding/presentation/pages/source_selection_page.dart';
import '../../features/onboarding/presentation/pages/permissions_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/mood_detection/presentation/pages/mood_detection_page.dart';
import '../../features/mood_detection/presentation/pages/mood_history_page.dart';
import '../../features/player/presentation/pages/player_page.dart';
import '../../features/player/presentation/pages/local_player_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
          path: '/splash',
          builder: (c, s) => const SplashPage()),
      GoRoute(
          path: '/welcome',
          builder: (c, s) => const WelcomePage()),
      GoRoute(
          path: '/register',
          builder: (c, s) => const RegisterPage()),
      GoRoute(
          path: '/login',
          builder: (c, s) => const LoginPage()),
      GoRoute(
          path: '/sources',
          builder: (c, s) => const SourceSelectionPage()),
      GoRoute(
          path: '/permissions',
          builder: (c, s) => const PermissionsPage()),
      GoRoute(
          path: '/home',
          builder: (c, s) => const MainShell()),
      GoRoute(
          path: '/mood-scan',
          builder: (c, s) =>
              const MoodDetectionPage(autoNavigate: true)),
      GoRoute(
          path: '/mood-history',
          builder: (c, s) => const MoodHistoryPage()),
      GoRoute(
          path: '/local-player',
          builder: (c, s) => const LocalPlayerPage()),
      GoRoute(
          path: '/settings',
          builder: (c, s) => const SettingsPage()),
      GoRoute(
        path: '/player',
        builder: (c, s) {
          final mood =
              s.extra as MoodLabel? ?? MoodLabel.neutral;
          return PlayerPage(mood: mood);
        },
      ),
    ],
  );
}