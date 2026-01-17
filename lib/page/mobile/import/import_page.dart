import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/import/import_view_model.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<ImportViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

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
            if (isIOS) ...[
              _buildCard(
                icon: Icons.audio_file,
                iconColor: AppTheme.accentColor,
                title: 'Select Audio Files',
                subtitle: 'Pick music files from Files app',
                trailing: const Icon(Icons.add, color: AppTheme.accentColor),
                onTap: _viewModel.pickAndImportFiles,
              ),
              const SizedBox(height: 16),
              _buildCard(
                icon: Icons.folder_special,
                iconColor: AppTheme.textPrimary,
                title: 'Scan App Documents',
                subtitle: 'Import from Finder/iTunes File Sharing',
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: _viewModel.scanDocumentsDirectory,
              ),
              const SizedBox(height: 16),
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            if (!isIOS) ...[
              _buildCard(
                icon: Icons.bolt,
                iconColor: AppTheme.accentColor,
                title: 'Quick Full Scan',
                subtitle: 'Scan all added folders for new music',
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: _viewModel.scanAllFolders,
              ),
              const SizedBox(height: 16),
              _buildCard(
                icon: Icons.folder_open,
                iconColor: AppTheme.textPrimary,
                title: 'Scan Specific Folder',
                subtitle: 'Select a folder to scan',
                trailing: const Icon(Icons.add, color: AppTheme.accentColor),
                onTap: _viewModel.pickAndAddFolder,
              ),
            ],

            // WiFi Transfer option (available on all platforms)
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.wifi,
              iconColor: Colors.blue,
              title: 'WiFi Transfer',
              subtitle: 'Receive files from your computer',
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              onTap: () => context.router.push(const MobileWifiTransferRoute()),
            ),

            const SizedBox(height: 32),
            if (isScanning) ...[
              const LinearProgressIndicator(
                color: AppTheme.accentColor,
                backgroundColor: AppTheme.dividerColor,
              ),
              const SizedBox(height: 8),
              Text(
                scanProgress,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
            ] else if (scanProgress.isNotEmpty) ...[
              Text(
                scanProgress,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
            ],
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
                        const Icon(Icons.folder_off, size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        const Text(
                          'No folders added yet',
                          style: TextStyle(color: AppTheme.textSecondary),
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
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
    });
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppTheme.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor == AppTheme.accentColor
                      ? AppTheme.accentColor.withValues(alpha: 0.2)
                      : AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
