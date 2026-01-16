import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:signals/signals.dart';

import '../entity/lyrics.dart';
import '../util/logger_util.dart';

class LyricsService {
  static final LyricsService instance = LyricsService._();

  final _logger = LoggerUtil.instance;

  LyricsService._();

  /// Current lyrics for the playing song
  final currentLyrics = Signal<Lyrics>(Lyrics.empty);

  /// Load lyrics for a song file
  Future<void> loadLyrics(String? audioFilePath) async {
    if (audioFilePath == null) {
      currentLyrics.value = Lyrics.empty;
      return;
    }

    final lrcPath = _getLrcPath(audioFilePath);
    _logger.i('Looking for lyrics at: $lrcPath');

    final lrcFile = File(lrcPath);
    if (!await lrcFile.exists()) {
      _logger.i('No lyrics file found');
      currentLyrics.value = Lyrics.empty;
      return;
    }

    try {
      final content = await lrcFile.readAsString();
      final lyrics = Lyrics.parse(content);
      _logger.i('Loaded ${lyrics.lines.length} lyrics lines');
      currentLyrics.value = lyrics;
    } catch (e) {
      _logger.e('Error loading lyrics: $e');
      currentLyrics.value = Lyrics.empty;
    }
  }

  /// Clear current lyrics
  void clearLyrics() {
    currentLyrics.value = Lyrics.empty;
  }

  /// Get LRC file path from audio file path
  String _getLrcPath(String audioPath) {
    final dir = p.dirname(audioPath);
    final baseName = p.basenameWithoutExtension(audioPath);
    return p.join(dir, '$baseName.lrc');
  }
}
