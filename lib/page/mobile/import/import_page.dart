import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  }

  Future<void> _pickAndImportFiles() async {
    final result = await _viewModel.pickAndImportFiles();
    if (result.audioCount > 0 || result.lyricsCount > 0) {
      await _libraryViewModel.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isScanning = _viewModel.isScanning.value;
      final scanProgress = _viewModel.scanProgress.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('IMPORT'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Select Files option
              _buildCard(
                icon: Icons.folder_open,
                iconColor: AppTheme.accentColor,
                title: 'Select Files',
                subtitle: 'Pick music and lyrics from Files app',
                trailing: const Icon(Icons.add, color: AppTheme.accentColor),
                onTap: isScanning ? null : _pickAndImportFiles,
              ),
              const SizedBox(height: 16),

              // WiFi Transfer option
              _buildCard(
                icon: Icons.wifi,
                iconColor: Colors.blue,
                title: 'WiFi Transfer',
                subtitle: 'Receive files from your computer',
                trailing:
                    const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: isScanning
                    ? null
                    : () => context.router.push(const MobileWifiTransferRoute()),
              ),

              const SizedBox(height: 32),

              // Progress indicator
              if (isScanning) ...[
                const LinearProgressIndicator(
                  color: AppTheme.accentColor,
                  backgroundColor: AppTheme.dividerColor,
                ),
                const SizedBox(height: 12),
                Text(
                  scanProgress,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ] else if (scanProgress.isNotEmpty) ...[
                Text(
                  scanProgress,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],

              const Spacer(),

              // Help card
              Card(
                color: AppTheme.cardBackground.withValues(alpha: 0.5),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: AppTheme.accentColor),
                          SizedBox(width: 8),
                          Text(
                            'Supported formats',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Audio: MP3, FLAC, WAV, AAC, M4A, OGG, WMA, AIFF, ALAC\n'
                        'Lyrics: LRC',
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
              const SizedBox(height: 80),
            ],
          ),
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
    required VoidCallback? onTap,
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
                      : iconColor.withValues(alpha: 0.2),
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
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
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
