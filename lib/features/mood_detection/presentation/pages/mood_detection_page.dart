import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../data/datasources/camera_datasource.dart';
import '../../data/datasources/tflite_emotion_datasource.dart';
import '../../data/repositories/mood_detection_repository_impl.dart';
import '../../domain/entities/mood_result.dart';
import '../../domain/usecases/detect_mood_usecase.dart';
import '../bloc/mood_detection_bloc.dart';
import '../bloc/mood_detection_event.dart';
import '../bloc/mood_detection_state.dart';
import '../widgets/mood_overlay_widget.dart';
import '../widgets/mood_result_card.dart';
import '../../data/datasources/mood_history_datasource.dart';

class MoodDetectionPage extends StatefulWidget {
  final bool autoNavigate; // true = auto go to player after detection
  const MoodDetectionPage({super.key, this.autoNavigate = true});

  @override
  State<MoodDetectionPage> createState() => _MoodDetectionPageState();
}

class _MoodDetectionPageState extends State<MoodDetectionPage> {
  late final CameraDataSource _cameraSource;
  late final MoodDetectionBloc _bloc;
  Timer? _captureTimer;
  Timer? _fallbackTimer;
  MoodResult? _lastResult;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _cameraSource = CameraDataSource();

    final tflite = TFLiteEmotionDataSource();
    final repo = MoodDetectionRepositoryImpl(tflite);
    final usecase = DetectMoodUseCase(repo);
    _bloc = MoodDetectionBloc(detectMood: usecase);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraSource.initialize();
      _bloc.add(InitializeMoodDetection());
      if (mounted) setState(() {});
      _startCapturing();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _startCapturing() {
    _bloc.add(StartMoodDetection());
    // Capture a frame every 3 seconds for mood analysis
    _captureTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      final file = await _cameraSource.takePicture();
      if (file == null) return;
      final bytes = await file.readAsBytes();
      _bloc.add(CameraFrameCaptured(bytes));
    });

    // Fallback: if confidence never reaches threshold in 15 s,
    // navigate anyway using the best result seen (or neutral).
    _fallbackTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      final mood = _lastResult?.mood ?? MoodLabel.neutral;
      context.go('/player', extra: mood);
    });
  }

  void _onMoodDetected(MoodResult result) async {
    // Don't show result card or save if no face detected
    if (result.noFaceDetected) {
      setState(() => _showResult = false);
      return;
    }

    setState(() {
      _lastResult = result;
      _showResult = true;
    });

    // Save to history only when face is detected
    await MoodHistoryDataSource().saveMood(
      mood: result.mood,
      confidence: result.confidence,
    );

    if (widget.autoNavigate && result.isReliable) {
      _fallbackTimer?.cancel(); // reliable result found — no need for fallback
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/player', extra: result.mood);
        }
      });
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _fallbackTimer?.cancel();
    _bloc.close();
    _cameraSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<MoodDetectionBloc, MoodDetectionState>(
        listener: (context, state) {
          if (state is MoodDetected) _onMoodDetected(state.result);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview
              if (_cameraSource.isInitialized &&
                  _cameraSource.controller != null)
                _buildCameraPreview()
              else
                _buildCameraPlaceholder(),

              // Mood overlay (scanning animation)
              const MoodOverlayWidget(),

              // Top bar
              _buildTopBar(),

              // Bottom result card
              if (_showResult && _lastResult != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: MoodResultCard(result: _lastResult!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraSource.controller!.value.previewSize!.height,
            height: _cameraSource.controller!.value.previewSize!.width,
            child: CameraPreview(_cameraSource.controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: AppColors.bgDark,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Starting camera...',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => context.go('/home'),
              ),
              const Spacer(),
              BlocBuilder<MoodDetectionBloc, MoodDetectionState>(
                builder: (context, state) {
                  final isScanning = state is MoodDetectionReady &&
                      state.isScanning ||
                      state is MoodDetected;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isScanning
                          ? AppColors.primary.withOpacity(0.8)
                          : Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isScanning) ...[
                          const SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          isScanning ? 'Scanning...' : 'Ready',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}