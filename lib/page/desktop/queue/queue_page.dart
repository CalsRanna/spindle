import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spindle/page/desktop/queue/queue_view_model.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/widget/album_cover.dart';

@RoutePage()
class DesktopQueuePage extends StatefulWidget {
  const DesktopQueuePage({super.key});

  @override
  State<DesktopQueuePage> createState() => _DesktopQueuePageState();
}

class _DesktopQueuePageState extends State<DesktopQueuePage> {
  late final QueueViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance.get<QueueViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final queue = _viewModel.queue.value;
      final currentIndex = _viewModel.currentIndex.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('QUEUE'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
          actions: [
            TextButton(
              onPressed: _viewModel.clearQueue,
              child: const Text(
                'CLEAR',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            ),
          ],
        ),
        body: queue.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue_music,
                      size: 64,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Queue is empty',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : ReorderableListView.builder(
                itemCount: queue.length,
                onReorder: _viewModel.reorderQueue,
                itemBuilder: (context, index) {
                  final song = queue[index];
                  final isCurrent = index == currentIndex;
                  final isUpNext = index > currentIndex;

                  // Add section headers
                  Widget? header;
                  if (index == currentIndex) {
                    header = _buildSectionHeader('NOW PLAYING');
                  } else if (index == currentIndex + 1) {
                    header = _buildSectionHeader('UP NEXT');
                  }

                  return Column(
                    key: ValueKey('${song.id}_$index'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (header != null) header,
                      ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(
                                Icons.drag_handle,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AlbumCover(
                              imagePath: song.albumArtPath,
                              size: 44,
                              isPlaying: isCurrent,
                            ),
                          ],
                        ),
                        title: Text(
                          song.title,
                          style: TextStyle(
                            color: isCurrent
                                ? AppTheme.accentColor
                                : AppTheme.textPrimary,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.displayArtist,
                          style: TextStyle(
                            color: isCurrent
                                ? AppTheme.accentColor.withValues(alpha: 0.7)
                                : AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isUpNext
                            ? IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () =>
                                    _viewModel.removeFromQueue(index),
                              )
                            : null,
                        onTap: () => _viewModel.playSongAt(index),
                      ),
                    ],
                  );
                },
              ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
