abstract class LocalPlayerEvent {}

class LoadLocalLibrary extends LocalPlayerEvent {}
class PickLocalFiles extends LocalPlayerEvent {}
class PlayLocalSong extends LocalPlayerEvent {
  final int index;
  PlayLocalSong(this.index);
}
class PlayLocalNext extends LocalPlayerEvent {}
class PlayLocalPrevious extends LocalPlayerEvent {}
class ToggleLocalPause extends LocalPlayerEvent {}
class LocalSongEnded extends LocalPlayerEvent {}
class RemoveLocalSong extends LocalPlayerEvent {
  final String id;
  RemoveLocalSong(this.id);
}