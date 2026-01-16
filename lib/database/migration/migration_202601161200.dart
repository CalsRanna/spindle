import 'package:laconic/laconic.dart';

class Migration202601161200 {
  static const name = 'migration_202601161200';

  Future<void> migrate(Laconic laconic) async {
    var count = await laconic.table('migrations').where('name', name).count();
    if (count > 0) return;

    // Create songs table
    await laconic.statement('''
      CREATE TABLE songs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        artist TEXT,
        album TEXT,
        album_art_path TEXT,
        duration INTEGER,
        track_number INTEGER,
        year INTEGER,
        genre TEXT,
        bitrate INTEGER,
        file_size INTEGER,
        created_at INTEGER NOT NULL,
        last_played_at INTEGER,
        play_count INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Create folder_paths table
    await laconic.statement('''
      CREATE TABLE folder_paths(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        song_count INTEGER DEFAULT 0,
        added_at INTEGER NOT NULL,
        last_scanned_at INTEGER
      )
    ''');

    // Create play_history table
    await laconic.statement('''
      CREATE TABLE play_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        played_at INTEGER NOT NULL,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await laconic.statement('''
      CREATE INDEX idx_songs_title ON songs(title)
    ''');

    await laconic.statement('''
      CREATE INDEX idx_songs_artist ON songs(artist)
    ''');

    await laconic.statement('''
      CREATE INDEX idx_songs_album ON songs(album)
    ''');

    await laconic.statement('''
      CREATE INDEX idx_play_history_song_id ON play_history(song_id)
    ''');

    await laconic.statement('''
      CREATE INDEX idx_play_history_played_at ON play_history(played_at)
    ''');

    await laconic.table('migrations').insert([
      {'name': name},
    ]);
  }
}
