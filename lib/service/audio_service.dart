import 'dart:io';

import 'package:audio_service/audio_service.dart' as audio;
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/play_history_repository.dart';
import 'package:spindle/repository/song_repository.dart';

enum RepeatMode { off, all, one }

/// 无状态的音频服务，仅负责音频播放操作和暴露流
/// 所有 UI 状态应由 PlayerViewModel 管理
class AudioService {
  static final AudioService instance = AudioService._();

  final _player = AudioPlayer();
  final _songRepository = SongRepository();
  final _historyRepository = PlayHistoryRepository();

  _SpindleAudioHandler? _audioHandler;
  bool _initialized = false;

  AudioService._();

  // 暴露 just_audio 的原生流
  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // 当前播放器状态的同步访问器
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  /// Initialize audio session for background playback
  Future<void> init() async {
    if (_initialized) return;

    // Initialize audio_service handler
    _audioHandler = await audio.AudioService.init(
      builder: () => _SpindleAudioHandler(this),
      config: const audio.AudioServiceConfig(
        androidNotificationChannelId: 'com.example.spindle.audio',
        androidNotificationChannelName: 'Spindle Audio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
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
        if (_player.playing) {
          pause();
        }
      } else {
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

  void updateMediaItem(Song song, Duration duration) {
    if (_audioHandler == null) return;

    _audioHandler!.setMediaItem(audio.MediaItem(
      id: song.id?.toString() ?? song.filePath,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      duration: duration,
      artUri: song.albumArtPath != null ? Uri.file(song.albumArtPath!) : null,
    ));
  }

  void updatePlaybackState({
    required bool isPlaying,
    required Duration position,
    required int queueIndex,
  }) {
    if (!_initialized || _audioHandler == null) return;

    _audioHandler!.setPlaybackState(audio.PlaybackState(
      controls: [
        audio.MediaControl.skipToPrevious,
        isPlaying ? audio.MediaControl.pause : audio.MediaControl.play,
        audio.MediaControl.skipToNext,
      ],
      systemActions: const {
        audio.MediaAction.seek,
        audio.MediaAction.seekForward,
        audio.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: audio.AudioProcessingState.ready,
      playing: isPlaying,
      updatePosition: position,
      bufferedPosition: Duration.zero,
      speed: 1.0,
      queueIndex: queueIndex,
    ));
  }

  Future<void> playSong(Song song) async {
    // Check if file exists
    final file = File(song.filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: ${song.filePath}');
    }

    // Record play history
    if (song.id != null) {
      await _songRepository.updateLastPlayed(song.id!);
      await _historyRepository.recordPlay(song.id!);
    }

    await _player.setFilePath(song.filePath);
    await _player.play();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Play a random song from the library
  Future<List<Song>> getAllSongs() async {
    return await _songRepository.getAll();
  }

  void dispose() {
    _player.dispose();
  }
}

/// AudioHandler for system media integration
class _SpindleAudioHandler extends audio.BaseAudioHandler
    with audio.SeekHandler, audio.QueueHandler {
  final AudioService _service;

  // 回调函数，由 PlayerViewModel 设置
  void Function()? onPlay;
  void Function()? onPause;
  void Function()? onStop;
  void Function()? onSkipToNext;
  void Function()? onSkipToPrevious;

  _SpindleAudioHandler(this._service);

  void setMediaItem(audio.MediaItem item) {
    mediaItem.add(item);
  }

  void setPlaybackState(audio.PlaybackState state) {
    playbackState.add(state);
  }

  @override
  Future<void> play() async {
    onPlay?.call();
  }

  @override
  Future<void> pause() async {
    onPause?.call();
  }

  @override
  Future<void> stop() async {
    onStop?.call();
  }

  @override
  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    onSkipToNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    onSkipToPrevious?.call();
  }
}
