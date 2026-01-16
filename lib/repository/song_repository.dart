import 'dart:io';

import 'package:spindle/database/database.dart';
import 'package:spindle/entity/song.dart';

class SongRepository {
  final _db = Database.instance;

  Future<List<Song>> getAll() async {
    final results = await _db.laconic.table('songs').orderBy('title').get();
    return results.map((e) => Song.fromMap(e.toMap())).toList();
  }

  /// Get all songs, filtering out those with missing files
  Future<List<Song>> getAllValid() async {
    final songs = await getAll();
    final validSongs = <Song>[];
    for (final song in songs) {
      if (await File(song.filePath).exists()) {
        validSongs.add(song);
      }
    }
    return validSongs;
  }

  /// Remove songs whose files no longer exist
  Future<int> cleanupInvalidSongs() async {
    final songs = await getAll();
    int removedCount = 0;
    for (final song in songs) {
      if (!await File(song.filePath).exists()) {
        if (song.id != null) {
          await delete(song.id!);
          removedCount++;
        }
      }
    }
    return removedCount;
  }

  Future<Song?> getById(int id) async {
    final results = await _db.laconic.table('songs').where('id', id).get();
    if (results.isEmpty) return null;
    return Song.fromMap(results.first.toMap());
  }

  Future<Song?> getByFilePath(String filePath) async {
    final results =
        await _db.laconic.table('songs').where('file_path', filePath).get();
    if (results.isEmpty) return null;
    return Song.fromMap(results.first.toMap());
  }

  Future<List<Song>> search(String query) async {
    final results = await _db.laconic
        .table('songs')
        .where('title', '%$query%', comparator: 'like')
        .orWhere('artist', '%$query%', comparator: 'like')
        .orWhere('album', '%$query%', comparator: 'like')
        .orderBy('title')
        .get();
    return results.map((e) => Song.fromMap(e.toMap())).toList();
  }

  Future<List<Song>> getRecentlyPlayed({int limit = 10}) async {
    final results = await _db.laconic
        .table('songs')
        .whereNotNull('last_played_at')
        .orderBy('last_played_at', direction: 'desc')
        .limit(limit)
        .get();
    return results.map((e) => Song.fromMap(e.toMap())).toList();
  }

  Future<List<Song>> getFavorites() async {
    final results = await _db.laconic
        .table('songs')
        .where('is_favorite', 1)
        .orderBy('title')
        .get();
    return results.map((e) => Song.fromMap(e.toMap())).toList();
  }

  Future<int> insert(Song song) async {
    return await _db.laconic.table('songs').insertGetId(song.toMap());
  }

  Future<void> insertMany(List<Song> songs) async {
    if (songs.isEmpty) return;
    await _db.laconic.table('songs').insert(songs.map((e) => e.toMap()).toList());
  }

  Future<void> update(Song song) async {
    if (song.id == null) return;
    await _db.laconic.table('songs').where('id', song.id).update(song.toMap());
  }

  Future<void> delete(int id) async {
    await _db.laconic.table('songs').where('id', id).delete();
  }

  Future<void> deleteByFilePath(String filePath) async {
    await _db.laconic.table('songs').where('file_path', filePath).delete();
  }

  Future<void> updateLastPlayed(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.laconic.table('songs').where('id', id).update({
      'last_played_at': now,
    });
    await _db.laconic.table('songs').where('id', id).increment('play_count');
  }

  Future<void> toggleFavorite(int id) async {
    final song = await getById(id);
    if (song == null) return;
    await _db.laconic.table('songs').where('id', id).update({
      'is_favorite': song.isFavorite ? 0 : 1,
    });
  }

  Future<int> count() async {
    return await _db.laconic.table('songs').count();
  }

  Future<bool> exists(String filePath) async {
    final count = await _db.laconic
        .table('songs')
        .where('file_path', filePath)
        .count();
    return count > 0;
  }
}
