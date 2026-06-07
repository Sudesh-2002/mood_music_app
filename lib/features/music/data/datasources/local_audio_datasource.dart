import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_song_model.dart';

class LocalAudioDataSource {
  static const _libraryKey = 'local_music_library';

  final AudioPlayer _player = AudioPlayer();
  List<LocalSongModel> _library = [];
  int _currentIndex = 0;

  AudioPlayer get player => _player;
  List<LocalSongModel> get library => List.unmodifiable(_library);
  LocalSongModel? get currentSong =>
      _library.isEmpty ? null : _library[_currentIndex];
  int get currentIndex => _currentIndex;

  // Load saved library from SharedPreferences
  Future<void> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_libraryKey);
    if (jsonStr == null) return;
    try {
      final list = jsonDecode(jsonStr) as List;
      _library = list
          .map((e) => LocalSongModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _library = [];
    }
  }

  // Save library to SharedPreferences
  Future<void> _saveLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_library.map((s) => s.toJson()).toList());
    await prefs.setString(_libraryKey, jsonStr);
  }

  // Pick files using file picker
  Future<List<LocalSongModel>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return [];

    final newSongs = result.files
        .where((f) => f.path != null)
        .map((f) => LocalSongModel.fromPath(f.path!))
        .toList();

    // Add only non-duplicates
    for (final song in newSongs) {
      if (!_library.any((s) => s.filePath == song.filePath)) {
        _library.add(song);
      }
    }

    await _saveLibrary();
    return newSongs;
  }

  // Remove a song from library
  Future<void> removeSong(String id) async {
    _library.removeWhere((s) => s.id == id);
    await _saveLibrary();
  }

  // Play a specific song by index.
  // Uses AudioSource.file with a MediaItem tag so just_audio_background
  // can display the song title/artist on the lock screen and in the
  // Android/iOS notification shade.
  Future<void> playAt(int index) async {
    if (index < 0 || index >= _library.length) return;
    _currentIndex = index;
    final song = _library[index];

    await _player.setAudioSource(
      AudioSource.file(
        song.filePath,
        tag: MediaItem(
          id: song.id,
          title: song.title,
          artist: song.artist.isNotEmpty ? song.artist : 'Unknown Artist',
          album: 'Local Library',
          // artwork is optional — add song.artworkUri if available
        ),
      ),
    );
    await _player.play();
  }

  // Play next
  Future<void> playNext() async {
    if (_library.isEmpty) return;
    final next = (_currentIndex + 1) % _library.length;
    await playAt(next);
  }

  // Play previous
  Future<void> playPrevious() async {
    if (_library.isEmpty) return;
    final prev = (_currentIndex - 1 + _library.length) % _library.length;
    await playAt(prev);
  }

  Future<void> togglePause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}