import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';

class QueueViewModel {
  final _playerViewModel = GetIt.instance.get<PlayerViewModel>();

  Signal<List<Song>> get queue => _playerViewModel.queue;
  Signal<int> get currentIndex => _playerViewModel.currentIndex;
  Signal<Song?> get currentSong => _playerViewModel.currentSong;

  void playSongAt(int index) {
    final q = queue.value;
    if (index >= 0 && index < q.length) {
      _playerViewModel.currentIndex.value = index;
      _playerViewModel.playSong(q[index]);
    }
  }

  void removeFromQueue(int index) {
    _playerViewModel.removeFromQueue(index);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _playerViewModel.reorderQueue(oldIndex, newIndex);
  }

  void clearQueue() {
    _playerViewModel.clearQueue();
  }

  void dispose() {}
}
