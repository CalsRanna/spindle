class PlayHistory {
  final int? id;
  final int songId;
  final int playedAt;

  PlayHistory({
    this.id,
    required this.songId,
    required this.playedAt,
  });

  factory PlayHistory.fromMap(Map<String, dynamic> map) {
    return PlayHistory(
      id: map['id'] as int?,
      songId: map['song_id'] as int,
      playedAt: map['played_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'song_id': songId,
      'played_at': playedAt,
    };
  }
}
