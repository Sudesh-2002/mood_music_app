import '../../../music/domain/entities/song.dart';
import '../../../../../core/constants/mood_constants.dart';

abstract class PlayerState {}

class PlayerInitial extends PlayerState {}
class PlayerLoading extends PlayerState {}

class PlayerLoaded extends PlayerState {
  final List<Song> playlist;
  final int currentIndex;
  final bool isPlaying;
  final MoodLabel mood;

  PlayerLoaded({
    required this.playlist,
    required this.currentIndex,
    required this.isPlaying,
    required this.mood,
  });

  Song get currentSong => playlist[currentIndex];
  bool get hasNext => currentIndex < playlist.length - 1;
  bool get hasPrevious => currentIndex > 0;

  PlayerLoaded copyWith({
    List<Song>? playlist,
    int? currentIndex,
    bool? isPlaying,
    MoodLabel? mood,
  }) {
    return PlayerLoaded(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      mood: mood ?? this.mood,
    );
  }
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError(this.message);
}