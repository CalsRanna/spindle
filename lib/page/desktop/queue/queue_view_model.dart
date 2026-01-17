import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/service/audio_service.dart';

class QueueViewModel {
  final _audioService = AudioService.instance;

  Signal<List<Song>> get queue => _audioService.queue;
  Signal<int> get currentIndex => _audioService.currentIndex;
  Signal get currentSong => _audioService.currentSong;

  void playSongAt(int index) {
    final q = queue.value;
    if (index >= 0 && index < q.length) {
      _audioService.currentIndex.value = index;
      _audioService.playSong(q[index]);
    }
  }

  void removeFromQueue(int index) {
    _audioService.removeFromQueue(index);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _audioService.reorderQueue(oldIndex, newIndex);
  }

  void clearQueue() {
    _audioService.clearQueue();
  }

  void dispose() {}
}
