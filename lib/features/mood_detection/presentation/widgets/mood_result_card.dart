import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../domain/entities/mood_result.dart';

class MoodResultCard extends StatelessWidget {
  final MoodResult result;

  const MoodResultCard({super.key, required this.result});

  Color _moodColor(MoodLabel mood) {
    switch (mood) {
      case MoodLabel.happy:     return AppColors.moodHappy;
      case MoodLabel.sad:       return AppColors.moodSad;
      case MoodLabel.angry:     return AppColors.moodAngry;
      case MoodLabel.neutral:   return AppColors.moodNeutral;
      case MoodLabel.surprised: return AppColors.moodSurprised;
      case MoodLabel.fearful:   return AppColors.moodFearful;
      case MoodLabel.disgusted: return AppColors.moodDisgusted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _moodColor(result.mood);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mood emoji + label
          Row(
            children: [
              Text(result.mood.emoji,
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feeling ${result.mood.displayName}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Confidence: ${result.confidencePercent}',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Score bars for all moods
          ...result.allScores.entries.map((entry) {
            final barColor = _moodColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(entry.key.emoji,
                        style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value,
                        backgroundColor: AppColors.bgDark,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(entry.value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),
          Text(
            result.isReliable
                ? 'Finding music for your mood...'
                : 'Hold still for a better read',
            style: TextStyle(
              color: result.isReliable ? color : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}