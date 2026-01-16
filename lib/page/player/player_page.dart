import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/player/player_view_model.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';
import 'package:spindle/widget/blur_background.dart';

@RoutePage()
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final PlayerViewModel _viewModel;
  final _audioService = AudioService.instance;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<PlayerViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _audioService.currentSong.watch(context);

    if (currentSong == null) {
      return const Scaffold(
        body: Center(
          child: Text('No song playing'),
        ),
      );
    }

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
          child: Column(
            children: [
              // Top bar
              Padding(
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
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Album cover
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AlbumCover(
                  imagePath: currentSong.albumArtPath,
                  size: MediaQuery.of(context).size.width - 80,
                  borderRadius: 16,
                ),
              ),

              const Spacer(),

              // Song info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
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
                        color: currentSong.isFavorite
                            ? AppTheme.accentColor
                            : null,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
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
              ),

              const SizedBox(height: 16),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
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
              ),

              const SizedBox(height: 24),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'LYRICS',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'AIRPLAY',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.router.push(const QueueRoute()),
                      child: const Text(
                        'QUEUE',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
