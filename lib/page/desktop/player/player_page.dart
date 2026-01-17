import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/service/lyrics_service.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';
import 'package:spindle/widget/lyrics_view.dart';

@RoutePage()
class DesktopPlayerPage extends StatefulWidget {
  const DesktopPlayerPage({super.key});

  @override
  State<DesktopPlayerPage> createState() => _DesktopPlayerPageState();
}

class _DesktopPlayerPageState extends State<DesktopPlayerPage> {
  late final PlayerViewModel _viewModel;
  final _lyricsService = LyricsService.instance;
  String? _lastLoadedSongPath;
  EffectCleanup? _effectCleanup;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<PlayerViewModel>();
    _loadLyrics();

    // Listen for song changes
    _effectCleanup = effect(() {
      final currentPath = _viewModel.currentSong.value?.filePath;
      if (currentPath != _lastLoadedSongPath) {
        _lastLoadedSongPath = currentPath;
        _lyricsService.loadLyrics(currentPath);
      }
    });
  }

  @override
  void dispose() {
    _effectCleanup?.call();
    super.dispose();
  }

  void _loadLyrics() {
    final currentSong = _viewModel.currentSong.value;
    _lastLoadedSongPath = currentSong?.filePath;
    _lyricsService.loadLyrics(currentSong?.filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final currentSong = _viewModel.currentSong.value;

      if (currentSong == null) {
        return const Scaffold(body: Center(child: Text('No song playing')));
      }

      final isPlaying = _viewModel.isPlaying.value;
      final position = _viewModel.position.value;
      final duration = _viewModel.duration.value;
      final shuffleMode = _viewModel.shuffleMode.value;
      final repeatMode = _viewModel.repeatMode.value;

      final progress = duration.inMilliseconds > 0
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0;

      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Left side - Player controls
                  Expanded(
                    flex: 1,
                    child: _buildPlayerControls(
                      context,
                      currentSong: currentSong,
                      isPlaying: isPlaying,
                      position: position,
                      duration: duration,
                      progress: progress,
                      shuffleMode: shuffleMode,
                      repeatMode: repeatMode,
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    color: AppTheme.dividerColor.withValues(alpha: 0.3),
                  ),
                  // Right side - Lyrics
                  Expanded(flex: 1, child: LyricsView(position: position)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlayerControls(
    BuildContext context, {
    required dynamic currentSong,
    required bool isPlaying,
    required Duration position,
    required Duration duration,
    required double progress,
    required bool shuffleMode,
    required RepeatMode repeatMode,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => context.router.maybePop(),
        ),
        title: const Text('NOW PLAYING'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppTheme.cardBackground,
            onSelected: (value) {
              switch (value) {
                case 'metadata':
                  context.router.push(
                    DesktopMetadataEditorRoute(song: currentSong),
                  );
                  break;
                case 'lyrics':
                  context.router.push(
                    MobileLyricsEditorRoute(song: currentSong),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'metadata',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Metadata'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'lyrics',
                child: Row(
                  children: [
                    Icon(Icons.lyrics, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Lyrics'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album cover
            AlbumCover(
              imagePath: currentSong.albumArtPath,
              size: 300,
              borderRadius: 16,
            ),

            const SizedBox(height: 32),

            // Song info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentSong.artist != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          currentSong.artist!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
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
                    currentSong.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: currentSong.isFavorite ? AppTheme.accentColor : null,
                  ),
                  onPressed: _viewModel.toggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.queue_music),
                  onPressed: () =>
                      context.router.push(const DesktopQueueRoute()),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress bar
            Row(
              children: [
                Text(
                  _viewModel.positionText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: _viewModel.seekToPercent,
                      activeColor: AppTheme.accentColor,
                      inactiveColor: AppTheme.dividerColor,
                    ),
                  ),
                ),
                Text(
                  _viewModel.durationText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: shuffleMode
                        ? AppTheme.accentColor
                        : AppTheme.textSecondary,
                  ),
                  onPressed: _viewModel.toggleShuffle,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 36),
                  onPressed: _viewModel.previous,
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36,
                      color: AppTheme.backgroundColor,
                    ),
                    onPressed: _viewModel.togglePlayPause,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 36),
                  onPressed: _viewModel.next,
                ),
                IconButton(
                  icon: Icon(
                    repeatMode == RepeatMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                    color: repeatMode != RepeatMode.off
                        ? AppTheme.accentColor
                        : AppTheme.textSecondary,
                  ),
                  onPressed: _viewModel.cycleRepeatMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
