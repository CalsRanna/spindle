import 'package:flutter/material.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const SongTile({
    super.key,
    required this.song,
    this.isPlaying = false,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AlbumCover(
        imagePath: song.albumArtPath,
        size: 48,
        isPlaying: isPlaying,
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? AppTheme.accentColor : AppTheme.textPrimary,
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.displayArtist,
        style: TextStyle(
          color: isPlaying ? AppTheme.accentColor.withValues(alpha: 0.7) : AppTheme.textSecondary,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            song.displayDuration,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onPressed: onMoreTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
