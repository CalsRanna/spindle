import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/folder_repository.dart';
import 'package:spindle/repository/song_repository.dart';
import 'package:spindle/service/bookmark_service.dart';
import 'package:spindle/service/metadata_service.dart';
import 'package:spindle/entity/folder_path.dart';
import 'package:spindle/util/logger_util.dart';

class FileService {
  final _songRepository = SongRepository();
  final _folderRepository = FolderRepository();
  final _metadataService = MetadataService();
  final _bookmarkService = BookmarkService.instance;
  final _logger = LoggerUtil.instance;

  static const _supportedAudioExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.aac',
    '.m4a',
    '.ogg',
    '.wma',
    '.aiff',
    '.alac',
  ];

  static const _supportedLyricsExtensions = ['.lrc'];

  static List<String> get _supportedExtensions =>
      [..._supportedAudioExtensions, ..._supportedLyricsExtensions];

  static const _allowedExtensions = [
    'mp3', 'flac', 'wav', 'aac', 'm4a', 'ogg', 'wma', 'aiff', 'alac', 'lrc'
  ];

  Future<String?> pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    _logger.i('Picked folder: $result');

    // Save bookmark for macOS sandbox persistence
    if (result != null) {
      await _bookmarkService.saveBookmark(result);
    }

    return result;
  }

  /// Pick audio and lyrics files (works on iOS)
  Future<List<String>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: true,
    );

    if (result == null) return [];

    final paths = result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();

    _logger.i('Picked ${paths.length} files');
    return paths;
  }

  /// Check if file is a lyrics file
  bool _isLyricsFile(String filePath) {
    final ext = '.${filePath.toLowerCase().split('.').last}';
    return _supportedLyricsExtensions.contains(ext);
  }

  /// Check if file is an audio file
  bool _isAudioFile(String filePath) {
    final ext = '.${filePath.toLowerCase().split('.').last}';
    return _supportedAudioExtensions.contains(ext);
  }

  /// Get the music directory inside app documents
  Future<Directory> _getMusicDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${docsDir.path}/Music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    return musicDir;
  }

  /// Copy file to app's permanent storage (for iOS)
  /// If a file with the same name already exists in the Music directory,
  /// return that path instead of creating a duplicate.
  Future<String?> _copyToMusicDirectory(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        _logger.w('Source file does not exist: $sourcePath');
        return null;
      }

      final musicDir = await _getMusicDirectory();
      final fileName = p.basename(sourcePath);
      final destPath = '${musicDir.path}/$fileName';
      final destFile = File(destPath);

      // If file already exists in Music directory, use it directly
      if (await destFile.exists()) {
        _logger.i('File already exists in Music directory: $destPath');
        return destPath;
      }

      _logger.i('Copying file to: $destPath');
      await sourceFile.copy(destPath);

      return destPath;
    } catch (e) {
      _logger.e('Error copying file: $e');
      return null;
    }
  }

  /// Import files directly (for iOS - copies files to permanent storage)
  /// Returns a record of (audioCount, lyricsCount)
  Future<({int audioCount, int lyricsCount})> importFiles(List<String> filePaths) async {
    int audioCount = 0;
    int lyricsCount = 0;
    final isIOS = Platform.isIOS;
    final musicDir = await _getMusicDirectory();

    for (final filePath in filePaths) {
      _logger.i('Importing file: $filePath');

      // Skip if not a supported file
      if (!isSupportedFile(filePath)) {
        _logger.w('Unsupported file format: $filePath');
        continue;
      }

      try {
        String permanentPath = filePath;

        // On iOS, copy file to permanent storage (unless already in Music directory)
        if (isIOS && !filePath.startsWith(musicDir.path)) {
          final copiedPath = await _copyToMusicDirectory(filePath);
          if (copiedPath == null) {
            _logger.w('Failed to copy file: $filePath');
            continue;
          }
          permanentPath = copiedPath;
        }

        // Handle lyrics files - just copy, don't add to database
        if (_isLyricsFile(permanentPath)) {
          _logger.i('Imported lyrics: $permanentPath');
          lyricsCount++;
          continue;
        }

        // Handle audio files
        // Skip if already imported (check with permanent path)
        if (await _songRepository.exists(permanentPath)) {
          _logger.i('File already imported: $permanentPath');
          continue;
        }

        final file = File(permanentPath);
        if (!await file.exists()) {
          _logger.w('File does not exist: $permanentPath');
          continue;
        }

        // Read metadata
        final metadata = await _metadataService.readMetadata(permanentPath);
        final stat = await file.stat();

        final song = Song(
          filePath: permanentPath,
          title: metadata['title'] ?? _extractFileName(permanentPath),
          artist: metadata['artist'],
          album: metadata['album'],
          albumArtPath: metadata['albumArtPath'],
          duration: metadata['duration'],
          trackNumber: metadata['trackNumber'],
          year: metadata['year'],
          genre: metadata['genre'],
          bitrate: metadata['bitrate'],
          fileSize: stat.size,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        await _songRepository.insert(song);
        audioCount++;
        _logger.i('Imported: ${song.title}');
      } catch (e) {
        _logger.e('Error importing file $filePath: $e');
      }
    }

    return (audioCount: audioCount, lyricsCount: lyricsCount);
  }

  /// Get the app's documents directory path
  Future<String> getDocumentsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Scan the app's documents directory for music files
  Future<int> scanDocumentsDirectory() async {
    final docsDir = await getDocumentsDirectory();
    _logger.i('Scanning documents directory: $docsDir');

    // Create a "Music" subdirectory if it doesn't exist
    final musicDir = Directory('$docsDir/Music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
      _logger.i('Created Music directory: ${musicDir.path}');
    }

    return await importFolder(musicDir.path);
  }

  Future<List<File>> scanFolder(String folderPath) async {
    _logger.i('Scanning folder: $folderPath');
    final directory = Directory(folderPath);

    _logger.i('Directory path: ${directory.path}');
    _logger.i('Directory absolute path: ${directory.absolute.path}');

    final exists = await directory.exists();
    _logger.i('Directory exists: $exists');

    if (!exists) {
      _logger.w('Directory does not exist: $folderPath');
      // Try to list parent to debug
      try {
        final parent = directory.parent;
        _logger.i('Parent path: ${parent.path}');
        _logger.i('Parent exists: ${await parent.exists()}');
        if (await parent.exists()) {
          await for (final entity in parent.list()) {
            _logger.i('Parent contains: ${entity.path}');
          }
        }
      } catch (e) {
        _logger.e('Error checking parent: $e');
      }
      return [];
    }

    final List<File> audioFiles = [];
    try {
      int fileCount = 0;
      await for (final entity in directory.list(recursive: true)) {
        fileCount++;
        _logger.d('Found entity: ${entity.path} (${entity.runtimeType})');
        if (entity is File) {
          final extension = entity.path.toLowerCase().split('.').last;
          _logger.d('File extension: .$extension');
          if (_supportedExtensions.contains('.$extension')) {
            _logger.i('Found audio file: ${entity.path}');
            audioFiles.add(entity);
          }
        }
      }
      _logger.i('Total entities scanned: $fileCount');
    } catch (e, stack) {
      _logger.e('Error scanning folder: $e');
      _logger.e('Stack trace: $stack');
    }

    _logger.i('Found ${audioFiles.length} audio files in $folderPath');
    return audioFiles;
  }

  Future<int> importFolder(String folderPath) async {
    // Cleanup invalid songs before scanning
    await _songRepository.cleanupInvalidSongs();

    // Add folder to database if not exists
    if (!await _folderRepository.exists(folderPath)) {
      await _folderRepository.insert(FolderPath(
        path: folderPath,
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    // Scan for audio files
    final files = await scanFolder(folderPath);
    int importedCount = 0;

    for (final file in files) {
      // Skip if already imported
      if (await _songRepository.exists(file.path)) continue;

      // Read metadata
      final metadata = await _metadataService.readMetadata(file.path);
      final stat = await file.stat();

      final song = Song(
        filePath: file.path,
        title: metadata['title'] ?? _extractFileName(file.path),
        artist: metadata['artist'],
        album: metadata['album'],
        albumArtPath: metadata['albumArtPath'],
        duration: metadata['duration'],
        trackNumber: metadata['trackNumber'],
        year: metadata['year'],
        genre: metadata['genre'],
        bitrate: metadata['bitrate'],
        fileSize: stat.size,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _songRepository.insert(song);
      importedCount++;
    }

    // Update folder song count
    final folder = await _folderRepository.getByPath(folderPath);
    if (folder != null) {
      await _folderRepository.updateSongCount(folder.id!, files.length);
    }

    return importedCount;
  }

  Future<void> scanAllFolders() async {
    final folders = await _folderRepository.getAll();
    for (final folder in folders) {
      await importFolder(folder.path);
    }
  }

  Future<void> removeFolder(int folderId) async {
    final folder = await _folderRepository.getById(folderId);
    if (folder == null) return;

    // Get all songs in this folder and delete them
    final allSongs = await _songRepository.getAll();
    for (final song in allSongs) {
      if (song.filePath.startsWith(folder.path)) {
        await _songRepository.delete(song.id!);
      }
    }

    await _folderRepository.delete(folderId);
  }

  String _extractFileName(String filePath) {
    final fileName = filePath.split('/').last;
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex > 0) {
      return fileName.substring(0, lastDotIndex);
    }
    return fileName;
  }

  bool isSupportedFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return _supportedExtensions.contains('.$extension');
  }
}
