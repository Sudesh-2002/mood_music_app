import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Mood emoji row
              Row(
                children: ['😊','😢','😠','😲','😐']
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(e, style: const TextStyle(fontSize: 32)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              const Text(
                AppStrings.welcomeTitle,
                style: TextStyle(
                  fontSize: 42, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.welcomeSubtitle,
                style: TextStyle(
                  fontSize: 16, color: AppColors.textSecondary, height: 1.6,
                ),
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () => context.go('/register'),
                child: const Text(AppStrings.getStarted),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    AppStrings.alreadyHaveAccount,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}