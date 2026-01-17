import 'package:signals/signals.dart';
import 'package:spindle/service/audio_service.dart';

class PlayerViewModel {
  final _audioService = AudioService.instance;

  Signal<bool> get isPlaying => _audioService.isPlaying;
  Signal get currentSong => _audioService.currentSong;
  Signal<Duration> get position => _audioService.position;
  Signal<Duration> get duration => _audioService.duration;
  Signal<bool> get shuffleMode => _audioService.shuffleMode;
  Signal<RepeatMode> get repeatMode => _audioService.repeatMode;

  String get positionText => _audioService.positionText;
  String get durationText => _audioService.durationText;
  double get progress => _audioService.progress;

  void togglePlayPause() => _audioService.togglePlayPause();
  void next() => _audioService.next();
  void previous() => _audioService.previous();
  void toggleShuffle() => _audioService.toggleShuffle();
  void cycleRepeatMode() => _audioService.cycleRepeatMode();
  void seekToPercent(double percent) => _audioService.seekToPercent(percent);

  void dispose() {}
}
