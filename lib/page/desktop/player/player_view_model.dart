import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/song_repository.dart';
import 'package:spindle/service/audio_service.dart';

class PlayerViewModel {
  final _audioService = AudioService.instance;
  final _songRepository = SongRepository();

  // 所有播放状态由 ViewModel 持有
  final currentSong = Signal<Song?>(null);
  final isPlaying = Signal<bool>(false);
  final position = Signal<Duration>(Duration.zero);
  final duration = Signal<Duration>(Duration.zero);
  final queue = Signal<List<Song>>([]);
  final currentIndex = Signal<int>(0);
  final shuffleMode = Signal<bool>(false);
  final repeatMode = Signal<RepeatMode>(RepeatMode.off);
  final volume = Signal<double>(1.0);

  final List<StreamSubscription> _subscriptions = [];

  PlayerViewModel() {
    _initListeners();
  }

  void _initListeners() {
    // 监听播放状态流
    _subscriptions.add(_audioService.playingStream.listen((playing) {
      isPlaying.value = playing;
      _updatePlaybackState();
    }));

    // 监听播放位置流
    _subscriptions.add(_audioService.positionStream.listen((pos) {
      position.value = pos;
      _updatePlaybackState();
    }));

    // 监听时长流
    _subscriptions.add(_audioService.durationStream.listen((dur) {
      if (dur != null) {
        duration.value = dur;
        _updateMediaItem();
      }
    }));

    // 监听播放器状态流（用于处理播放完成）
    _subscriptions.add(_audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    }));
  }

  void _updateMediaItem() {
    final song = currentSong.value;
    if (song == null) return;
    _audioService.updateMediaItem(song, duration.value);
  }

  void _updatePlaybackState() {
    _audioService.updatePlaybackState(
      isPlaying: isPlaying.value,
      position: position.value,
      queueIndex: currentIndex.value,
    );
  }

  Future<void> playSong(Song song) async {
    currentSong.value = song;
    _updateMediaItem();

    try {
      await _audioService.playSong(song);
    } catch (e) {
      currentSong.value = null;
      rethrow;
    }
  }

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    queue.value = List.from(songs);
    currentIndex.value = startIndex;

    await playSong(songs[startIndex]);
  }

  Future<void> play() async {
    await _audioService.play();
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pause();
    } else {
      if (currentSong.value == null) {
        await playRandomSong();
      } else {
        await play();
      }
    }
  }

  Future<void> playRandomSong() async {
    final songs = await _audioService.getAllSongs();
    if (songs.isEmpty) return;

    final randomIndex = DateTime.now().millisecondsSinceEpoch % songs.length;
    await playQueue(songs, startIndex: randomIndex);
  }

  Future<void> stop() async {
    await _audioService.stop();
    currentSong.value = null;
  }

  Future<void> seek(Duration pos) async {
    await _audioService.seek(pos);
  }

  Future<void> seekToPercent(double percent) async {
    final dur = duration.value;
    final newPosition = Duration(
      milliseconds: (dur.inMilliseconds * percent).round(),
    );
    await seek(newPosition);
  }

  Future<void> next() async {
    final q = queue.value;
    if (q.isEmpty) return;

    int nextIndex;
    if (shuffleMode.value) {
      nextIndex = DateTime.now().millisecondsSinceEpoch % q.length;
    } else {
      nextIndex = currentIndex.value + 1;
      if (nextIndex >= q.length) {
        if (repeatMode.value == RepeatMode.all) {
          nextIndex = 0;
        } else {
          return;
        }
      }
    }

    currentIndex.value = nextIndex;
    await playSong(q[nextIndex]);
  }

  Future<void> previous() async {
    // If more than 3 seconds into the song, restart it
    if (position.value.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final q = queue.value;
    if (q.isEmpty) return;

    int prevIndex = currentIndex.value - 1;
    if (prevIndex < 0) {
      if (repeatMode.value == RepeatMode.all) {
        prevIndex = q.length - 1;
      } else {
        await seek(Duration.zero);
        return;
      }
    }

    currentIndex.value = prevIndex;
    await playSong(q[prevIndex]);
  }

  Future<void> _onSongComplete() async {
    switch (repeatMode.value) {
      case RepeatMode.one:
        await seek(Duration.zero);
        await play();
        break;
      case RepeatMode.all:
      case RepeatMode.off:
        await next();
        break;
    }
  }

  void toggleShuffle() {
    shuffleMode.value = !shuffleMode.value;
  }

  void cycleRepeatMode() {
    switch (repeatMode.value) {
      case RepeatMode.off:
        repeatMode.value = RepeatMode.all;
        break;
      case RepeatMode.all:
        repeatMode.value = RepeatMode.one;
        break;
      case RepeatMode.one:
        repeatMode.value = RepeatMode.off;
        break;
    }
  }

  Future<void> setVolume(double vol) async {
    volume.value = vol.clamp(0.0, 1.0);
    await _audioService.setVolume(volume.value);
  }

  void addToQueue(Song song) {
    final q = List<Song>.from(queue.value);
    q.add(song);
    queue.value = q;
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= queue.value.length) return;

    final q = List<Song>.from(queue.value);
    q.removeAt(index);
    queue.value = q;

    // Adjust current index if necessary
    if (index < currentIndex.value) {
      currentIndex.value = currentIndex.value - 1;
    } else if (index == currentIndex.value && q.isNotEmpty) {
      if (currentIndex.value >= q.length) {
        currentIndex.value = q.length - 1;
      }
      playSong(q[currentIndex.value]);
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    final q = List<Song>.from(queue.value);
    if (newIndex > oldIndex) newIndex--;

    final item = q.removeAt(oldIndex);
    q.insert(newIndex, item);
    queue.value = q;

    // Update current index
    if (oldIndex == currentIndex.value) {
      currentIndex.value = newIndex;
    } else if (oldIndex < currentIndex.value && newIndex >= currentIndex.value) {
      currentIndex.value = currentIndex.value - 1;
    } else if (oldIndex > currentIndex.value && newIndex <= currentIndex.value) {
      currentIndex.value = currentIndex.value + 1;
    }
  }

  void clearQueue() {
    queue.value = [];
    currentIndex.value = 0;
  }

  Future<void> toggleFavorite() async {
    final song = currentSong.value;
    if (song?.id == null) return;

    await _songRepository.toggleFavorite(song!.id!);

    // Update currentSong with new favorite status
    currentSong.value = song.copyWith(isFavorite: !song.isFavorite);

    // Also update the song in the queue
    final q = queue.value;
    final index = q.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      final updatedQueue = List<Song>.from(q);
      updatedQueue[index] = currentSong.value!;
      queue.value = updatedQueue;
    }
  }

  String get positionText => _formatDuration(position.value);
  String get durationText => _formatDuration(duration.value);

  double get progress {
    if (duration.value.inMilliseconds == 0) return 0;
    return position.value.inMilliseconds / duration.value.inMilliseconds;
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }
}
