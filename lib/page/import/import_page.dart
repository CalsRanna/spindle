import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/import/import_view_model.dart';
import 'package:spindle/util/app_theme.dart';

@RoutePage()
class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  late final ImportViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<ImportViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final folders = _viewModel.folders.watch(context);
    final isScanning = _viewModel.isScanning.watch(context);
    final scanProgress = _viewModel.scanProgress.watch(context);
    final isIOS = Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IMPORT MUSIC'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // iOS: Select Audio Files
          if (isIOS) ...[
            Card(
              color: AppTheme.cardBackground,
              child: InkWell(
                onTap: _viewModel.pickAndImportFiles,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.audio_file,
                          color: AppTheme.accentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Audio Files',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pick music files from Files app',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.add, color: AppTheme.accentColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // iOS: Scan App Documents
            Card(
              color: AppTheme.cardBackground,
              child: InkWell(
                onTap: _viewModel.scanDocumentsDirectory,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.dividerColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder_special,
                          color: AppTheme.textPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan App Documents',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Import from Finder/iTunes File Sharing',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // iOS Help Text
            Card(
              color: AppTheme.cardBackground.withValues(alpha: 0.5),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppTheme.accentColor),
                        SizedBox(width: 8),
                        Text(
                          'How to add music on iOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. Select Audio Files: Pick files directly from the Files app\n'
                      '2. Finder/iTunes: Connect to Mac/PC, select Spindle in Finder sidebar, drag music to Documents',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Non-iOS: Quick Full Scan
          if (!isIOS) ...[
            Card(
              color: AppTheme.cardBackground,
              child: InkWell(
                onTap: _viewModel.scanAllFolders,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: AppTheme.accentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Full Scan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Scan all added folders for new music',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Non-iOS: Scan Specific Folder
            Card(
              color: AppTheme.cardBackground,
              child: InkWell(
                onTap: _viewModel.pickAndAddFolder,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.dividerColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder_open,
                          color: AppTheme.textPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan Specific Folder',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Select a folder to scan',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.add, color: AppTheme.accentColor),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Scan Progress
          if (isScanning) ...[
            const LinearProgressIndicator(
              color: AppTheme.accentColor,
              backgroundColor: AppTheme.dividerColor,
            ),
            const SizedBox(height: 8),
            Text(
              scanProgress,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
          ] else if (scanProgress.isNotEmpty) ...[
            Text(
              scanProgress,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Current Scan Paths (only show on non-iOS)
          if (!isIOS) ...[
            const Text(
              'CURRENT SCAN PATHS',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            if (folders.isEmpty)
              Card(
                color: AppTheme.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.folder_off,
                        size: 48,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No folders added yet',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _viewModel.pickAndAddFolder,
                        child: const Text('Add a folder'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...folders.map((folder) {
                return Card(
                  color: AppTheme.cardBackground,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.folder, color: AppTheme.accentColor),
                    title: Text(
                      folder.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${folder.songCount} songs',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: () => _viewModel.scanFolder(folder.path),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _viewModel.removeFolder(folder.id!),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
