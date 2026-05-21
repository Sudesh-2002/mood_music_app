import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded,
                size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Home — Step 3 coming next',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 18,
                )),
          ],
        ),
      ),
    );
  }
}