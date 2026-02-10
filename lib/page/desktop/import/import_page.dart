import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/import/import_view_model.dart';
import 'package:spindle/util/app_theme.dart';

@RoutePage()
class DesktopImportPage extends StatefulWidget {
  const DesktopImportPage({super.key});

  @override
  State<DesktopImportPage> createState() => _DesktopImportPageState();
}

class _DesktopImportPageState extends State<DesktopImportPage> {
  late final ImportViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<ImportViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final folders = _viewModel.folders.value;
      final isScanning = _viewModel.isScanning.value;
      final scanProgress = _viewModel.scanProgress.value;

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
            // Scan All Folders
            Card(
              color: AppTheme.cardBackground,
              child: InkWell(
                onTap: isScanning ? null : _viewModel.scanAllFolders,
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
                              'Scan All Folders',
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

            // Scan Progress
            if (isScanning) ...[
              const SizedBox(height: 16),
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
            ] else if (scanProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                scanProgress,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Folders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FOLDERS',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: _viewModel.pickAndAddFolder,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Folder'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Folder List
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _viewModel.removeFolder(folder.id!),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }
}
