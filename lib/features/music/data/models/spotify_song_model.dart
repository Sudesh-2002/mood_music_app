import '../../domain/entities/song.dart';
import '../../../../core/constants/mood_constants.dart';

class SpotifySongModel extends Song {
  final String previewUrl;
  final String spotifyUri;

  const SpotifySongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.thumbnailUrl,
    required this.previewUrl,
    required this.spotifyUri,
  }) : super(
          videoId: '',
          source: MusicSource.spotify,
        );

  factory SpotifySongModel.fromJson(Map<String, dynamic> json) {
    final artists = (json['artists'] as List)
        .map((a) => a['name'] as String)
        .join(', ');

    final images = json['album']['images'] as List;
    final thumbnail = images.isNotEmpty
        ? images[0]['url'] as String
        : '';

    return SpotifySongModel(
      id: json['id'] as String,
      title: json['name'] as String,
      artist: artists,
      thumbnailUrl: thumbnail,
      previewUrl: json['preview_url'] as String? ?? '',
      spotifyUri: json['uri'] as String,
    );
  }
}