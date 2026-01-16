import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/player/player_view_model.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/service/lyrics_service.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';
import 'package:spindle/widget/blur_background.dart';
import 'package:spindle/widget/lyrics_view.dart';

@RoutePage()
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final PlayerViewModel _viewModel;
  final _audioService = AudioService.instance;
  final _lyricsService = LyricsService.instance;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<PlayerViewModel>();
    _loadLyrics();
  }

  void _loadLyrics() {
    final currentSong = _audioService.currentSong.value;
    _lyricsService.loadLyrics(currentSong?.filePath);
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _audioService.currentSong.watch(context);

    if (currentSong == null) {
      return const Scaffold(body: Center(child: Text('No song playing')));
    }

    // Reload lyrics when song changes
    effect(() {
      _lyricsService.loadLyrics(_audioService.currentSong.value?.filePath);
    });

    final isPlaying = _audioService.isPlaying.watch(context);
    final position = _audioService.position.watch(context);
    final duration = _audioService.duration.watch(context);
    final shuffleMode = _audioService.shuffleMode.watch(context);
    final repeatMode = _audioService.repeatMode.watch(context);

    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Scaffold(
      body: BlurBackground(
        imagePath: currentSong.albumArtPath,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return _buildDesktopLayout(
                  context,
                  currentSong: currentSong,
                  isPlaying: isPlaying,
                  position: position,
                  duration: duration,
                  progress: progress,
                  shuffleMode: shuffleMode,
                  repeatMode: repeatMode,
                );
              } else {
                return _buildMobileLayout(
                  context,
                  currentSong: currentSong,
                  isPlaying: isPlaying,
                  position: position,
                  duration: duration,
                  progress: progress,
                  shuffleMode: shuffleMode,
                  repeatMode: repeatMode,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context, {
    required dynamic currentSong,
    required bool isPlaying,
    required Duration position,
    required Duration duration,
    required double progress,
    required bool shuffleMode,
    required RepeatMode repeatMode,
  }) {
    return Column(
      children: [
        _buildTopBar(context),
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
                  albumCoverSize: 300,
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
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, {
    required dynamic currentSong,
    required bool isPlaying,
    required Duration position,
    required Duration duration,
    required double progress,
    required bool shuffleMode,
    required RepeatMode repeatMode,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final albumCoverSize = (screenWidth - 80).clamp(200.0, 400.0);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopBar(context),
          const SizedBox(height: 24),
          _buildPlayerControls(
            context,
            currentSong: currentSong,
            isPlaying: isPlaying,
            position: position,
            duration: duration,
            progress: progress,
            shuffleMode: shuffleMode,
            repeatMode: repeatMode,
            albumCoverSize: albumCoverSize,
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            onPressed: () => context.router.maybePop(),
          ),
          const Text(
            'PLAYING FROM LIBRARY',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              color: AppTheme.textSecondary,
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
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
    required double albumCoverSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album cover
          AlbumCover(
            imagePath: currentSong.albumArtPath,
            size: albumCoverSize,
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
                    const SizedBox(height: 4),
                    Text(
                      currentSong.displayArtist,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () => context.router.push(
                  LyricsEditorRoute(song: currentSong),
                ),
                tooltip: 'Edit lyrics',
              ),
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => context.router.push(const QueueRoute()),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress bar
          Column(
            children: [
              SliderTheme(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _viewModel.positionText,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
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
    );
  }
}
