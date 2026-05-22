import '../../domain/entities/song.dart';
import '../../../../core/constants/mood_constants.dart';

class YouTubeSongModel extends Song {
  const YouTubeSongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.thumbnailUrl,
    required super.videoId,
    super.mood,
  }) : super(source: MusicSource.youtube);

  factory YouTubeSongModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>;
    final id = json['id'];
    final videoId = id is Map ? id['videoId'] as String : id as String;

    return YouTubeSongModel(
      id: videoId,
      title: snippet['title'] as String,
      artist: snippet['channelTitle'] as String,
      thumbnailUrl: (snippet['thumbnails']['medium']
              ?? snippet['thumbnails']['default'])['url'] as String,
      videoId: videoId,
    );
  }
}