import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/mood_result.dart';
import '../repositories/mood_detection_repository.dart';

class DetectMoodUseCase {
  final MoodDetectionRepository repository;
  DetectMoodUseCase(this.repository);

  Future<Either<Failure, MoodResult>> call(List<int> imageBytes) {
    return repository.detectMoodFromFrame(imageBytes);
  }
}