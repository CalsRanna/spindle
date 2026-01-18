import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../service/lyrics_service.dart';
import '../util/app_theme.dart';

class LyricsView extends StatefulWidget {
  final Duration position;

  const LyricsView({
    super.key,
    required this.position,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final _lyricsService = LyricsService.instance;
  final _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  int _lastHighlightedIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.position != oldWidget.position) {
      _scrollToCurrentLine();
    }
  }

  GlobalKey _getKeyForIndex(int index) {
    return _itemKeys.putIfAbsent(index, () => GlobalKey());
  }

  void _scrollToCurrentLine() {
    final lyrics = _lyricsService.currentLyrics.value;
    if (lyrics.isEmpty || !lyrics.hasTiming) return;

    final currentIndex = lyrics.getCurrentLineIndex(widget.position);
    if (currentIndex == _lastHighlightedIndex) return;
    _lastHighlightedIndex = currentIndex;

    if (currentIndex >= 0) {
      final key = _itemKeys[currentIndex];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: 0.5, // Center the item in viewport
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final lyrics = _lyricsService.currentLyrics.value;

      if (lyrics.isEmpty) {
        return const _EmptyLyricsView();
      }

      // Static lyrics (no timing)
      if (!lyrics.hasTiming) {
        return _StaticLyricsView(lyrics: lyrics);
      }

      // Timed lyrics with highlighting
      final currentIndex = lyrics.getCurrentLineIndex(widget.position);

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 100),
        itemCount: lyrics.lines.length,
        itemBuilder: (context, index) {
          final line = lyrics.lines[index];
          final isHighlighted = index == currentIndex;
          final isPast = index < currentIndex;

          return Padding(
            key: _getKeyForIndex(index),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isHighlighted ? 22 : 18,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted
                    ? AppTheme.accentColor
                    : isPast
                        ? AppTheme.textSecondary.withValues(alpha: 0.5)
                        : AppTheme.textSecondary,
                height: 1.5,
              ),
              child: Text(
                line.text,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
    });
  }
}

/// Static lyrics view for lyrics without timing information
class _StaticLyricsView extends StatelessWidget {
  final dynamic lyrics;

  const _StaticLyricsView({required this.lyrics});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      itemCount: lyrics.lines.length,
      itemBuilder: (context, index) {
        final line = lyrics.lines[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            line.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyLyricsView extends StatelessWidget {
  const _EmptyLyricsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No lyrics available',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Place a .lrc file with the same name\nas the audio file',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
