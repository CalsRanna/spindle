import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/folder_path.dart';
import 'package:spindle/repository/folder_repository.dart';
import 'package:spindle/service/file_service.dart';

class ImportViewModel {
  final _fileService = FileService();
  final _folderRepository = FolderRepository();

  final folders = Signal<List<FolderPath>>([]);
  final isScanning = Signal<bool>(false);
  final scanProgress = Signal<String>('');

  /// Whether to show iOS-specific import options
  bool get isIOS => Platform.isIOS;

  ImportViewModel() {
    loadFolders();
  }

  Future<void> loadFolders() async {
    folders.value = await _folderRepository.getAll();
  }

  /// Pick and import audio files directly (works on iOS)
  Future<void> pickAndImportFiles() async {
    isScanning.value = true;
    scanProgress.value = 'Selecting files...';

    try {
      final filePaths = await _fileService.pickAudioFiles();
      if (filePaths.isEmpty) {
        scanProgress.value = 'No files selected';
        return;
      }

      scanProgress.value = 'Importing ${filePaths.length} files...';
      final count = await _fileService.importFiles(filePaths);

      if (count > 0) {
        scanProgress.value = 'Imported $count songs';
      } else {
        scanProgress.value = 'No new songs imported';
      }
    } catch (e) {
      scanProgress.value = 'Error: $e';
    } finally {
      isScanning.value = false;
    }
  }

  /// Scan the app's documents directory (for iTunes File Sharing)
  Future<void> scanDocumentsDirectory() async {
    isScanning.value = true;
    scanProgress.value = 'Scanning app documents...';

    try {
      final count = await _fileService.scanDocumentsDirectory();
      if (count > 0) {
        scanProgress.value = 'Imported $count songs from Documents';
      } else {
        scanProgress.value = 'No new songs in Documents folder';
      }
      await loadFolders();
    } catch (e) {
      scanProgress.value = 'Error: $e';
    } finally {
      isScanning.value = false;
    }
  }

  /// Get the documents directory path for display
  Future<String> getDocumentsPath() async {
    return await _fileService.getDocumentsDirectory();
  }

  Future<bool> _requestStoragePermission() async {
    // iOS: file_picker uses UIDocumentPickerViewController which doesn't require
    // explicit permission. Access is granted when user selects a folder.
    // For Apple Music library access, mediaLibrary permission would be needed.
    if (Platform.isIOS) {
      // Try to get media library permission for Apple Music access (optional)
      final status = await Permission.mediaLibrary.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Not critical - user can still pick folders from Files app
        scanProgress.value = 'Tip: Enable media library access for Apple Music';
      }
      return true;
    }

    // macOS/Linux/Windows: No special permissions needed for file picker
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Android 11+ (API 30+) needs MANAGE_EXTERNAL_STORAGE for full access
    if (sdkInt >= 30) {
      final status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        final result = await Permission.manageExternalStorage.request();
        if (!result.isGranted) {
          scanProgress.value = 'Please grant "All files access" in Settings';
          await openAppSettings();
          return false;
        }
      }
      return true;
    }

    // Android 13+ (API 33+) uses granular media permissions
    if (sdkInt >= 33) {
      final audioStatus = await Permission.audio.request();
      final photosStatus = await Permission.photos.request();

      if (audioStatus.isGranted || photosStatus.isGranted) {
        return true;
      }

      if (audioStatus.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
        scanProgress.value = 'Permission denied. Please enable in Settings.';
        await openAppSettings();
        return false;
      }

      scanProgress.value = 'Storage permission required';
      return false;
    }

    // Android 12 and below
    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      scanProgress.value = 'Permission denied. Please enable in Settings.';
      await openAppSettings();
      return false;
    }

    scanProgress.value = 'Storage permission required';
    return false;
  }

  Future<void> pickAndAddFolder() async {
    if (!await _requestStoragePermission()) return;

    final path = await _fileService.pickFolder();
    if (path == null) return;

    if (await _folderRepository.exists(path)) {
      scanProgress.value = 'Folder already added';
      return;
    }

    await _folderRepository.insert(FolderPath(
      path: path,
      addedAt: DateTime.now().millisecondsSinceEpoch,
    ));

    await loadFolders();
    await scanFolder(path);
  }

  Future<void> scanFolder(String path) async {
    isScanning.value = true;
    scanProgress.value = 'Scanning: $path';

    try {
      // First, check if we can access the folder
      final dir = Directory(path);
      final exists = await dir.exists();
      scanProgress.value = 'Folder exists: $exists';

      if (!exists) {
        scanProgress.value = 'Error: Cannot access folder';
        return;
      }

      final count = await _fileService.importFolder(path);
      if (count > 0) {
        scanProgress.value = 'Imported $count songs';
      } else {
        scanProgress.value = 'No audio files found in folder';
      }
      await loadFolders();
    } catch (e) {
      scanProgress.value = 'Error: $e';
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> scanAllFolders() async {
    if (!await _requestStoragePermission()) return;

    isScanning.value = true;
    scanProgress.value = 'Scanning all folders...';

    try {
      await _fileService.scanAllFolders();
      await loadFolders();
      scanProgress.value = 'Scan complete';
    } catch (e) {
      scanProgress.value = 'Error: $e';
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> removeFolder(int id) async {
    await _fileService.removeFolder(id);
    await loadFolders();
  }

  void dispose() {
    folders.dispose();
    isScanning.dispose();
    scanProgress.dispose();
  }
}
