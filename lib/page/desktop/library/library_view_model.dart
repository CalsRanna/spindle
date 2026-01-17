import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/repository/song_repository.dart';

class LibraryViewModel {
  final _songRepository = SongRepository();
  final _playerViewModel = GetIt.instance.get<PlayerViewModel>();

  final songs = Signal<List<Song>>([]);
  final recentlyPlayed = Signal<List<Song>>([]);
  final isLoading = Signal<bool>(false);
  final searchQuery = Signal<String>('');

  LibraryViewModel() {
    loadSongs();
  }

  Future<void> loadSongs() async {
    isLoading.value = true;
    try {
      // Clean up invalid songs first (songs with missing files)
      await _songRepository.cleanupInvalidSongs();

      // Get valid songs only
      songs.value = await _songRepository.getAllValid();
      recentlyPlayed.value = await _songRepository.getRecentlyPlayed(limit: 10);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      await loadSongs();
    } else {
      songs.value = await _songRepository.search(query);
    }
  }

  void playAll() {
    if (songs.value.isEmpty) return;
    _playerViewModel.playQueue(songs.value);
  }

  void playSong(Song song) {
    final index = songs.value.indexOf(song);
    if (index >= 0) {
      _playerViewModel.playQueue(songs.value, startIndex: index);
    } else {
      _playerViewModel.playSong(song);
    }
  }

  void playRecentSong(Song song) {
    final allSongs = songs.value;
    final index = allSongs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _playerViewModel.playQueue(allSongs, startIndex: index);
    } else {
      _playerViewModel.playSong(song);
    }
  }

  void addToQueue(Song song) {
    _playerViewModel.addToQueue(song);
  }

  /// Delete a song from the library
  /// If [deleteFile] is true, also delete the file from disk
  Future<void> deleteSong(Song song, {bool deleteFile = false}) async {
    if (song.id == null) return;

    // Delete from database
    await _songRepository.delete(song.id!);

    // Delete file if requested
    if (deleteFile) {
      final file = File(song.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      // Also delete album art if it exists
      if (song.albumArtPath != null) {
        final artFile = File(song.albumArtPath!);
        if (await artFile.exists()) {
          await artFile.delete();
        }
      }
    }

    // Refresh the list
    await loadSongs();
  }

  Signal<Song?> get currentSong => _playerViewModel.currentSong;
}
