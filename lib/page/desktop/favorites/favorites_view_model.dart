import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/repository/song_repository.dart';

class FavoritesViewModel {
  final _songRepository = SongRepository();
  final _playerViewModel = GetIt.instance.get<PlayerViewModel>();

  /// Callback to notify when favorite status changes
  static void Function()? onFavoriteChanged;

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
    if (index >= 0) {
      _playerViewModel.playQueue(songs.value, startIndex: index);
    } else {
      _playerViewModel.playSong(song);
    }
  }

  void playAll() {
    if (songs.value.isEmpty) return;
    _playerViewModel.playQueue(songs.value);
  }

  void addToQueue(Song song) {
    _playerViewModel.addToQueue(song);
  }

  Signal<Song?> get currentSong => _playerViewModel.currentSong;

  Future<void> toggleFavorite(Song song) async {
    if (song.id == null) return;
    await _songRepository.toggleFavorite(song.id!);
    await loadFavorites();

    // Notify listeners that favorite changed
    onFavoriteChanged?.call();
  }
}
