import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../../../features/auth/data/datasources/local_auth_datasource.dart';
import '../../../../features/auth/data/models/user_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserModel? _user;
  Set<MusicSource> _sources = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await LocalAuthDataSource().getCurrentUser();
    if (mounted && user != null) {
      setState(() {
        _user = user;
        _sources = user.musicSources
            .map((s) => MusicSource.values
                .firstWhere((m) => m.name == s,
                    orElse: () => MusicSource.youtube))
            .toSet();
      });
    }
  }

  Future<void> _signOut() async {
    await LocalAuthDataSource().signOut();
    if (mounted) context.go('/welcome');
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Text(title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          )),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon,
            color: iconColor ?? AppColors.textSecondary, size: 22),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12))
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary)
                : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text('Settings',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.name ?? 'User',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Local account',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            // Music sources
            _buildSection('MUSIC SOURCES'),
            ...[
              _sourcesTile(MusicSource.youtube,
                  Icons.play_circle_fill_rounded,
                  const Color(0xFFFF0000)),
              _sourcesTile(MusicSource.spotify,
                  Icons.library_music_rounded,
                  const Color(0xFF1DB954)),
              _sourcesTile(MusicSource.local,
                  Icons.folder_rounded,
                  const Color(0xFFFFD93D)),
            ],

            _buildTile(
              icon: Icons.library_music_rounded,
              title: 'Connect Spotify',
              subtitle: 'Link your Spotify account',
              iconColor: const Color(0xFF1DB954),
              onTap: () => context.go('/spotify-connect'),
            ),

            // App
            _buildSection('APP'),
            _buildTile(
              icon: Icons.history_rounded,
              title: 'Mood History',
              subtitle: 'View your past mood scans',
              onTap: () => context.go('/mood-history'),
            ),
            _buildTile(
              icon: Icons.face_retouching_natural_rounded,
              title: 'Scan Mood Now',
              subtitle: 'Open the mood camera',
              onTap: () => context.go('/mood-scan'),
            ),
            _buildTile(
              icon: Icons.folder_rounded,
              title: 'Local Music',
              subtitle: 'Manage your offline library',
              onTap: () => context.go('/local-player'),
              iconColor: const Color(0xFFFFD93D),
            ),

            // About
            _buildSection('ABOUT'),
            _buildTile(
              icon: Icons.info_outline_rounded,
              title: 'Version',
              subtitle: '1.0.0',
            ),
            _buildTile(
              icon: Icons.psychology_rounded,
              title: 'Emotion Model',
              subtitle: 'FER2013 — 7 emotions',
              iconColor: AppColors.primary,
            ),

            // Sign out
            _buildSection('ACCOUNT'),
            _buildTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              iconColor: AppColors.secondary,
              onTap: _signOut,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sourcesTile(
      MusicSource source, IconData icon, Color color) {
    final isEnabled = _sources.contains(source);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.4) : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(source.displayName,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 15)),
        trailing: Switch(
          value: isEnabled,
          activeColor: color,
          onChanged: (val) async {
            setState(() {
              if (val) {
                _sources.add(source);
              } else {
                _sources.remove(source);
              }
            });
            // Persist the updated sources to Hive immediately
            await LocalAuthDataSource().updateMusicSources(
              _sources.map((s) => s.name).toList(),
            );
          },
        ),
      ),
    );
  }
}