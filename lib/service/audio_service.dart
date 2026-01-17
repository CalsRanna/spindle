import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/play_history_repository.dart';
import 'package:spindle/repository/song_repository.dart';

enum RepeatMode { off, all, one }

class AudioService {
  static final AudioService instance = AudioService._();

  final _player = AudioPlayer();
  final _songRepository = SongRepository();
  final _historyRepository = PlayHistoryRepository();

  // Signals for reactive state
  final currentSong = Signal<Song?>(null);
  final isPlaying = Signal<bool>(false);
  final position = Signal<Duration>(Duration.zero);
  final duration = Signal<Duration>(Duration.zero);
  final queue = Signal<List<Song>>([]);
  final currentIndex = Signal<int>(0);
  final shuffleMode = Signal<bool>(false);
  final repeatMode = Signal<RepeatMode>(RepeatMode.off);
  final volume = Signal<double>(1.0);

  bool _initialized = false;

  AudioService._() {
    _initListeners();
  }

  /// Initialize audio session for background playback
  Future<void> init() async {
    if (_initialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    // Handle audio interruptions (phone calls, etc.)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        // Audio interrupted
        if (isPlaying.value) {
          pause();
        }
      } else {
        // Interruption ended
        if (event.type == AudioInterruptionType.pause) {
          play();
        }
      }
    });

    // Handle becoming noisy (headphones unplugged)
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });

    _initialized = true;
  }

  void _initListeners() {
    _player.playingStream.listen((playing) {
      isPlaying.value = playing;
    });

    _player.positionStream.listen((pos) {
      position.value = pos;
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        duration.value = dur;
      }
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    });
  }

  Future<void> playSong(Song song) async {
    // Check if file exists
    final file = File(song.filePath);
    if (!await file.exists()) {
      // File doesn't exist, might have been deleted or using invalid temp path
      currentSong.value = null;
      throw Exception('Audio file not found: ${song.filePath}');
    }

    currentSong.value = song;

    // Record play history
    if (song.id != null) {
      await _songRepository.updateLastPlayed(song.id!);
      await _historyRepository.recordPlay(song.id!);
    }

    try {
      await _player.setFilePath(song.filePath);
      await _player.play();
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
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pause();
    } else {
      // If no song is loaded, play a random song from library
      if (currentSong.value == null) {
        await playRandomSong();
      } else {
        await play();
      }
    }
  }

  /// Play a random song from the library
  Future<void> playRandomSong() async {
    final songs = await _songRepository.getAll();
    if (songs.isEmpty) return;

    final randomIndex = DateTime.now().millisecondsSinceEpoch % songs.length;
    final randomSong = songs[randomIndex];
    await playQueue(songs, startIndex: randomIndex);
  }

  Future<void> stop() async {
    await _player.stop();
    currentSong.value = null;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
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

  void _onSongComplete() {
    switch (repeatMode.value) {
      case RepeatMode.one:
        seek(Duration.zero);
        play();
        break;
      case RepeatMode.all:
      case RepeatMode.off:
        next();
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
    await _player.setVolume(volume.value);
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
    _player.dispose();
    currentSong.dispose();
    isPlaying.dispose();
    position.dispose();
    duration.dispose();
    queue.dispose();
    currentIndex.dispose();
    shuffleMode.dispose();
    repeatMode.dispose();
    volume.dispose();
  }
}
