class Song {
  final int? id;
  final String filePath;
  final String title;
  final String? artist;
  final String? album;
  final String? albumArtPath;
  final int? duration;
  final int? trackNumber;
  final int? year;
  final String? genre;
  final int? bitrate;
  final int? fileSize;
  final int createdAt;
  final int? lastPlayedAt;
  final int playCount;
  final bool isFavorite;

  Song({
    this.id,
    required this.filePath,
    required this.title,
    this.artist,
    this.album,
    this.albumArtPath,
    this.duration,
    this.trackNumber,
    this.year,
    this.genre,
    this.bitrate,
    this.fileSize,
    required this.createdAt,
    this.lastPlayedAt,
    this.playCount = 0,
    this.isFavorite = false,
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      albumArtPath: map['album_art_path'] as String?,
      duration: map['duration'] as int?,
      trackNumber: map['track_number'] as int?,
      year: map['year'] as int?,
      genre: map['genre'] as String?,
      bitrate: map['bitrate'] as int?,
      fileSize: map['file_size'] as int?,
      createdAt: map['created_at'] as int,
      lastPlayedAt: map['last_played_at'] as int?,
      playCount: map['play_count'] as int? ?? 0,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_path': filePath,
      'title': title,
      'artist': artist,
      'album': album,
      'album_art_path': albumArtPath,
      'duration': duration,
      'track_number': trackNumber,
      'year': year,
      'genre': genre,
      'bitrate': bitrate,
      'file_size': fileSize,
      'created_at': createdAt,
      'last_played_at': lastPlayedAt,
      'play_count': playCount,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  Song copyWith({
    int? id,
    String? filePath,
    String? title,
    String? artist,
    String? album,
    String? albumArtPath,
    int? duration,
    int? trackNumber,
    int? year,
    String? genre,
    int? bitrate,
    int? fileSize,
    int? createdAt,
    int? lastPlayedAt,
    int? playCount,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      duration: duration ?? this.duration,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      bitrate: bitrate ?? this.bitrate,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get displayDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get displayArtist => artist ?? '';
  String get displayAlbum => album ?? 'Unknown Album';
}
