import 'package:dartz/dartz.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song.dart';

abstract class MusicRepository {
  Future<Either<Failure, List<Song>>> getSongsByMood(MoodLabel mood);
  Future<Either<Failure, List<Song>>> searchSongs(String query);
}