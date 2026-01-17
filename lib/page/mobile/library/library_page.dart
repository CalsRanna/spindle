import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/library/library_view_model.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';
import 'package:spindle/widget/song_tile.dart';

@RoutePage()
class MobileLibraryPage extends StatefulWidget {
  const MobileLibraryPage({super.key});

  @override
  State<MobileLibraryPage> createState() => _MobileLibraryPageState();
}

class _MobileLibraryPageState extends State<MobileLibraryPage>
    with AutoRouteAwareStateMixin {
  late final LibraryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<LibraryViewModel>();
  }

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    _viewModel.loadSongs();
  }

  @override
  void didPopNext() {
    _viewModel.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isLoading = _viewModel.isLoading.value;
      final songs = _viewModel.songs.value;
      final recentlyPlayed = _viewModel.recentlyPlayed.value;
      final currentSong = _viewModel.currentSong.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('LIBRARY'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.router.push(const MobileImportRoute()),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                    context.router.push(const MobileImportRoute()),
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
                    const SliverToBoxAdapter(child: SizedBox(height: 160)),
                  ],
                ),
              ),
      );
    });
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
                  _viewModel.addToQueue(song);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  song.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: song.isFavorite ? AppTheme.accentColor : null,
                ),
                title: Text(
                  song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Metadata'),
                onTap: () {
                  Navigator.pop(context);
                  context.router.push(MobileMetadataEditorRoute(song: song));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, song);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (context) {
        bool deleteFile = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              title: const Text('Delete Song'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to delete "${song.title}"?'),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: deleteFile,
                    onChanged: (value) => setState(() => deleteFile = value ?? false),
                    title: const Text('Also delete the file'),
                    subtitle: const Text(
                      'This will permanently remove the file from your device',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.accentColor,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _viewModel.deleteSong(song, deleteFile: deleteFile);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(deleteFile
                              ? 'Song and file deleted'
                              : 'Song removed from library'),
                          backgroundColor: AppTheme.accentColor,
                        ),
                      );
                    }
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
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
