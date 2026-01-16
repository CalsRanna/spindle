import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MetadataService {
  Future<Map<String, dynamic>> readMetadata(String filePath) async {
    try {
      final metadata = await MetadataRetriever.fromFile(File(filePath));

      String? albumArtPath;
      if (metadata.albumArt != null) {
        albumArtPath = await _saveAlbumArt(filePath, metadata.albumArt!);
      }

      return {
        'title': metadata.trackName,
        'artist': metadata.trackArtistNames?.join(', '),
        'album': metadata.albumName,
        'albumArtPath': albumArtPath,
        'duration': metadata.trackDuration != null
            ? (metadata.trackDuration! / 1000).round()
            : null,
        'trackNumber': metadata.trackNumber,
        'year': metadata.year,
        'genre': metadata.genre,
        'bitrate': metadata.bitrate,
      };
    } catch (e) {
      // Return empty metadata on error
      return {};
    }
  }

  Future<String?> _saveAlbumArt(String audioFilePath, List<int> albumArt) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final artDir = Directory(p.join(appDir.path, 'album_art'));
      if (!await artDir.exists()) {
        await artDir.create(recursive: true);
      }

      // Use hash of file path as filename
      final hash = audioFilePath.hashCode.abs().toString();
      final artPath = p.join(artDir.path, '$hash.jpg');

      final artFile = File(artPath);
      if (!await artFile.exists()) {
        await artFile.writeAsBytes(albumArt);
      }

      return artPath;
    } catch (e) {
      return null;
    }
  }

  Future<List<int>?> getAlbumArt(String filePath) async {
    try {
      final metadata = await MetadataRetriever.fromFile(File(filePath));
      return metadata.albumArt;
    } catch (e) {
      return null;
    }
  }
}
