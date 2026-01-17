import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:signals/signals.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/repository/song_repository.dart';
import 'package:spindle/util/logger_util.dart';

class MetadataEditorViewModel {
  final _songRepository = SongRepository();
  final _logger = LoggerUtil.instance;

  late Song _song;

  // Form fields
  final title = signal('');
  final artist = signal('');
  final album = signal('');
  final trackNumber = signal('');
  final year = signal('');
  final genre = signal('');

  // State
  final isSaving = signal(false);
  final hasChanges = signal(false);

  void init(Song song) {
    _song = song;
    title.value = song.title;
    artist.value = song.artist ?? '';
    album.value = song.album ?? '';
    trackNumber.value = song.trackNumber?.toString() ?? '';
    year.value = song.year?.toString() ?? '';
    genre.value = song.genre ?? '';
    hasChanges.value = false;
  }

  void updateTitle(String value) {
    title.value = value;
    hasChanges.value = true;
  }

  void updateArtist(String value) {
    artist.value = value;
    hasChanges.value = true;
  }

  void updateAlbum(String value) {
    album.value = value;
    hasChanges.value = true;
  }

  void updateTrackNumber(String value) {
    trackNumber.value = value;
    hasChanges.value = true;
  }

  void updateYear(String value) {
    year.value = value;
    hasChanges.value = true;
  }

  void updateGenre(String value) {
    genre.value = value;
    hasChanges.value = true;
  }

  Future<bool> save() async {
    if (!hasChanges.value) return true;

    isSaving.value = true;

    try {
      // Try to write metadata to audio file
      final file = File(_song.filePath);
      if (await file.exists()) {
        try {
          final metadata = Metadata(
            title: title.value.isNotEmpty ? title.value : null,
            artist: artist.value.isNotEmpty ? artist.value : null,
            album: album.value.isNotEmpty ? album.value : null,
            trackNumber: int.tryParse(trackNumber.value),
            year: int.tryParse(year.value),
            genre: genre.value.isNotEmpty ? genre.value : null,
          );
          await MetadataGod.writeMetadata(file: _song.filePath, metadata: metadata);
          _logger.i('Wrote metadata to file: ${_song.filePath}');
        } catch (e) {
          _logger.w('Could not write metadata to file: $e');
          // Continue to save to database even if file write fails
        }
      }

      // Update database
      final updatedSong = _song.copyWith(
        title: title.value.isNotEmpty ? title.value : _song.title,
        artist: artist.value.isNotEmpty ? artist.value : null,
        album: album.value.isNotEmpty ? album.value : null,
        trackNumber: int.tryParse(trackNumber.value),
        year: int.tryParse(year.value),
        genre: genre.value.isNotEmpty ? genre.value : null,
      );

      await _songRepository.update(updatedSong);
      _song = updatedSong;
      hasChanges.value = false;
      _logger.i('Saved metadata to database for: ${_song.title}');

      return true;
    } catch (e) {
      _logger.e('Error saving metadata: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Song get song => _song;
}
