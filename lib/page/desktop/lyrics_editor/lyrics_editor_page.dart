import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';

import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/lyrics_editor/lyrics_editor_view_model.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/util/app_theme.dart';

@RoutePage()
class DesktopLyricsEditorPage extends StatefulWidget {
  final Song song;

  const DesktopLyricsEditorPage({super.key, required this.song});

  @override
  State<DesktopLyricsEditorPage> createState() => _DesktopLyricsEditorPageState();
}

class _DesktopLyricsEditorPageState extends State<DesktopLyricsEditorPage> {
  final _viewModel = LyricsEditorViewModel();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _audioService = AudioService.instance;

  @override
  void initState() {
    super.initState();
    _viewModel.init(widget.song);

    // Sync text controller with view model
    effect(() {
      if (_textController.text != _viewModel.lyricsText.value) {
        _textController.text = _viewModel.lyricsText.value;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertTimestamp() {
    final cursorPos = _textController.selection.baseOffset;
    if (cursorPos < 0) return;

    final newText = _viewModel.insertTimestamp(_textController.text, cursorPos);
    final timestampLength = _viewModel.getCurrentTimestamp().length;

    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: cursorPos + timestampLength,
    );
    _viewModel.updateText(newText);
  }

  void _insertNewLine() {
    final cursorPos = _textController.selection.baseOffset;
    if (cursorPos < 0) return;

    final timestamp = _viewModel.getCurrentTimestamp();
    final before = _textController.text.substring(0, cursorPos);
    final after = _textController.text.substring(cursorPos);
    final newText = '$before\n$timestamp';

    _textController.text = '$newText$after';
    _textController.selection = TextSelection.collapsed(
      offset: newText.length,
    );
    _viewModel.updateText('$newText$after');
  }

  Future<void> _save() async {
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
    final isSaving = _viewModel.isSaving.watch(context);
    final position = _audioService.position.watch(context);
    final isPlaying = _audioService.isPlaying.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LYRICS EDITOR'),
        actions: [
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
      body: Column(
        children: [
          // Song info bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardBackground,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.song.displayArtist,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Playback controls
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => _audioService.togglePlayPause(),
                ),
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),

          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                _ToolbarButton(
                  icon: Icons.timer,
                  label: 'Insert Time',
                  onPressed: _insertTimestamp,
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.add,
                  label: 'New Line + Time',
                  onPressed: _insertNewLine,
                ),
                const Spacer(),
                Text(
                  'Current: ${_viewModel.getCurrentTimestamp()}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Editor
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                // Ctrl/Cmd + T to insert timestamp
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.keyT &&
                    (HardwareKeyboard.instance.isControlPressed ||
                        HardwareKeyboard.instance.isMetaPressed)) {
                  _insertTimestamp();
                }
              },
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.8,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: 'Enter lyrics in LRC format...\n\n'
                      'Example:\n'
                      '[00:12.34]First line of lyrics\n'
                      '[00:15.67]Second line of lyrics',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                ),
                onChanged: _viewModel.updateText,
              ),
            ),
          ),

          // Help text
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.cardBackground,
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Text(
                  'Tip: Use Ctrl+T (Cmd+T on Mac) to insert timestamp at cursor',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final centis = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textPrimary,
        backgroundColor: AppTheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
