import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/mood_constants.dart';
import '../models/youtube_song_model.dart';

class YouTubeDataSource {
  final Dio _dio;

  YouTubeDataSource() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.youtubeBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<YouTubeSongModel>> searchByMood(MoodLabel mood) async {
    final queries = MoodToGenre.youtubeQueries[mood] ?? ['chill music'];
    final query = queries[DateTime.now().millisecond % queries.length];

    try {
      final response = await _dio.get('/search', queryParameters: {
        'part': 'snippet',
        'q': '$query official music',
        'type': 'video',
        'videoCategoryId': '10', // Music category
        'maxResults': ApiConstants.maxResults,
        'key': ApiConstants.youtubeApiKey,
        'relevanceLanguage': 'en',
        'safeSearch': 'moderate',
      });

      final items = response.data['items'] as List;
      return items
          .map((item) => YouTubeSongModel.fromJson(item))
          .where((s) => s.videoId.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception('YouTube API error: ${e.message}');
    }
  }

  Future<List<YouTubeSongModel>> searchByQuery(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'videoCategoryId': '10',
        'maxResults': ApiConstants.maxResults,
        'key': ApiConstants.youtubeApiKey,
      });

      final items = response.data['items'] as List;
      return items
          .map((item) => YouTubeSongModel.fromJson(item))
          .where((s) => s.videoId.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception('YouTube search error: ${e.message}');
    }
  }
}