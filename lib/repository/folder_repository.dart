import 'package:spindle/database/database.dart';
import 'package:spindle/entity/folder_path.dart';

class FolderRepository {
  final _db = Database.instance;

  Future<List<FolderPath>> getAll() async {
    final results = await _db.laconic
        .table('folder_paths')
        .orderBy('added_at', direction: 'desc')
        .get();
    return results.map((e) => FolderPath.fromMap(e.toMap())).toList();
  }

  Future<FolderPath?> getById(int id) async {
    final results =
        await _db.laconic.table('folder_paths').where('id', id).get();
    if (results.isEmpty) return null;
    return FolderPath.fromMap(results.first.toMap());
  }

  Future<FolderPath?> getByPath(String path) async {
    final results =
        await _db.laconic.table('folder_paths').where('path', path).get();
    if (results.isEmpty) return null;
    return FolderPath.fromMap(results.first.toMap());
  }

  Future<int> insert(FolderPath folderPath) async {
    return await _db.laconic
        .table('folder_paths')
        .insertGetId(folderPath.toMap());
  }

  Future<void> update(FolderPath folderPath) async {
    if (folderPath.id == null) return;
    await _db.laconic
        .table('folder_paths')
        .where('id', folderPath.id)
        .update(folderPath.toMap());
  }

  Future<void> updateSongCount(int id, int count) async {
    await _db.laconic.table('folder_paths').where('id', id).update({
      'song_count': count,
      'last_scanned_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> delete(int id) async {
    await _db.laconic.table('folder_paths').where('id', id).delete();
  }

  Future<bool> exists(String path) async {
    final count =
        await _db.laconic.table('folder_paths').where('path', path).count();
    return count > 0;
  }
}
