import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/library/library_view_model.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';
import 'package:spindle/widget/song_tile.dart';

@RoutePage()
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutoRouteAwareStateMixin {
  late final LibraryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<LibraryViewModel>();
  }

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    // Called when this tab becomes active again
    _viewModel.loadSongs();
  }

  @override
  void didPopNext() {
    // Called when returning from a pushed route (e.g., Import page)
    _viewModel.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _viewModel.isLoading.watch(context);
    final songs = _viewModel.songs.watch(context);
    final recentlyPlayed = _viewModel.recentlyPlayed.watch(context);
    final currentSong = AudioService.instance.currentSong.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LIBRARY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.router.push(const SearchRoute()),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.router.push(const ImportRoute()),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : RefreshIndicator(
              onRefresh: _viewModel.loadSongs,
              color: AppTheme.accentColor,
              child: CustomScrollView(
                slivers: [
                  // Recently Played Section
                  if (recentlyPlayed.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Recently Played',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 164,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: recentlyPlayed.length,
                              itemBuilder: (context, index) {
                                final song = recentlyPlayed[index];
                                return _RecentlyPlayedCard(
                                  song: song,
                                  onTap: () => _viewModel.playRecentSong(song),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                  // All Songs Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Songs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _viewModel.playAll,
                            icon: const Icon(Icons.play_arrow, size: 20),
                            label: const Text('PLAY ALL'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Songs List
                  if (songs.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.music_off,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No songs yet',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () =>
                                  context.router.push(const ImportRoute()),
                              child: const Text('Import Music'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final song = songs[index];
                        return SongTile(
                          song: song,
                          isPlaying: currentSong?.id == song.id,
                          onTap: () => _viewModel.playSong(song),
                          onMoreTap: () => _showSongOptions(context, song),
                        );
                      }, childCount: songs.length),
                    ),

                  // Bottom padding for mini player
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to Queue'),
                onTap: () {
                  AudioService.instance.addToQueue(song);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  song.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: song.isFavorite ? AppTheme.accentColor : null,
                ),
                title: Text(
                  song.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentlyPlayedCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _RecentlyPlayedCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlbumCover(
              imagePath: song.albumArtPath,
              size: 120,
              borderRadius: 8,
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.displayArtist,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
