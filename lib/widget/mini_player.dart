import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final playerViewModel = GetIt.instance.get<PlayerViewModel>();

    return Watch((context) {
      final currentSong = playerViewModel.currentSong.value;

      if (currentSong == null) return const SizedBox.shrink();

      final position = playerViewModel.position.value;
      final duration = playerViewModel.duration.value;
      final isPlaying = playerViewModel.isPlaying.value;

      final progress = duration.inMilliseconds > 0
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            border: Border(
              top: BorderSide(color: AppTheme.dividerColor, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.accentColor,
                ),
                minHeight: 2,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      AlbumCover(
                        imagePath: currentSong.albumArtPath,
                        size: 44,
                        borderRadius: 6,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (currentSong.artist != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                currentSong.artist!,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppTheme.textPrimary,
                        ),
                        onPressed: playerViewModel.togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          color: AppTheme.textPrimary,
                        ),
                        onPressed: playerViewModel.next,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
