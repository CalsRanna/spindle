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

  void _scrollToCurrentLine() {
    final lyrics = _lyricsService.currentLyrics.value;
    if (lyrics.isEmpty) return;

    final currentIndex = lyrics.getCurrentLineIndex(widget.position);
    if (currentIndex == _lastHighlightedIndex) return;
    _lastHighlightedIndex = currentIndex;

    if (currentIndex >= 0 && _scrollController.hasClients) {
      final targetOffset = (currentIndex * 56.0) - 100;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = _lyricsService.currentLyrics.watch(context);

    if (lyrics.isEmpty) {
      return const _EmptyLyricsView();
    }

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
