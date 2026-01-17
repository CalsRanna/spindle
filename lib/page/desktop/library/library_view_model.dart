import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/song_repository.dart';
import 'package:spindle/service/audio_service.dart';

class LibraryViewModel {
  final _songRepository = SongRepository();
  final _audioService = AudioService.instance;

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
    _audioService.playQueue(songs.value);
  }

  void playSong(Song song) {
    final index = songs.value.indexOf(song);
    if (index >= 0) {
      _audioService.playQueue(songs.value, startIndex: index);
    } else {
      _audioService.playSong(song);
    }
  }

  void playRecentSong(Song song) {
    final allSongs = songs.value;
    final index = allSongs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _audioService.playQueue(allSongs, startIndex: index);
    } else {
      _audioService.playSong(song);
    }
  }

  bool isSongPlaying(Song song) {
    final current = _audioService.currentSong.value;
    return current?.id == song.id && _audioService.isPlaying.value;
  }

  Song? get currentPlayingSong => _audioService.currentSong.value;

  void dispose() {
    songs.dispose();
    recentlyPlayed.dispose();
    isLoading.dispose();
    searchQuery.dispose();
  }
}
