import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../music/domain/entities/song.dart';

class PlaylistWidget extends StatelessWidget {
  final List<Song> songs;
  final int currentIndex;
  final Function(Song) onTap;

  const PlaylistWidget({
    super.key,
    required this.songs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isCurrent = index == currentIndex;
        return ListTile(
          onTap: () => onTap(song),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: song.thumbnailUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 52,
                height: 52,
                color: AppColors.bgCard,
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.textSecondary),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 52,
                height: 52,
                color: AppColors.bgCard,
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.textSecondary),
              ),
            ),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrent ? AppColors.primary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          trailing: isCurrent
              ? const Icon(Icons.equalizer_rounded,
                  color: AppColors.primary, size: 20)
              : null,
        );
      },
    );
  }
}