import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/service/lyrics_service.dart';
import 'package:spindle/util/logger_util.dart';

class LyricsEditorViewModel {
  final _playerViewModel = GetIt.instance.get<PlayerViewModel>();
  final _lyricsService = LyricsService.instance;
  final _logger = LoggerUtil.instance;

  final lyricsText = Signal<String>('');
  final isSaving = Signal<bool>(false);
  final message = Signal<String?>(null);

  Song? _song;

  // 暴露播放状态供 UI 使用
  Signal<Duration> get position => _playerViewModel.position;
  Signal<bool> get isPlaying => _playerViewModel.isPlaying;

  void togglePlayPause() {
    _playerViewModel.togglePlayPause();
  }

  void init(Song song) {
    _song = song;
    _loadExistingLyrics();
  }

  Future<void> _loadExistingLyrics() async {
    if (_song == null) return;

    final lrcPath = _getLrcPath(_song!.filePath);
    final file = File(lrcPath);

    if (await file.exists()) {
      try {
        lyricsText.value = await file.readAsString();
        _logger.i('Loaded existing lyrics from: $lrcPath');
      } catch (e) {
        _logger.e('Error loading lyrics: $e');
      }
    } else {
      // Create template
      lyricsText.value = '''[ti:${_song!.title}]
[ar:${_song!.artist ?? 'Unknown'}]
[al:${_song!.album ?? 'Unknown'}]

''';
    }
  }

  String _getLrcPath(String audioPath) {
    final dir = p.dirname(audioPath);
    final baseName = p.basenameWithoutExtension(audioPath);
    return p.join(dir, '$baseName.lrc');
  }

  /// Insert timestamp at current cursor position
  String insertTimestamp(String text, int cursorPosition) {
    final pos = _playerViewModel.position.value;
    final timestamp = _formatTimestamp(pos);

    final before = text.substring(0, cursorPosition);
    final after = text.substring(cursorPosition);

    return '$before$timestamp$after';
  }

  String _formatTimestamp(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final centiseconds =
        ((duration.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '[$minutes:$seconds.$centiseconds]';
  }

  String getCurrentTimestamp() {
    return _formatTimestamp(_playerViewModel.position.value);
  }

  Future<bool> save() async {
    if (_song == null) return false;

    isSaving.value = true;
    message.value = null;

    try {
      final lrcPath = _getLrcPath(_song!.filePath);
      final file = File(lrcPath);
      await file.writeAsString(lyricsText.value);

      _logger.i('Saved lyrics to: $lrcPath');
      message.value = 'Lyrics saved successfully';

      // Reload lyrics in service
      await _lyricsService.loadLyrics(_song!.filePath);

      return true;
    } catch (e) {
      _logger.e('Error saving lyrics: $e');
      message.value = 'Error saving: $e';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void updateText(String text) {
    lyricsText.value = text;
  }
}
