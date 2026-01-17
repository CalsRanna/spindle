import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/search/search_view_model.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/song_tile.dart';

@RoutePage()
class DesktopSearchPage extends StatefulWidget {
  const DesktopSearchPage({super.key});

  @override
  State<DesktopSearchPage> createState() => _DesktopSearchPageState();
}

class _DesktopSearchPageState extends State<DesktopSearchPage> {
  late final SearchViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<SearchViewModel>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final query = _viewModel.searchQuery.value;
      final results = _viewModel.results.value;
      final isSearching = _viewModel.isSearching.value;
      final currentSong = _viewModel.currentSong.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('SEARCH'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, albums...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  suffixIcon: query.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _viewModel.search('');
                          },
                        ),
                ),
                onChanged: _viewModel.search,
              ),
            ),

            // Results
            Expanded(
              child: _buildContent(query, results, isSearching, currentSong),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContent(String query, List results, bool isSearching, currentSong) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Search for your music',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentColor,
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return SongTile(
          song: song,
          isPlaying: currentSong?.id == song.id,
          onTap: () => _viewModel.playSong(song),
        );
      },
    );
  }
}
