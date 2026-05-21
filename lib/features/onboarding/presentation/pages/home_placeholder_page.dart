import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/data/datasources/local_auth_datasource.dart';

class HomePlaceholderPage extends StatefulWidget {
  const HomePlaceholderPage({super.key});
  @override
  State<HomePlaceholderPage> createState() => _HomePlaceholderPageState();
}

class _HomePlaceholderPageState extends State<HomePlaceholderPage> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await LocalAuthDataSource().getCurrentUser();
    if (mounted && user != null) {
      setState(() => _userName = user.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Hey${_userName.isNotEmpty ? ', $_userName' : ''} 👋',
                style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How are you\nfeeling today?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/mood-scan'),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.face_retouching_natural_rounded,
                            size: 56, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Scan Mood',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'Step 4 — music player coming next',
                  style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}