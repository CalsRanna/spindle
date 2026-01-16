import 'dart:io';

import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/logger_util.dart';

/// Service to manage macOS security-scoped bookmarks
/// This allows the app to retain access to user-selected folders across app restarts
class BookmarkService {
  static final BookmarkService instance = BookmarkService._();

  final _logger = LoggerUtil.instance;
  final _secureBookmarks = SecureBookmarks();

  static const _bookmarksKey = 'folder_bookmarks';

  BookmarkService._();

  /// Save a bookmark for a folder path
  /// Call this after user selects a folder via file picker
  Future<void> saveBookmark(String folderPath) async {
    if (!Platform.isMacOS) return;

    try {
      final dir = Directory(folderPath);
      final bookmark = await _secureBookmarks.bookmark(dir);

      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];

      // Store as "path|bookmark" pairs
      final entry = '$folderPath|$bookmark';

      // Remove existing bookmark for this path if any
      bookmarks.removeWhere((b) => b.startsWith('$folderPath|'));
      bookmarks.add(entry);

      await prefs.setStringList(_bookmarksKey, bookmarks);
      _logger.i('Saved bookmark for: $folderPath');
    } catch (e) {
      _logger.e('Error saving bookmark: $e');
    }
  }

  /// Restore access to all bookmarked folders
  /// Call this on app startup
  Future<void> restoreAllBookmarks() async {
    if (!Platform.isMacOS) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];

      for (final entry in bookmarks) {
        final parts = entry.split('|');
        if (parts.length != 2) continue;

        final path = parts[0];
        final bookmark = parts[1];

        try {
          final resolved = await _secureBookmarks.resolveBookmark(bookmark);
          await _secureBookmarks.startAccessingSecurityScopedResource(resolved);
          _logger.i('Restored access to: $path');
        } catch (e) {
          _logger.w('Failed to restore bookmark for $path: $e');
        }
      }
    } catch (e) {
      _logger.e('Error restoring bookmarks: $e');
    }
  }

  /// Remove bookmark for a folder
  Future<void> removeBookmark(String folderPath) async {
    if (!Platform.isMacOS) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];

      bookmarks.removeWhere((b) => b.startsWith('$folderPath|'));
      await prefs.setStringList(_bookmarksKey, bookmarks);

      _logger.i('Removed bookmark for: $folderPath');
    } catch (e) {
      _logger.e('Error removing bookmark: $e');
    }
  }

  /// Get all bookmarked folder paths
  Future<List<String>> getBookmarkedPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];

    return bookmarks.map((entry) => entry.split('|').first).toList();
  }
}
