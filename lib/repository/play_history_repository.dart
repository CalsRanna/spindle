import 'package:spindle/database/database.dart';
import 'package:spindle/entity/play_history.dart';
import 'package:spindle/entity/song.dart';

class PlayHistoryRepository {
  final _db = Database.instance;

  Future<List<PlayHistory>> getAll({int limit = 100}) async {
    final results = await _db.laconic
        .table('play_history')
        .orderBy('played_at', direction: 'desc')
        .limit(limit)
        .get();
    return results.map((e) => PlayHistory.fromMap(e.toMap())).toList();
  }

  Future<List<Song>> getRecentSongs({int limit = 20}) async {
    // Use join to get songs from play history
    final results = await _db.laconic
        .table('play_history')
        .join('songs', (join) => join.on('play_history.song_id', 'songs.id'))
        .select(['songs.*'])
        .distinct()
        .orderBy('play_history.played_at', direction: 'desc')
        .limit(limit)
        .get();
    return results.map((e) => Song.fromMap(e.toMap())).toList();
  }

  Future<void> insert(PlayHistory history) async {
    await _db.laconic.table('play_history').insert([history.toMap()]);
  }

  Future<void> recordPlay(int songId) async {
    final history = PlayHistory(
      songId: songId,
      playedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await insert(history);
  }

  Future<void> clearHistory() async {
    await _db.laconic.table('play_history').delete();
  }

  Future<void> deleteOldHistory({int keepDays = 30}) async {
    final cutoff = DateTime.now()
        .subtract(Duration(days: keepDays))
        .millisecondsSinceEpoch;
    await _db.laconic
        .table('play_history')
        .where('played_at', cutoff, comparator: '<')
        .delete();
  }
}
