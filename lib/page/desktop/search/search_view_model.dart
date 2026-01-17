import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/repository/song_repository.dart';

class SearchViewModel {
  final _songRepository = SongRepository();
  final _playerViewModel = GetIt.instance.get<PlayerViewModel>();

  final searchQuery = Signal<String>('');
  final results = Signal<List<Song>>([]);
  final isSearching = Signal<bool>(false);

  Future<void> search(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      results.value = [];
      return;
    }

    isSearching.value = true;
    try {
      results.value = await _songRepository.search(query);
    } finally {
      isSearching.value = false;
    }
  }

  void playSong(Song song) {
    final allResults = results.value;
    final index = allResults.indexOf(song);
    if (index >= 0) {
      _playerViewModel.playQueue(allResults, startIndex: index);
    } else {
      _playerViewModel.playSong(song);
    }
  }

  Signal<Song?> get currentSong => _playerViewModel.currentSong;
}
