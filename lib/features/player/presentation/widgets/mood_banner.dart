import 'package:flutter/material.dart';
import '../../../../../core/constants/mood_constants.dart';

class MoodBanner extends StatelessWidget {
  final MoodLabel mood;
  final Color color;

  const MoodBanner({super.key, required this.mood, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            'Music for your ${mood.displayName} mood',
            style: TextStyle(color: color, fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}