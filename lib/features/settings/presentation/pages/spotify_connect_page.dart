import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/music/data/datasources/spotify_auth_datasource.dart';

class SpotifyConnectPage extends StatefulWidget {
  const SpotifyConnectPage({super.key});

  @override
  State<SpotifyConnectPage> createState() => _SpotifyConnectPageState();
}

class _SpotifyConnectPageState extends State<SpotifyConnectPage> {
  final _auth = SpotifyAuthDataSource();
  bool _isConnected = false;
  bool _loading = true;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connected = await _auth.isAuthenticated;
    if (mounted) {
      setState(() {
        _isConnected = connected;
        _loading = false;
      });
    }
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    final tokens = await _auth.authenticate();
    if (mounted) {
      setState(() {
        _isConnected = tokens != null;
        _connecting = false;
      });
      if (tokens != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spotify connected!'),
            backgroundColor: Color(0xFF1DB954),
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await _auth.signOut();
    if (mounted) setState(() => _isConnected = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('Connect Spotify',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF1DB954)))
          : Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Spotify logo area
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.library_music_rounded,
                        color: Color(0xFF1DB954), size: 52),
                  ),

                  const SizedBox(height: 24),
                  const Text('Spotify',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    _isConnected
                        ? 'Your Spotify account is connected'
                        : 'Connect Spotify to play mood-matched music from your library',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 15),
                  ),

                  const SizedBox(height: 48),

                  if (_isConnected) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF1DB954)
                                .withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Color(0xFF1DB954), size: 24),
                          SizedBox(width: 12),
                          Text('Connected',
                              style: TextStyle(
                                color: Color(0xFF1DB954),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _disconnect,
                      child: const Text('Disconnect',
                          style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15)),
                    ),
                  ] else
                    ElevatedButton(
                      onPressed: _connecting ? null : _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                      ),
                      child: _connecting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Text('Connect with Spotify'),
                    ),

                  const Spacer(),

                  // Features list
                  ...[
                    '30M+ songs available',
                    'Mood-matched recommendations',
                    'Audio feature targeting (energy, valence)',
                    'Your personal library access',
                  ].map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                color: Color(0xFF1DB954), size: 18),
                            const SizedBox(width: 10),
                            Text(f,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14)),
                          ],
                        ),
                      )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}