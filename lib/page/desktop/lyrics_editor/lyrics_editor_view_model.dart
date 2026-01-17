import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/service/lyrics_service.dart';
import 'package:spindle/util/logger_util.dart';

/// Represents a single lyrics line with optional timestamp
class LyricsLine {
  final String text;
  final Duration? timestamp;

  LyricsLine({required this.text, this.timestamp});

  LyricsLine copyWith({String? text, Duration? timestamp}) {
    return LyricsLine(
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  String toFormattedString() {
    if (timestamp == null) return text;
    return '${_formatTimestamp(timestamp!)}$text';
  }

  static String _formatTimestamp(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final centiseconds =
        ((duration.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '[$minutes:$seconds.$centiseconds]';
  }
}

class LyricsEditorViewModel {
  final _playerViewModel = GetIt.instance.get<PlayerViewModel>();
  final _lyricsService = LyricsService.instance;
  final _logger = LoggerUtil.instance;

  // Raw lyrics text (for edit mode)
  final lyricsText = Signal<String>('');

  // Parsed lines (for sync mode)
  final lines = Signal<List<LyricsLine>>([]);

  // Current line index being synced
  final currentLineIndex = Signal<int>(0);

  final isSaving = Signal<bool>(false);
  final message = Signal<String?>(null);

  Song? _song;

  // Expose player state for UI
  Signal<Duration> get position => _playerViewModel.position;
  Signal<Duration> get duration => _playerViewModel.duration;
  Signal<bool> get isPlaying => _playerViewModel.isPlaying;

  void togglePlayPause() {
    _playerViewModel.togglePlayPause();
  }

  Future<void> play() async {
    await _playerViewModel.play();
  }

  Future<void> pause() async {
    await _playerViewModel.pause();
  }

  Future<void> seek(Duration position) async {
    await _playerViewModel.seek(position);
  }

  void seekToPercent(double percent) {
    _playerViewModel.seekToPercent(percent);
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
      lyricsText.value = '';
    }
  }

  String _getLrcPath(String audioPath) {
    final dir = p.dirname(audioPath);
    final baseName = p.basenameWithoutExtension(audioPath);
    return p.join(dir, '$baseName.lrc');
  }

  /// Parse raw text into lines for sync mode
  void parseTextToLines() {
    final text = lyricsText.value;
    final rawLines = text.split('\n');
    final parsedLines = <LyricsLine>[];

    for (final line in rawLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Skip metadata lines
      if (trimmed.startsWith('[ti:') ||
          trimmed.startsWith('[ar:') ||
          trimmed.startsWith('[al:') ||
          trimmed.startsWith('[by:') ||
          trimmed.startsWith('[offset:')) {
        continue;
      }

      // Parse existing timestamp if present
      final match = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2})\](.*)$').firstMatch(trimmed);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final centis = int.parse(match.group(3)!);
        final content = match.group(4)!;

        if (content.trim().isNotEmpty) {
          parsedLines.add(LyricsLine(
            text: content,
            timestamp: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: centis * 10,
            ),
          ));
        }
      } else {
        // No timestamp
        parsedLines.add(LyricsLine(text: trimmed));
      }
    }

    lines.value = parsedLines;
    currentLineIndex.value = 0;
  }

  /// Set timestamp for a specific line
  void setTimestampForLine(int index) {
    if (index < 0 || index >= lines.value.length) return;

    final currentPos = _playerViewModel.position.value;
    final updatedLines = List<LyricsLine>.from(lines.value);
    updatedLines[index] = updatedLines[index].copyWith(timestamp: currentPos);
    lines.value = updatedLines;

    // Auto-advance to next line
    if (index < lines.value.length - 1) {
      currentLineIndex.value = index + 1;
    }
  }

  /// Select a line for re-syncing
  void selectLine(int index) {
    if (index < 0 || index >= lines.value.length) return;
    currentLineIndex.value = index;
  }

  /// Clear timestamp for a line
  void clearTimestampForLine(int index) {
    if (index < 0 || index >= lines.value.length) return;

    final updatedLines = List<LyricsLine>.from(lines.value);
    updatedLines[index] = LyricsLine(text: updatedLines[index].text);
    lines.value = updatedLines;
  }

  /// Convert lines back to LRC format text
  String linesToLrcText() {
    final buffer = StringBuffer();

    // Add metadata
    buffer.writeln('[ti:${_song?.title ?? ''}]');
    buffer.writeln('[ar:${_song?.artist ?? ''}]');
    buffer.writeln('[al:${_song?.album ?? ''}]');
    buffer.writeln();

    // Add lyrics lines
    for (final line in lines.value) {
      buffer.writeln(line.toFormattedString());
    }

    return buffer.toString();
  }

  /// Apply synced lines back to text
  void applyLinesToText() {
    lyricsText.value = linesToLrcText();
  }

  String getCurrentTimestamp() {
    return LyricsLine._formatTimestamp(_playerViewModel.position.value);
  }

  /// Insert timestamp at cursor position (for desktop editor)
  String insertTimestamp(String text, int cursorPosition) {
    final timestamp = getCurrentTimestamp();
    final before = text.substring(0, cursorPosition);
    final after = text.substring(cursorPosition);
    return '$before$timestamp$after';
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
