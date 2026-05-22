import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../music/domain/usecases/get_songs_by_mood_usecase.dart';
import '../../../music/data/datasources/youtube_datasource.dart';
import '../../../music/data/repositories/music_repository_impl.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final GetSongsByMoodUseCase getSongsByMood;

  PlayerBloc({required this.getSongsByMood}) : super(PlayerInitial()) {
    on<LoadPlaylistForMood>(_onLoadPlaylist);
    on<PlaySong>(_onPlaySong);
    on<PlayNext>(_onPlayNext);
    on<PlayPrevious>(_onPlayPrevious);
    on<TogglePause>(_onTogglePause);
    on<PlayerEnded>(_onPlayerEnded);
    on<PlayerReady>(_onPlayerReady);
  }

  Future<void> _onLoadPlaylist(
    LoadPlaylistForMood event,
    Emitter<PlayerState> emit,
  ) async {
    emit(PlayerLoading());
    final result = await getSongsByMood(event.mood);
    result.fold(
      (failure) => emit(PlayerError(failure.message)),
      (songs) {
        if (songs.isEmpty) {
          emit(PlayerError('No songs found for this mood'));
          return;
        }
        emit(PlayerLoaded(
          playlist: songs,
          currentIndex: 0,
          isPlaying: true,
          mood: event.mood,
        ));
      },
    );
  }

  void _onPlaySong(PlaySong event, Emitter<PlayerState> emit) {
    final state = this.state;
    if (state is PlayerLoaded) {
      final idx = state.playlist.indexOf(event.song);
      if (idx != -1) {
        emit(state.copyWith(currentIndex: idx, isPlaying: true));
      }
    }
  }

  void _onPlayNext(PlayNext event, Emitter<PlayerState> emit) {
    final state = this.state;
    if (state is PlayerLoaded && state.hasNext) {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        isPlaying: true,
      ));
    }
  }

  void _onPlayPrevious(PlayPrevious event, Emitter<PlayerState> emit) {
    final state = this.state;
    if (state is PlayerLoaded && state.hasPrevious) {
      emit(state.copyWith(
        currentIndex: state.currentIndex - 1,
        isPlaying: true,
      ));
    }
  }

  void _onTogglePause(TogglePause event, Emitter<PlayerState> emit) {
    final state = this.state;
    if (state is PlayerLoaded) {
      emit(state.copyWith(isPlaying: !state.isPlaying));
    }
  }

  void _onPlayerEnded(PlayerEnded event, Emitter<PlayerState> emit) {
    final state = this.state;
    if (state is PlayerLoaded) {
      if (state.hasNext) {
        emit(state.copyWith(
          currentIndex: state.currentIndex + 1,
          isPlaying: true,
        ));
      } else {
        // Restart playlist
        emit(state.copyWith(currentIndex: 0, isPlaying: true));
      }
    }
  }

  void _onPlayerReady(PlayerReady event, Emitter<PlayerState> emit) {
    final state = this.state;
    if (state is PlayerLoaded) {
      emit(state.copyWith(isPlaying: true));
    }
  }

  static PlayerBloc create() {
    final ds = YouTubeDataSource();
    final repo = MusicRepositoryImpl(ds);
    final usecase = GetSongsByMoodUseCase(repo);
    return PlayerBloc(getSongsByMood: usecase);
  }
}