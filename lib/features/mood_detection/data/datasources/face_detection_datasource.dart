import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class FaceDetectionDataSource {
  late final FaceDetector _detector;
  bool _isInitialized = false;
  bool _isProcessing = false;

  void initialize() {
    if (_isInitialized) return;
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: false,
        minFaceSize: 0.10, // lowered to 10% — more lenient
        performanceMode: FaceDetectorMode.accurate, // more accurate
      ),
    );
    _isInitialized = true;
  }

  /// Main method — saves bytes to temp file then runs ML Kit on the file.
  Future<Uint8List?> detectAndCropFace(Uint8List jpegBytes) async {
    if (!_isInitialized) initialize();
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      // Write JPEG to a temp file — ML Kit works best with file path
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/mlkit_input_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(jpegBytes);

      // Create InputImage from file path
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final faces = await _detector.processImage(inputImage);

      // Clean up temp file
      await tempFile.delete();

      if (faces.isEmpty) return null;

      // Use the largest face found
      final face = faces.reduce((a, b) =>
          _faceArea(a) > _faceArea(b) ? a : b);

      return _cropFace(jpegBytes, face.boundingBox);
    } catch (e) {
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Crops the face region with 20% padding.
  Uint8List? _cropFace(Uint8List jpegBytes, Rect boundingBox) {
    try {
      final image = img.decodeImage(jpegBytes);
      if (image == null) return null;

      final padding = boundingBox.width * 0.2;
      final x =
          (boundingBox.left - padding).clamp(0, image.width - 1).toInt();
      final y =
          (boundingBox.top - padding).clamp(0, image.height - 1).toInt();
      final w = (boundingBox.width + padding * 2)
          .clamp(1, image.width - x)
          .toInt();
      final h = (boundingBox.height + padding * 2)
          .clamp(1, image.height - y)
          .toInt();

      final cropped =
          img.copyCrop(image, x: x, y: y, width: w, height: h);
      return Uint8List.fromList(img.encodeJpg(cropped));
    } catch (e) {
      return null;
    }
  }

  double _faceArea(Face face) =>
      face.boundingBox.width * face.boundingBox.height;

  bool isFaceReliable(Face face) => _faceArea(face) >= 1000;

  void dispose() {
    if (_isInitialized) {
      _detector.close();
      _isInitialized = false;
    }
  }
}