import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/lyrics_editor/lyrics_editor_view_model.dart';
import 'package:spindle/util/app_theme.dart';

enum EditorMode { edit, sync }

@RoutePage()
class MobileLyricsEditorPage extends StatefulWidget {
  final Song song;

  const MobileLyricsEditorPage({super.key, required this.song});

  @override
  State<MobileLyricsEditorPage> createState() => _MobileLyricsEditorPageState();
}

class _MobileLyricsEditorPageState extends State<MobileLyricsEditorPage> {
  final _viewModel = LyricsEditorViewModel();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  EditorMode _mode = EditorMode.edit;

  @override
  void initState() {
    super.initState();
    _viewModel.init(widget.song);

    effect(() {
      if (_textController.text != _viewModel.lyricsText.value) {
        _textController.text = _viewModel.lyricsText.value;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _switchToSyncMode() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter lyrics first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _viewModel.updateText(_textController.text);
    _viewModel.parseTextToLines();

    if (_viewModel.lines.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No lyrics lines found'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _mode = EditorMode.sync);
  }

  void _switchToEditMode() {
    _viewModel.applyLinesToText();
    setState(() => _mode = EditorMode.edit);
  }

  Future<void> _save() async {
    if (_mode == EditorMode.sync) {
      _viewModel.applyLinesToText();
    } else {
      _viewModel.updateText(_textController.text);
    }

    final success = await _viewModel.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lyrics saved'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isSaving = _viewModel.isSaving.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(_mode == EditorMode.edit ? 'EDIT LYRICS' : 'SYNC LYRICS'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_mode == EditorMode.sync) {
                _switchToEditMode();
              } else {
                context.router.maybePop();
              }
            },
          ),
          actions: [
            if (_mode == EditorMode.edit)
              TextButton(
                onPressed: _switchToSyncMode,
                child: const Text('SYNC', style: TextStyle(color: AppTheme.accentColor)),
              )
            else
              TextButton(
                onPressed: _switchToEditMode,
                child: const Text('EDIT', style: TextStyle(color: AppTheme.accentColor)),
              ),
            if (isSaving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accentColor,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _save,
                tooltip: 'Save lyrics',
              ),
          ],
        ),
        body: _mode == EditorMode.edit ? _buildEditMode() : _buildSyncMode(),
      );
    });
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        // Song info
        _buildSongInfo(),
        // Hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppTheme.cardBackground,
          width: double.infinity,
          child: const Text(
            'Enter plain lyrics text, one line per sentence.\nTap SYNC to add timestamps.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
        // Editor
        Expanded(
          child: TextField(
            controller: _textController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: 'Lyrics line 1\nLyrics line 2\nLyrics line 3\n...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
            ),
            onChanged: _viewModel.updateText,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncMode() {
    return Watch((context) {
      final lines = _viewModel.lines.value;
      final currentIndex = _viewModel.currentLineIndex.value;
      final position = _viewModel.position.value;
      final duration = _viewModel.duration.value;
      final isPlaying = _viewModel.isPlaying.value;

      return Column(
        children: [
          // Song info with mini player
          _buildSongInfo(),

          // Player controls
          _buildPlayerControls(position, duration, isPlaying),

          // Current timestamp display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppTheme.cardBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Current: ',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                Text(
                  _viewModel.getCurrentTimestamp(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lyrics lines list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                final isCurrentLine = index == currentIndex;
                final hasTimestamp = line.timestamp != null;

                return _buildLyricsLineItem(
                  index: index,
                  line: line,
                  isCurrentLine: isCurrentLine,
                  hasTimestamp: hasTimestamp,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSongInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.cardBackground,
      child: Row(
        children: [
          const Icon(Icons.music_note, color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.song.artist != null)
                  Text(
                    widget.song.artist!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(Duration position, Duration duration, bool isPlaying) {
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.backgroundColor,
      child: Row(
        children: [
          // Time
          Text(
            _formatDuration(position),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),

          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: _viewModel.seekToPercent,
                activeColor: AppTheme.accentColor,
                inactiveColor: AppTheme.dividerColor,
              ),
            ),
          ),

          // Duration
          Text(
            _formatDuration(duration),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(width: 8),

          // Play/Pause button
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 40,
              color: AppTheme.accentColor,
            ),
            onPressed: _viewModel.togglePlayPause,
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsLineItem({
    required int index,
    required LyricsLine line,
    required bool isCurrentLine,
    required bool hasTimestamp,
  }) {
    return GestureDetector(
      onTap: () {
        _viewModel.selectLine(index);
        _scrollToIndex(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentLine
              ? AppTheme.accentColor.withValues(alpha: 0.2)
              : AppTheme.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentLine ? AppTheme.accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Timestamp button - always visible as IconButton
            IconButton(
              icon: Icon(
                hasTimestamp ? Icons.check_circle : Icons.radio_button_unchecked,
                color: hasTimestamp ? AppTheme.accentColor : AppTheme.textSecondary,
                size: 28,
              ),
              onPressed: () {
                _viewModel.setTimestampForLine(index);
                _scrollToIndex(index + 1);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: hasTimestamp ? 'Re-sync timestamp' : 'Set timestamp',
            ),

            const SizedBox(width: 12),

            // Lyrics text and timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.text,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: isCurrentLine ? AppTheme.textPrimary : AppTheme.textPrimary.withValues(alpha: 0.8),
                      fontWeight: isCurrentLine ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (hasTimestamp)
                    Text(
                      _formatTimestamp(line.timestamp!),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppTheme.accentColor.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),

            // Clear button for lines with timestamp
            if (hasTimestamp)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () => _viewModel.clearTimestampForLine(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Clear timestamp',
              ),

            // Index indicator
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrentLine
                    ? AppTheme.accentColor.withValues(alpha: 0.3)
                    : AppTheme.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCurrentLine ? AppTheme.accentColor : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToIndex(int index) {
    if (index < 0 || index >= _viewModel.lines.value.length) return;

    // Estimate item height (padding + content) and scroll
    final targetOffset = index * 72.0;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatTimestamp(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final centis = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }
}
