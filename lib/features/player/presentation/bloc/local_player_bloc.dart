import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../music/data/datasources/local_audio_datasource.dart';
import 'local_player_event.dart';
import 'local_player_state.dart';

class LocalPlayerBloc
    extends Bloc<LocalPlayerEvent, LocalPlayerState> {
  final LocalAudioDataSource _dataSource;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;

  LocalPlayerBloc(this._dataSource) : super(LocalPlayerInitial()) {
    on<LoadLocalLibrary>(_onLoad);
    on<PickLocalFiles>(_onPick);
    on<PlayLocalSong>(_onPlay);
    on<PlayLocalNext>(_onNext);
    on<PlayLocalPrevious>(_onPrevious);
    on<ToggleLocalPause>(_onToggle);
    on<LocalSongEnded>(_onEnded);
    on<RemoveLocalSong>(_onRemove);

    _positionSub = _dataSource.player.positionStream.listen((pos) {
      final s = state;
      if (s is LocalPlayerLoaded) {
        emit(s.copyWith(position: pos));
      }
    });

    _durationSub = _dataSource.player.durationStream.listen((dur) {
      final s = state;
      if (s is LocalPlayerLoaded && dur != null) {
        emit(s.copyWith(duration: dur));
      }
    });

    _playerStateSub =
        _dataSource.player.playerStateStream.listen((ps) {
      if (ps.processingState == ProcessingState.completed) {
        add(LocalSongEnded());
      }
    });
  }

  Future<void> _onLoad(
      LoadLocalLibrary event, Emitter<LocalPlayerState> emit) async {
    emit(LocalPlayerLoading());
    await _dataSource.loadLibrary();
    emit(LocalPlayerLoaded(
      library: _dataSource.library.cast(),
      currentIndex: 0,
      isPlaying: false,
    ));
  }

  Future<void> _onPick(
      PickLocalFiles event, Emitter<LocalPlayerState> emit) async {
    await _dataSource.pickFiles();
    final s = state;
    final idx = s is LocalPlayerLoaded ? s.currentIndex : 0;
    emit(LocalPlayerLoaded(
      library: _dataSource.library.cast(),
      currentIndex: idx,
      isPlaying: s is LocalPlayerLoaded ? s.isPlaying : false,
    ));
  }

  Future<void> _onPlay(
      PlayLocalSong event, Emitter<LocalPlayerState> emit) async {
    await _dataSource.playAt(event.index);
    final s = state;
    if (s is LocalPlayerLoaded) {
      emit(s.copyWith(currentIndex: event.index, isPlaying: true));
    }
  }

  Future<void> _onNext(
      PlayLocalNext event, Emitter<LocalPlayerState> emit) async {
    await _dataSource.playNext();
    final s = state;
    if (s is LocalPlayerLoaded) {
      emit(s.copyWith(
          currentIndex: _dataSource.currentIndex, isPlaying: true));
    }
  }

  Future<void> _onPrevious(
      PlayLocalPrevious event, Emitter<LocalPlayerState> emit) async {
    await _dataSource.playPrevious();
    final s = state;
    if (s is LocalPlayerLoaded) {
      emit(s.copyWith(
          currentIndex: _dataSource.currentIndex, isPlaying: true));
    }
  }

  Future<void> _onToggle(
      ToggleLocalPause event, Emitter<LocalPlayerState> emit) async {
    await _dataSource.togglePause();
    final s = state;
    if (s is LocalPlayerLoaded) {
      emit(s.copyWith(isPlaying: _dataSource.player.playing));
    }
  }

  Future<void> _onEnded(
      LocalSongEnded event, Emitter<LocalPlayerState> emit) async {
    await _dataSource.playNext();
    final s = state;
    if (s is LocalPlayerLoaded) {
      emit(s.copyWith(
          currentIndex: _dataSource.currentIndex, isPlaying: true));
    }
  }

  Future<void> _onRemove(
      RemoveLocalSong event, Emitter<LocalPlayerState> emit) async {
    await _dataSource.removeSong(event.id);
    final s = state;
    if (s is LocalPlayerLoaded) {
      emit(s.copyWith(
        library: _dataSource.library.cast(),
        currentIndex: 0,
        isPlaying: false,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playerStateSub?.cancel();
    await _dataSource.dispose();
    return super.close();
  }
}