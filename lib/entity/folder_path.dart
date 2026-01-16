class FolderPath {
  final int? id;
  final String path;
  final int songCount;
  final int addedAt;
  final int? lastScannedAt;

  FolderPath({
    this.id,
    required this.path,
    this.songCount = 0,
    required this.addedAt,
    this.lastScannedAt,
  });

  factory FolderPath.fromMap(Map<String, dynamic> map) {
    return FolderPath(
      id: map['id'] as int?,
      path: map['path'] as String,
      songCount: map['song_count'] as int? ?? 0,
      addedAt: map['added_at'] as int,
      lastScannedAt: map['last_scanned_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'path': path,
      'song_count': songCount,
      'added_at': addedAt,
      'last_scanned_at': lastScannedAt,
    };
  }

  FolderPath copyWith({
    int? id,
    String? path,
    int? songCount,
    int? addedAt,
    int? lastScannedAt,
  }) {
    return FolderPath(
      id: id ?? this.id,
      path: path ?? this.path,
      songCount: songCount ?? this.songCount,
      addedAt: addedAt ?? this.addedAt,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
    );
  }

  String get displayName {
    final parts = path.split('/');
    return parts.isNotEmpty ? parts.last : path;
  }
}
