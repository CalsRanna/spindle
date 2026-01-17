import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

import '../../../service/wifi_transfer_service.dart';
import '../../../util/app_theme.dart';
import '../../desktop/wifi_transfer/wifi_transfer_view_model.dart';

@RoutePage()
class MobileWifiTransferPage extends StatefulWidget {
  const MobileWifiTransferPage({super.key});

  @override
  State<MobileWifiTransferPage> createState() => _MobileWifiTransferPageState();
}

class _MobileWifiTransferPageState extends State<MobileWifiTransferPage> {
  late final WiFiTransferViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<WiFiTransferViewModel>();
  }

  @override
  void dispose() {
    // Stop server when leaving the page
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
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Icon
              Icon(
                Icons.wifi,
                size: 64,
                color: isRunning ? AppTheme.accentColor : AppTheme.textSecondary,
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isRunning ? 'Server Running' : 'WiFi Transfer',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                isRunning
                    ? 'Open this URL in your browser'
                    : 'Transfer music from your computer',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // URL display (when running)
              if (isRunning && serverUrl != null) ...[
                GestureDetector(
                  onTap: _copyUrl,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.copy,
                          size: 20,
                          color: AppTheme.accentColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Make sure your device and computer\nare on the same WiFi network',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Uploaded files list
              if (uploadedFiles.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Received (${uploadedFiles.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (!isImporting)
                      TextButton(
                        onPressed: _importFiles,
                        child: const Text(
                          'IMPORT ALL',
                          style: TextStyle(color: AppTheme.accentColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: uploadedFiles.length,
                    itemBuilder: (context, index) {
                      final file = uploadedFiles[uploadedFiles.length - 1 - index];
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
                          Icons.upload_file,
                          size: 48,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Waiting for files...',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Spacer(),
              ],

              // Start/Stop button
              SizedBox(
                width: double.infinity,
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
                                      'Failed to start server. Check WiFi connection.'),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isRunning ? 'STOP SERVER' : 'START SERVER',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFileItem(UploadedFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.music_note,
            color: AppTheme.accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
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
                Text(
                  _formatFileSize(file.size),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppTheme.accentColor,
            size: 20,
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
