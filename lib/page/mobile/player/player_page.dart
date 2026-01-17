import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';
import 'package:spindle/widget/blur_background.dart';

@RoutePage()
class MobilePlayerPage extends StatefulWidget {
  const MobilePlayerPage({super.key});

  @override
  State<MobilePlayerPage> createState() => _MobilePlayerPageState();
}

class _MobilePlayerPageState extends State<MobilePlayerPage> {
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
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => context.router.maybePop(),
          ),
        ),
        body: const Center(child: Text('No song playing')),
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
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

              // Album art
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: AlbumCover(
                      imagePath: currentSong.albumArtPath,
                      size: MediaQuery.of(context).size.width - 64,
                      borderRadius: 16,
                    ),
                  ),
                ),
              ),

              // Song info and controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentSong.displayArtist,
                                style: const TextStyle(
                                  fontSize: 14,
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
                        IconButton(
                          icon: const Icon(Icons.queue_music),
                          onPressed: () =>
                              context.router.push(const MobileQueueRoute()),
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
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                _viewModel.durationText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
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
                              size: 32,
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
