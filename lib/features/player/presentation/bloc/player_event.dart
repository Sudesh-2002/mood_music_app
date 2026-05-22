import '../../../music/domain/entities/song.dart';
import '../../../../../core/constants/mood_constants.dart';

abstract class PlayerEvent {}

class LoadPlaylistForMood extends PlayerEvent {
  final MoodLabel mood;
  LoadPlaylistForMood(this.mood);
}

class PlaySong extends PlayerEvent {
  final Song song;
  PlaySong(this.song);
}

class PlayNext extends PlayerEvent {}
class PlayPrevious extends PlayerEvent {}
class TogglePause extends PlayerEvent {}
class SeekTo extends PlayerEvent {
  final Duration position;
  SeekTo(this.position);
}

class PlayerReady extends PlayerEvent {}
class PlayerEnded extends PlayerEvent {}