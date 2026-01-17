import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/song_repository.dart';
import 'package:spindle/service/audio_service.dart';

class SearchViewModel {
  final _songRepository = SongRepository();
  final _audioService = AudioService.instance;

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
      _audioService.playQueue(allResults, startIndex: index);
    } else {
      _audioService.playSong(song);
    }
  }

  void dispose() {
    searchQuery.dispose();
    results.dispose();
    isSearching.dispose();
  }
}
