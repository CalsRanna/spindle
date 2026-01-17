import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/import/import_view_model.dart';
import 'package:spindle/page/desktop/library/library_view_model.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/util/app_theme.dart';

@RoutePage()
class MobileImportPage extends StatefulWidget {
  const MobileImportPage({super.key});

  @override
  State<MobileImportPage> createState() => _MobileImportPageState();
}

class _MobileImportPageState extends State<MobileImportPage> {
  late final ImportViewModel _viewModel;
  late final LibraryViewModel _libraryViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<ImportViewModel>();
    _libraryViewModel = GetIt.instance.get<LibraryViewModel>();
    _viewModel.loadImportedFiles();
  }

  Future<void> _pickAndImportFiles() async {
    final result = await _viewModel.pickAndImportFiles();
    if (result.audioCount > 0 || result.lyricsCount > 0) {
      await _libraryViewModel.refresh();
    }
  }

  Future<void> _deleteFile(String filePath, String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _viewModel.deleteFile(filePath);
      await _libraryViewModel.refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted: $fileName'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final audioFiles = _viewModel.audioFiles.value;
      final lyricsFiles = _viewModel.lyricsFiles.value;
      final isScanning = _viewModel.isScanning.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('FILES'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.wifi),
              tooltip: 'WiFi Transfer',
              onPressed: isScanning
                  ? null
                  : () => context.router.push(const MobileWifiTransferRoute()),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Select Files',
              onPressed: isScanning ? null : _pickAndImportFiles,
            ),
          ],
        ),
        body: isScanning
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.accentColor),
                    SizedBox(height: 16),
                    Text('Importing...', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : audioFiles.isEmpty && lyricsFiles.isEmpty
                ? _buildEmptyState()
                : _buildFileList(audioFiles, lyricsFiles),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'No files imported',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to select files or use WiFi transfer',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickAndImportFiles,
                icon: const Icon(Icons.add),
                label: const Text('Select Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.router.push(const MobileWifiTransferRoute()),
                icon: const Icon(Icons.wifi),
                label: const Text('WiFi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentColor,
                  side: const BorderSide(color: AppTheme.accentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(List<File> audioFiles, List<File> lyricsFiles) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (audioFiles.isNotEmpty) ...[
          _buildSectionHeader('Songs', audioFiles.length),
          ...audioFiles.map((file) => _buildFileItem(file, Icons.music_note)),
        ],
        if (lyricsFiles.isNotEmpty) ...[
          if (audioFiles.isNotEmpty) const SizedBox(height: 16),
          _buildSectionHeader('Lyrics', lyricsFiles.length),
          ...lyricsFiles.map((file) => _buildFileItem(file, Icons.lyrics)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(File file, IconData icon) {
    final fileName = p.basename(file.path);
    final fileSize = _formatFileSize(file.lengthSync());

    return Dismissible(
      key: Key(file.path),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardBackground,
            title: const Text('Delete File'),
            content: Text('Are you sure you want to delete "$fileName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _viewModel.deleteFile(file.path);
        await _libraryViewModel.refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted: $fileName'),
              backgroundColor: AppTheme.accentColor,
            ),
          );
        }
      },
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentColor, size: 20),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          fileSize,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary),
          onPressed: () => _deleteFile(file.path, fileName),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
