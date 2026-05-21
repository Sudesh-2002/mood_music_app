import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/mood_result.dart';
import '../../domain/repositories/mood_detection_repository.dart';
import '../datasources/tflite_emotion_datasource.dart';

class MoodDetectionRepositoryImpl implements MoodDetectionRepository {
  final TFLiteEmotionDataSource dataSource;

  MoodDetectionRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, bool>> initialize() async {
    try {
      final result = await dataSource.initialize();
      return Right(result);
    } catch (e) {
      return Left(ModelFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MoodResult>> detectMoodFromFrame(
      List<int> imageBytes) async {
    try {
      final result =
          await dataSource.detectEmotion(Uint8List.fromList(imageBytes));
      return Right(result);
    } catch (e) {
      return Left(ModelFailure(e.toString()));
    }
  }

  @override
  void dispose() => dataSource.dispose();
}