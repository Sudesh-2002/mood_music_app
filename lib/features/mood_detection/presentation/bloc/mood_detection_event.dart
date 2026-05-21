abstract class MoodDetectionEvent {}

class InitializeMoodDetection extends MoodDetectionEvent {}
class StartMoodDetection extends MoodDetectionEvent {}
class StopMoodDetection extends MoodDetectionEvent {}
class CameraFrameCaptured extends MoodDetectionEvent {
  final List<int> imageBytes;
  CameraFrameCaptured(this.imageBytes);
}