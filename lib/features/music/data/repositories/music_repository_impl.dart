import 'package:dartz/dartz.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/youtube_datasource.dart';

class MusicRepositoryImpl implements MusicRepository {
  final YouTubeDataSource youtubeDataSource;

  MusicRepositoryImpl(this.youtubeDataSource);

  @override
  Future<Either<Failure, List<Song>>> getSongsByMood(MoodLabel mood) async {
    try {
      final songs = await youtubeDataSource.searchByMood(mood);
      return Right(songs);
    } catch (e) {
      return Left(MusicSourceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> searchSongs(String query) async {
    try {
      final songs = await youtubeDataSource.searchByQuery(query);
      return Right(songs);
    } catch (e) {
      return Left(MusicSourceFailure(e.toString()));
    }
  }
}