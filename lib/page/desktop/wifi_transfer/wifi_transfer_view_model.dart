import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';

import '../../../service/file_service.dart';
import '../../../service/wifi_transfer_service.dart';
import '../library/library_view_model.dart';

class WiFiTransferViewModel {
  final _wifiTransferService = WiFiTransferService.instance;
  final _fileService = FileService();
  final _libraryViewModel = GetIt.instance.get<LibraryViewModel>();

  // Expose signals from service
  Signal<bool> get isRunning => _wifiTransferService.isRunning;
  Signal<String?> get serverUrl => _wifiTransferService.serverUrl;
  Signal<List<UploadedFile>> get uploadedFiles =>
      _wifiTransferService.uploadedFiles;

  final isImporting = Signal<bool>(false);
  final importedCount = Signal<int>(0);

  /// Start the WiFi transfer server
  Future<bool> startServer() async {
    return await _wifiTransferService.startServer();
  }

  /// Stop the WiFi transfer server
  Future<void> stopServer() async {
    await _wifiTransferService.stopServer();
  }

  /// Import all uploaded files to the music library
  Future<({int audioCount, int lyricsCount})> importUploadedFiles() async {
    final paths = _wifiTransferService.getUploadedFilePaths();
    if (paths.isEmpty) return (audioCount: 0, lyricsCount: 0);

    isImporting.value = true;
    try {
      final result = await _fileService.importFiles(paths);
      importedCount.value = result.audioCount;

      // Refresh library
      if (result.audioCount > 0) {
        await _libraryViewModel.refresh();
      }

      // Clear uploaded files after import
      _wifiTransferService.clearUploadedFiles();

      return result;
    } finally {
      isImporting.value = false;
    }
  }

  /// Clear the uploaded files list
  void clearUploadedFiles() {
    _wifiTransferService.clearUploadedFiles();
    importedCount.value = 0;
  }
}
