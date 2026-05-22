import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/mood_constants.dart';
import '../models/spotify_song_model.dart';
import 'spotify_auth_datasource.dart';

class SpotifyDataSource {
  final SpotifyAuthDataSource _auth;
  late final Dio _dio;

  SpotifyDataSource(this._auth) {
    _dio = Dio(BaseOptions(baseUrl: ApiConstants.spotifyBaseUrl));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _auth.getValidAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<List<SpotifySongModel>> getRecommendations(
      MoodLabel mood) async {
    try {
      final seeds = MoodToGenre.spotifySeeds[mood] ?? ['pop'];
      final seedGenres = seeds.take(3).join(',');

      final response = await _dio.get(
        '/recommendations',
        queryParameters: {
          'seed_genres': seedGenres,
          'limit': 20,
          'market': 'US',
          ...MoodAudioFeatures.forMood(mood),
        },
      );

      final tracks = response.data['tracks'] as List;
      return tracks
          .map((t) => SpotifySongModel.fromJson(t))
          .toList();
    } on DioException catch (e) {
      throw Exception('Spotify API error: ${e.message}');
    }
  }

  Future<List<SpotifySongModel>> searchTracks(String query) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'type': 'track',
          'limit': 20,
        },
      );
      final items =
          response.data['tracks']['items'] as List;
      return items
          .map((t) => SpotifySongModel.fromJson(t))
          .toList();
    } on DioException catch (e) {
      throw Exception('Spotify search error: ${e.message}');
    }
  }
}

// Spotify audio feature targets per mood
class MoodAudioFeatures {
  static Map<String, dynamic> forMood(MoodLabel mood) {
    switch (mood) {
      case MoodLabel.happy:
        return {
          'target_valence': 0.8,
          'target_energy': 0.8,
          'target_danceability': 0.7,
          'min_tempo': 100,
        };
      case MoodLabel.sad:
        return {
          'target_valence': 0.2,
          'target_energy': 0.3,
          'target_acousticness': 0.7,
          'max_tempo': 90,
        };
      case MoodLabel.angry:
        return {
          'target_energy': 0.9,
          'target_valence': 0.3,
          'min_loudness': -5.0,
          'min_tempo': 120,
        };
      case MoodLabel.surprised:
        return {
          'target_energy': 0.8,
          'target_danceability': 0.8,
          'target_valence': 0.7,
        };
      case MoodLabel.neutral:
        return {
          'target_valence': 0.5,
          'target_energy': 0.5,
          'target_danceability': 0.5,
        };
      case MoodLabel.fearful:
        return {
          'target_valence': 0.3,
          'target_energy': 0.4,
          'target_acousticness': 0.6,
        };
      case MoodLabel.disgusted:
        return {
          'target_valence': 0.3,
          'target_energy': 0.5,
          'target_acousticness': 0.4,
        };
    }
  }
}