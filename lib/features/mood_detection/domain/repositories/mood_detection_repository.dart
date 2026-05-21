import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/mood_result.dart';

abstract class MoodDetectionRepository {
  Future<Either<Failure, MoodResult>> detectMoodFromFrame(List<int> imageBytes);
  Future<Either<Failure, bool>> initialize();
  void dispose();
}