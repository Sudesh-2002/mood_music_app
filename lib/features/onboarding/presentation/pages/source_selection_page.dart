import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../../../features/auth/data/datasources/local_auth_datasource.dart';
import '../../../../features/auth/data/datasources/registration_temp.dart';

class SourceSelectionPage extends StatefulWidget {
  const SourceSelectionPage({super.key});
  @override
  State<SourceSelectionPage> createState() => _SourceSelectionPageState();
}

class _SourceSelectionPageState extends State<SourceSelectionPage> {
  final Set<MusicSource> _selected = {};
  bool _loading = false;
  String? _error;

  final _sources = [
    _SourceItem(MusicSource.youtube,  Icons.play_circle_fill_rounded,
        Color(0xFFFF0000), 'Free, no login needed'),
    _SourceItem(MusicSource.spotify,  Icons.library_music_rounded,
        Color(0xFF1DB954), 'Requires Spotify account'),
    _SourceItem(MusicSource.local,    Icons.folder_rounded,
        Color(0xFFFFD93D), 'Play from your device'),
  ];

  Future<void> _continue() async {
    if (_selected.isEmpty) {
      setState(() { _error = AppStrings.atLeastOne; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final auth = LocalAuthDataSource();
      await auth.register(
        name: RegistrationTemp().name,
        pin: RegistrationTemp().pin,
        musicSources: _selected.map((s) => s.name).toList(),
      );
      RegistrationTemp().clear(); // clean up after use
      if (mounted) context.go('/permissions');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                AppStrings.chooseSources,
                style:  TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.sourcesSubtitle,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              ..._sources.map((s) => _buildSourceCard(s)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(color: AppColors.secondary)),
              ],
              const SizedBox(height: 100), // ← replaces Spacer()
              ElevatedButton(
                onPressed: _loading ? null : _continue,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text(AppStrings.continueBtn),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard(_SourceItem item) {
    final isSelected = _selected.contains(item.source);
    return GestureDetector(
      onTap: () => setState(() {
        isSelected ? _selected.remove(item.source) : _selected.add(item.source);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withOpacity(0.15)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? item.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.source.displayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16, fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Text(item.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13,
                      )),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isSelected ? item.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? item.color : AppColors.textSecondary,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceItem {
  final MusicSource source;
  final IconData icon;
  final Color color;
  final String subtitle;
  const _SourceItem(this.source, this.icon, this.color, this.subtitle);
}