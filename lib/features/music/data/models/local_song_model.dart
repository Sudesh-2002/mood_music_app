import '../../domain/entities/song.dart';
import '../../../../core/constants/mood_constants.dart';

class LocalSongModel extends Song {
  final String filePath;

  const LocalSongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.thumbnailUrl,
    required this.filePath,
  }) : super(
          videoId: '',
          source: MusicSource.local,
        );

  factory LocalSongModel.fromPath(String path) {
    final fileName = path.split('/').last.split('\\').last;
    final nameWithoutExt = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    // Try to parse "Artist - Title" format
    String title = nameWithoutExt;
    String artist = 'Unknown Artist';
    if (nameWithoutExt.contains(' - ')) {
      final parts = nameWithoutExt.split(' - ');
      artist = parts[0].trim();
      title = parts.sublist(1).join(' - ').trim();
    }

    return LocalSongModel(
      id: path.hashCode.toString(),
      title: title,
      artist: artist,
      thumbnailUrl: '',
      filePath: path,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'filePath': filePath,
      };

  factory LocalSongModel.fromJson(Map<String, dynamic> json) {
    return LocalSongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      thumbnailUrl: '',
      filePath: json['filePath'] as String,
    );
  }
}