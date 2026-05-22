import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../../../core/constants/api_constants.dart';

class SpotifyTokens {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  SpotifyTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class SpotifyAuthDataSource {
  static const _accessTokenKey = 'spotify_access_token';
  static const _refreshTokenKey = 'spotify_refresh_token';
  static const _expiresAtKey = 'spotify_expires_at';

  final _storage = const FlutterSecureStorage();
  final _dio = Dio();

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  Future<SpotifyTokens?> authenticate() async {
    try {
      final verifier = _generateCodeVerifier();
      final challenge = _generateCodeChallenge(verifier);
      final state = _generateCodeVerifier().substring(0, 16);

      final authUrl = Uri.parse(
          '${ApiConstants.spotifyAuthUrl}/authorize').replace(
        queryParameters: {
          'client_id': ApiConstants.spotifyClientId,
          'response_type': 'code',
          'redirect_uri': ApiConstants.spotifyRedirectUri,
          'code_challenge_method': 'S256',
          'code_challenge': challenge,
          'state': state,
          'scope': [
            'streaming',
            'user-read-playback-state',
            'user-modify-playback-state',
            'user-read-currently-playing',
            'playlist-read-private',
            'user-library-read',
          ].join(' '),
        },
      );

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'moodmusic',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) return null;

      return await _exchangeCode(code, verifier);
    } catch (e) {
      return null;
    }
  }

  Future<SpotifyTokens?> _exchangeCode(
      String code, String verifier) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.spotifyAuthUrl}/api/token',
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': ApiConstants.spotifyRedirectUri,
          'client_id': ApiConstants.spotifyClientId,
          'code_verifier': verifier,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      final tokens = SpotifyTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        expiresAt: DateTime.now()
            .add(Duration(seconds: response.data['expires_in'])),
      );

      await _saveTokens(tokens);
      return tokens;
    } catch (e) {
      return null;
    }
  }

  Future<SpotifyTokens?> refreshTokens(String refreshToken) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.spotifyAuthUrl}/api/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': ApiConstants.spotifyClientId,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      final tokens = SpotifyTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'] ?? refreshToken,
        expiresAt: DateTime.now()
            .add(Duration(seconds: response.data['expires_in'])),
      );

      await _saveTokens(tokens);
      return tokens;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveTokens(SpotifyTokens tokens) async {
    await _storage.write(
        key: _accessTokenKey, value: tokens.accessToken);
    if (tokens.refreshToken != null) {
      await _storage.write(
          key: _refreshTokenKey, value: tokens.refreshToken);
    }
    await _storage.write(
        key: _expiresAtKey,
        value: tokens.expiresAt.toIso8601String());
  }

  Future<SpotifyTokens?> getSavedTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final expiresAtStr = await _storage.read(key: _expiresAtKey);

    if (accessToken == null || expiresAtStr == null) return null;

    final tokens = SpotifyTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtStr),
    );

    if (tokens.isExpired && refreshToken != null) {
      return await refreshTokens(refreshToken);
    }

    return tokens;
  }

  Future<String?> getValidAccessToken() async {
    final tokens = await getSavedTokens();
    return tokens?.accessToken;
  }

  Future<void> signOut() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
  }

  Future<bool> get isAuthenticated async {
    final token = await getValidAccessToken();
    return token != null;
  }
}