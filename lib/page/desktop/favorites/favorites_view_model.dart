import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/song_repository.dart';
import 'package:spindle/service/audio_service.dart';

class FavoritesViewModel {
  final _songRepository = SongRepository();
  final _audioService = AudioService.instance;

  final songs = Signal<List<Song>>([]);
  final isLoading = Signal<bool>(false);

  FavoritesViewModel() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      songs.value = await _songRepository.getFavorites();
    } finally {
      isLoading.value = false;
    }
  }

  void playSong(Song song) {
    final index = songs.value.indexOf(song);
    _audioService.playQueue(songs.value, startIndex: index);
  }

  void playAll() {
    if (songs.value.isEmpty) return;
    _audioService.playQueue(songs.value);
  }

  Future<void> toggleFavorite(Song song) async {
    if (song.id == null) return;
    await _songRepository.toggleFavorite(song.id!);
    await loadFavorites();
  }
}
