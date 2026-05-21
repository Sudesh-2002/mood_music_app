import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/data/datasources/local_auth_datasource.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/login_page.dart';
import '../../features/onboarding/presentation/pages/source_selection_page.dart';
import '../../features/onboarding/presentation/pages/permissions_page.dart';
import '../../features/onboarding/presentation/pages/home_placeholder_page.dart';
import '../../features/mood_detection/presentation/pages/mood_detection_page.dart';

class AppRouter {
  static final _auth = LocalAuthDataSource();

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      return null; // handled per-page
    },
    routes: [
      GoRoute(path: '/splash',    builder: (c, s) => const SplashPage()),
      GoRoute(path: '/welcome',   builder: (c, s) => const WelcomePage()),
      GoRoute(path: '/register',  builder: (c, s) => const RegisterPage()),
      GoRoute(path: '/login',     builder: (c, s) => const LoginPage()),
      GoRoute(path: '/sources',   builder: (c, s) => const SourceSelectionPage()),
      GoRoute(path: '/permissions', builder: (c, s) => const PermissionsPage()),
      GoRoute(path: '/home',      builder: (c, s) => const HomePlaceholderPage()),
      GoRoute(
        path: '/mood-scan',
        builder: (c, s) => const MoodDetectionPage(autoNavigate: true),
      ),
    ],
  );
}