import '../../../../core/constants/mood_constants.dart';
import '../../domain/entities/mood_result.dart';

abstract class MoodDetectionState {}

class MoodDetectionInitial extends MoodDetectionState {}
class MoodDetectionLoading extends MoodDetectionState {}

class MoodDetectionReady extends MoodDetectionState {
  final bool isScanning;
  MoodDetectionReady({this.isScanning = false});
}

class MoodDetected extends MoodDetectionState {
  final MoodResult result;
  MoodDetected(this.result);
}

class MoodDetectionError extends MoodDetectionState {
  final String message;
  MoodDetectionError(this.message);
}