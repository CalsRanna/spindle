import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/metadata_editor/metadata_editor_view_model.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';

@RoutePage()
class DesktopMetadataEditorPage extends StatefulWidget {
  final Song song;

  const DesktopMetadataEditorPage({super.key, required this.song});

  @override
  State<DesktopMetadataEditorPage> createState() => _DesktopMetadataEditorPageState();
}

class _DesktopMetadataEditorPageState extends State<DesktopMetadataEditorPage> {
  final _viewModel = MetadataEditorViewModel();
  
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;
  late final TextEditingController _trackNumberController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;

  @override
  void initState() {
    super.initState();
    _viewModel.init(widget.song);
    
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist ?? '');
    _albumController = TextEditingController(text: widget.song.album ?? '');
    _trackNumberController = TextEditingController(text: widget.song.trackNumber?.toString() ?? '');
    _yearController = TextEditingController(text: widget.song.year?.toString() ?? '');
    _genreController = TextEditingController(text: widget.song.genre ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _trackNumberController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final success = await _viewModel.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metadata saved'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      context.router.maybePop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save metadata'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = _viewModel.isSaving.watch(context);
    final hasChanges = _viewModel.hasChanges.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT METADATA'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.maybePop(),
        ),
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
            TextButton(
              onPressed: hasChanges ? _save : null,
              child: Text(
                'SAVE',
                style: TextStyle(
                  color: hasChanges ? AppTheme.accentColor : AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Album art and file info
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AlbumCover(
                  imagePath: widget.song.albumArtPath,
                  size: 200,
                  borderRadius: 12,
                ),
                const SizedBox(height: 24),
                _buildFileInfo(),
              ],
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            color: AppTheme.dividerColor,
          ),
          
          // Right side - Edit form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Title',
                    controller: _titleController,
                    onChanged: _viewModel.updateTitle,
                    icon: Icons.music_note,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Artist',
                    controller: _artistController,
                    onChanged: _viewModel.updateArtist,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Album',
                    controller: _albumController,
                    onChanged: _viewModel.updateAlbum,
                    icon: Icons.album,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Track Number',
                          controller: _trackNumberController,
                          onChanged: _viewModel.updateTrackNumber,
                          icon: Icons.tag,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Year',
                          controller: _yearController,
                          onChanged: _viewModel.updateYear,
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Genre',
                    controller: _genreController,
                    onChanged: _viewModel.updateGenre,
                    icon: Icons.category,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.accentColor),
        ),
        filled: true,
        fillColor: AppTheme.cardBackground,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildFileInfo() {
    return Card(
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FILE INFO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Duration', widget.song.displayDuration),
            if (widget.song.bitrate != null)
              _buildInfoRow('Bitrate', '${widget.song.bitrate} kbps'),
            if (widget.song.fileSize != null)
              _buildInfoRow('Size', _formatFileSize(widget.song.fileSize!)),
            _buildInfoRow('Path', widget.song.filePath, isPath: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPath = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isPath ? AppTheme.textSecondary : AppTheme.textPrimary,
              ),
              maxLines: isPath ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
