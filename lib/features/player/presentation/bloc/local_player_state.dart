import '../../../music/data/models/local_song_model.dart';

abstract class LocalPlayerState {}

class LocalPlayerInitial extends LocalPlayerState {}
class LocalPlayerLoading extends LocalPlayerState {}

class LocalPlayerLoaded extends LocalPlayerState {
  final List<LocalSongModel> library;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  LocalPlayerLoaded({
    required this.library,
    required this.currentIndex,
    required this.isPlaying,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  LocalSongModel? get currentSong =>
      library.isEmpty ? null : library[currentIndex];

  bool get hasNext => library.length > 1;
  bool get hasPrevious => library.length > 1;
  bool get isEmpty => library.isEmpty;

  LocalPlayerLoaded copyWith({
    List<LocalSongModel>? library,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return LocalPlayerLoaded(
      library: library ?? this.library,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class LocalPlayerError extends LocalPlayerState {
  final String message;
  LocalPlayerError(this.message);
}