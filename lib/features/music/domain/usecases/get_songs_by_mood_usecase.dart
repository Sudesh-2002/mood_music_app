import 'package:dartz/dartz.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song.dart';
import '../repositories/music_repository.dart';

class GetSongsByMoodUseCase {
  final MusicRepository repository;
  GetSongsByMoodUseCase(this.repository);

  Future<Either<Failure, List<Song>>> call(MoodLabel mood) {
    return repository.getSongsByMood(mood);
  }
}