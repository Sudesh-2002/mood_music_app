import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/detect_mood_usecase.dart';
import '../../data/datasources/tflite_emotion_datasource.dart';
import '../../data/repositories/mood_detection_repository_impl.dart';
import 'mood_detection_event.dart';
import 'mood_detection_state.dart';

class MoodDetectionBloc
    extends Bloc<MoodDetectionEvent, MoodDetectionState> {
  final DetectMoodUseCase detectMood;
  Timer? _scanTimer;
  bool _isProcessing = false;

  MoodDetectionBloc({required this.detectMood})
      : super(MoodDetectionInitial()) {
    on<InitializeMoodDetection>(_onInitialize);
    on<StartMoodDetection>(_onStart);
    on<StopMoodDetection>(_onStop);
    on<CameraFrameCaptured>(_onFrameCaptured);
  }

  Future<void> _onInitialize(
    InitializeMoodDetection event,
    Emitter<MoodDetectionState> emit,
  ) async {
    emit(MoodDetectionLoading());
    final result = await detectMood.repository.initialize();
    result.fold(
      (failure) => emit(MoodDetectionError(failure.message)),
      (_) => emit(MoodDetectionReady()),
    );
  }

  void _onStart(
    StartMoodDetection event,
    Emitter<MoodDetectionState> emit,
  ) {
    emit(MoodDetectionReady(isScanning: true));
  }

  void _onStop(
    StopMoodDetection event,
    Emitter<MoodDetectionState> emit,
  ) {
    _scanTimer?.cancel();
    emit(MoodDetectionReady(isScanning: false));
  }

  Future<void> _onFrameCaptured(
    CameraFrameCaptured event,
    Emitter<MoodDetectionState> emit,
  ) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final result = await detectMood(event.imageBytes);
      result.fold(
        (failure) => emit(MoodDetectionError(failure.message)),
        (moodResult) => emit(MoodDetected(moodResult)),
      );
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    detectMood.repository.dispose();
    return super.close();
  }
}