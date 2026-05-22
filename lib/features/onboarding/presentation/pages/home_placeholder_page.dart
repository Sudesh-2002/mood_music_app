import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mood_constants.dart';
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

              // Scan Mood button
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

              const SizedBox(height: 32),

              // Quick mood test buttons
              const Center(
                child: Text('Or jump straight to music:',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
              const SizedBox(height: 16),

              // Mood quick-select grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                children: MoodLabel.values.map((mood) {
                  return GestureDetector(
                    onTap: () => context.go('/player', extra: mood),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood.emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            mood.displayName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}