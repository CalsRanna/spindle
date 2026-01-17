import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

import '../../../service/wifi_transfer_service.dart';
import '../../../util/app_theme.dart';
import 'wifi_transfer_view_model.dart';

@RoutePage()
class DesktopWifiTransferPage extends StatefulWidget {
  const DesktopWifiTransferPage({super.key});

  @override
  State<DesktopWifiTransferPage> createState() =>
      _DesktopWifiTransferPageState();
}

class _DesktopWifiTransferPageState extends State<DesktopWifiTransferPage> {
  late final WiFiTransferViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<WiFiTransferViewModel>();
  }

  @override
  void dispose() {
    _viewModel.stopServer();
    super.dispose();
  }

  void _copyUrl() {
    final url = _viewModel.serverUrl.value;
    if (url != null) {
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to clipboard'),
          backgroundColor: AppTheme.accentColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _importFiles() async {
    final count = await _viewModel.importUploadedFiles();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported $count songs'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isRunning = _viewModel.isRunning.value;
      final serverUrl = _viewModel.serverUrl.value;
      final uploadedFiles = _viewModel.uploadedFiles.value;
      final isImporting = _viewModel.isImporting.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('WIFI TRANSFER'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Icon
                Icon(
                  Icons.wifi,
                  size: 80,
                  color:
                      isRunning ? AppTheme.accentColor : AppTheme.textSecondary,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  isRunning ? 'Server Running' : 'WiFi Transfer',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  isRunning
                      ? 'Open this URL in any browser on your network'
                      : 'Start a local server to receive music files from other devices',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // URL display (when running)
                if (isRunning && serverUrl != null) ...[
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _copyUrl,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              serverUrl,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.accentColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.copy,
                              size: 24,
                              color: AppTheme.accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Uploaded files list
                if (uploadedFiles.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Received Files (${uploadedFiles.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _viewModel.clearUploadedFiles,
                            child: const Text('Clear'),
                          ),
                          const SizedBox(width: 8),
                          if (!isImporting)
                            ElevatedButton.icon(
                              onPressed: _importFiles,
                              icon: const Icon(Icons.library_add, size: 18),
                              label: const Text('Import All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final file =
                            uploadedFiles[uploadedFiles.length - 1 - index];
                        return _buildFileItem(file);
                      },
                    ),
                  ),
                ] else if (isRunning) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 64,
                            color: AppTheme.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Waiting for files...',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload files through the web interface',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ],

                // Start/Stop button
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: isImporting
                        ? null
                        : () async {
                            if (isRunning) {
                              await _viewModel.stopServer();
                            } else {
                              final success = await _viewModel.startServer();
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to start server. Check your network connection.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isRunning ? Colors.red.shade700 : AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isRunning ? 'Stop Server' : 'Start Server',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFileItem(UploadedFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.music_note,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(file.size),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppTheme.accentColor,
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
