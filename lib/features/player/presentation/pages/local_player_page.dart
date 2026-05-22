import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../music/data/datasources/local_audio_datasource.dart';
import '../bloc/local_player_bloc.dart';
import '../bloc/local_player_event.dart';
import '../bloc/local_player_state.dart';

class LocalPlayerPage extends StatefulWidget {
  const LocalPlayerPage({super.key});

  @override
  State<LocalPlayerPage> createState() => _LocalPlayerPageState();
}

class _LocalPlayerPageState extends State<LocalPlayerPage> {
  late final LocalPlayerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = LocalPlayerBloc(LocalAudioDataSource());
    _bloc.add(LoadLocalLibrary());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<LocalPlayerBloc, LocalPlayerState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bgDark,
            appBar: AppBar(
              backgroundColor: AppColors.bgDark,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => context.go('/home'),
              ),
              title: const Text('Local Music',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded,
                      color: AppColors.primary),
                  onPressed: () => _bloc.add(PickLocalFiles()),
                  tooltip: 'Add songs',
                ),
              ],
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(LocalPlayerState state) {
    if (state is LocalPlayerLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is LocalPlayerLoaded) {
      if (state.isEmpty) {
        return _buildEmptyState();
      }
      return Column(
        children: [
          // Mini player at top
          if (state.currentSong != null) _buildMiniPlayer(state),
          // Library list
          Expanded(child: _buildLibrary(state)),
        ],
      );
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off_rounded,
              size: 72, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          const Text('No local music yet',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tap + to add songs from your device',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _bloc.add(PickLocalFiles()),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Songs'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(LocalPlayerLoaded state) {
    final song = state.currentSong!;
    final progress = state.duration.inMilliseconds > 0
        ? state.position.inMilliseconds / state.duration.inMilliseconds
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Album art placeholder
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 2),
                    Text(song.artist,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.bgDark,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(state.position),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              Text(_formatDuration(state.duration),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),

          const SizedBox(height: 8),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: state.hasPrevious
                    ? () => _bloc.add(PlayLocalPrevious())
                    : null,
                icon: Icon(Icons.skip_previous_rounded,
                    size: 32,
                    color: state.hasPrevious
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _bloc.add(ToggleLocalPause()),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: state.hasNext
                    ? () => _bloc.add(PlayLocalNext())
                    : null,
                icon: Icon(Icons.skip_next_rounded,
                    size: 32,
                    color: state.hasNext
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLibrary(LocalPlayerLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: state.library.length,
      itemBuilder: (context, index) {
        final song = state.library[index];
        final isCurrent = index == state.currentIndex;

        return ListTile(
          onTap: () => _bloc.add(PlayLocalSong(index)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCurrent && state.isPlaying
                  ? Icons.equalizer_rounded
                  : Icons.music_note_rounded,
              color: isCurrent ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrent ? AppColors.primary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight:
                  isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () => _bloc.add(RemoveLocalSong(song.id)),
          ),
        );
      },
    );
  }
}