import '../../../../core/constants/mood_constants.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String videoId;       // YouTube video ID
  final MusicSource source;
  final Duration? duration;
  final MoodLabel? mood;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.videoId,
    required this.source,
    this.duration,
    this.mood,
  });

  @override
  String toString() => 'Song($title by $artist)';
}