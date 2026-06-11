import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../../../features/auth/data/datasources/local_auth_datasource.dart';
import '../../presentation/bloc/player_bloc.dart';
import '../../presentation/bloc/player_event.dart';
import '../../presentation/bloc/player_state.dart';
import '../widgets/mood_banner.dart';
import '../widgets/playlist_widget.dart';
import '../widgets/player_controls.dart';

class PlayerPage extends StatefulWidget {
  final MoodLabel mood;
  const PlayerPage({super.key, required this.mood});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  PlayerBloc? _bloc;
  yt.YoutubePlayerController? _ytController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initBloc();
  }

  /// Reads the user's selected music source from Hive (single value, radio-button model)
  /// and routes to the correct player.
  Future<void> _initBloc() async {
    final user = await LocalAuthDataSource().getCurrentUser();
    final sourceNames = user?.musicSources ?? ['youtube'];

    // Only one source is ever saved now (radio button in settings).
    // Fall back to youtube if list is somehow empty.
    final chosen = sourceNames.isNotEmpty
        ? MusicSource.values.firstWhere(
            (m) => m.name == sourceNames.first,
            orElse: () => MusicSource.youtube,
          )
        : MusicSource.youtube;

    // Local source → redirect to local player page
    if (chosen == MusicSource.local) {
      if (mounted) context.go('/local-player');
      return;
    }

    final bloc = await PlayerBloc.createForSource(chosen);
    if (!mounted) {
      bloc.close();
      return;
    }

    setState(() {
      _bloc = bloc;
      _loading = false;
    });

    _bloc!.add(LoadPlaylistForMood(widget.mood));
  }

  void _initYouTubeController(String videoId) {
    _ytController?.dispose();
    _ytController = yt.YoutubePlayerController(
      initialVideoId: videoId,
      flags: const yt.YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        enableCaption: false,
      ),
    )..addListener(_onPlayerStateChanged);
    setState(() {});
  }

  void _onPlayerStateChanged() {
    if (_ytController == null) return;
    if (_ytController!.value.playerState == yt.PlayerState.ended) {
      _bloc?.add(PlayerEnded());
    }
  }

  @override
  void dispose() {
    _ytController?.removeListener(_onPlayerStateChanged);
    _ytController?.dispose();
    _bloc?.close();
    super.dispose();
  }

  Color _moodColor(MoodLabel mood) {
    switch (mood) {
      case MoodLabel.happy:     return AppColors.moodHappy;
      case MoodLabel.sad:       return AppColors.moodSad;
      case MoodLabel.angry:     return AppColors.moodAngry;
      case MoodLabel.neutral:   return AppColors.moodNeutral;
      case MoodLabel.surprised: return AppColors.moodSurprised;
      case MoodLabel.fearful:   return AppColors.moodFearful;
      case MoodLabel.disgusted: return AppColors.moodDisgusted;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while resolving music source
    if (_loading || _bloc == null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Setting up your music...',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _bloc!,
      child: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerLoaded) {
            final videoId = state.currentSong.videoId;
            // Only init YouTube player for YouTube songs (videoId non-empty)
            if (videoId.isNotEmpty) {
              if (_ytController == null) {
                _initYouTubeController(videoId);
              } else if (_ytController!.initialVideoId != videoId) {
                _ytController!.load(videoId);
              }
              if (state.isPlaying) {
                _ytController?.play();
              } else {
                _ytController?.pause();
              }
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context, state),
                  _buildYouTubePlayer(state),

                  if (state is PlayerLoaded) ...[
                    MoodBanner(
                        mood: state.mood,
                        color: _moodColor(state.mood)),
                    _buildSongInfo(state),
                    PlayerControls(
                      isPlaying: state.isPlaying,
                      hasNext: state.hasNext,
                      hasPrevious: state.hasPrevious,
                      onPlay: () => _bloc!.add(TogglePause()),
                      onNext: () => _bloc!.add(PlayNext()),
                      onPrevious: () => _bloc!.add(PlayPrevious()),
                    ),
                    const Divider(color: AppColors.bgCard),
                    Expanded(
                      child: PlaylistWidget(
                        songs: state.playlist,
                        currentIndex: state.currentIndex,
                        onTap: (song) => _bloc!.add(PlaySong(song)),
                      ),
                    ),
                  ],

                  if (state is PlayerLoading)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Finding music for your mood...',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),

                  if (state is PlayerError)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                color: AppColors.textSecondary, size: 48),
                            const SizedBox(height: 16),
                            Text(state.message,
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () =>
                                  _bloc!.add(LoadPlaylistForMood(widget.mood)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PlayerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary),
            onPressed: () => context.go('/home'),
          ),
          const Expanded(
            child: Text('Now Playing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
          IconButton(
            icon: const Icon(Icons.face_retouching_natural_rounded,
                color: AppColors.primary),
            onPressed: () => context.go('/mood-scan'),
            tooltip: 'Re-scan mood',
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubePlayer(PlayerState state) {
    if (_ytController == null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return yt.YoutubePlayer(
      controller: _ytController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: AppColors.primary,
      progressColors: const yt.ProgressBarColors(
        playedColor: AppColors.primary,
        handleColor: AppColors.primary,
      ),
      onReady: () => _bloc?.add(PlayerReady()),
    );
  }

  Widget _buildSongInfo(PlayerLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.currentSong.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.currentSong.artist,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                state.currentSong.source == MusicSource.spotify
                    ? Icons.library_music_rounded
                    : Icons.play_circle_fill_rounded,
                size: 14,
                color: state.currentSong.source == MusicSource.spotify
                    ? const Color(0xFF1DB954)
                    : const Color(0xFFFF0000),
              ),
              const SizedBox(width: 4),
              Text(
                '${state.currentSong.source.displayName}  •  '
                '${state.currentIndex + 1} of ${state.playlist.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}