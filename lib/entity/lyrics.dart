/// Represents a single line of lyrics with timestamp
class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({
    required this.timestamp,
    required this.text,
  });

  @override
  String toString() => '[$timestamp] $text';
}

/// Parsed lyrics data
class Lyrics {
  final String? title;
  final String? artist;
  final String? album;
  final List<LyricLine> lines;

  const Lyrics({
    this.title,
    this.artist,
    this.album,
    required this.lines,
  });

  /// Empty lyrics placeholder
  static const empty = Lyrics(lines: []);

  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;

  /// Get current lyric line index based on position
  int getCurrentLineIndex(Duration position) {
    if (lines.isEmpty) return -1;

    for (int i = lines.length - 1; i >= 0; i--) {
      if (position >= lines[i].timestamp) {
        return i;
      }
    }
    return 0;
  }

  /// Parse LRC format lyrics
  static Lyrics parse(String lrcContent) {
    final lines = <LyricLine>[];
    String? title;
    String? artist;
    String? album;

    for (final line in lrcContent.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Parse metadata tags
      if (trimmed.startsWith('[ti:')) {
        title = _extractTag(trimmed);
        continue;
      }
      if (trimmed.startsWith('[ar:')) {
        artist = _extractTag(trimmed);
        continue;
      }
      if (trimmed.startsWith('[al:')) {
        album = _extractTag(trimmed);
        continue;
      }

      // Skip other metadata tags
      if (RegExp(r'^\[[a-z]+:').hasMatch(trimmed)) {
        continue;
      }

      // Parse timestamp lines: [mm:ss.xx] or [mm:ss:xx]
      final regex = RegExp(r'\[(\d{2}):(\d{2})[.:;](\d{2,3})\](.*)');
      final match = regex.firstMatch(trimmed);

      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final millisStr = match.group(3)!;
        // Handle both 2-digit (centiseconds) and 3-digit (milliseconds)
        final millis = millisStr.length == 2
            ? int.parse(millisStr) * 10
            : int.parse(millisStr);
        final text = match.group(4)?.trim() ?? '';

        if (text.isNotEmpty) {
          lines.add(LyricLine(
            timestamp: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: millis,
            ),
            text: text,
          ));
        }
      }
    }

    // Sort by timestamp
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Lyrics(
      title: title,
      artist: artist,
      album: album,
      lines: lines,
    );
  }

  static String? _extractTag(String line) {
    final start = line.indexOf(':');
    final end = line.lastIndexOf(']');
    if (start != -1 && end != -1 && start < end) {
      return line.substring(start + 1, end).trim();
    }
    return null;
  }
}
