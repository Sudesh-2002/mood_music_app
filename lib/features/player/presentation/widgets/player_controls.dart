import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onPlay;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.hasNext,
    required this.hasPrevious,
    required this.onPlay,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: hasPrevious ? onPrevious : null,
            icon: Icon(
              Icons.skip_previous_rounded,
              size: 36,
              color: hasPrevious ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: hasNext ? onNext : null,
            icon: Icon(
              Icons.skip_next_rounded,
              size: 36,
              color: hasNext ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}