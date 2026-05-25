import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraDataSource {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isStreaming = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) throw Exception('No cameras available');

    // Prefer front camera for mood detection
    final front = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) return null;
    if (_controller!.value.isTakingPicture) return null;
    try {
      return await _controller!.takePicture();
    } catch (e) {
      return null;
    }
  }

  void startImageStream(Function(CameraImage) onImage) {
    if (!_isInitialized || _isStreaming) return;
    _controller!.startImageStream(onImage);
    _isStreaming = true;
  }

  Future<void> stopImageStream() async {
    if (!_isStreaming) return;
    await _controller!.stopImageStream();
    _isStreaming = false;
  }

  Future<void> dispose() async {
    await stopImageStream();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}