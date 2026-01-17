import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/entity/song.dart';
import 'package:spindle/page/desktop/favorites/favorites_view_model.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/song_tile.dart';

@RoutePage()
class DesktopFavoritesPage extends StatefulWidget {
  const DesktopFavoritesPage({super.key});

  @override
  State<DesktopFavoritesPage> createState() => _DesktopFavoritesPageState();
}

class _DesktopFavoritesPageState extends State<DesktopFavoritesPage> {
  late final FavoritesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<FavoritesViewModel>();
    _viewModel.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _viewModel.isLoading.watch(context);
    final songs = _viewModel.songs.watch(context);
    final currentSong = AudioService.instance.currentSong.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAVORITES'),
        actions: [
          if (songs.isNotEmpty)
            TextButton.icon(
              onPressed: _viewModel.playAll,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('PLAY ALL'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.accentColor),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : songs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No favorites yet',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the heart icon on a song to add it here',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _viewModel.loadFavorites,
                  color: AppTheme.accentColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SongTile(
                        song: song,
                        isPlaying: currentSong?.id == song.id,
                        onTap: () => _viewModel.playSong(song),
                        onMoreTap: () => _showSongOptions(context, song),
                      );
                    },
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
                leading: const Icon(Icons.favorite, color: AppTheme.accentColor),
                title: const Text('Remove from Favorites'),
                onTap: () async {
                  Navigator.pop(context);
                  await _viewModel.toggleFavorite(song);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
