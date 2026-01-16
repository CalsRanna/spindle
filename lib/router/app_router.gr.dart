// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:flutter/material.dart' as _i12;
import 'package:spindle/entity/song.dart' as _i13;
import 'package:spindle/page/favorites/favorites_page.dart' as _i1;
import 'package:spindle/page/home/home_page.dart' as _i2;
import 'package:spindle/page/import/import_page.dart' as _i3;
import 'package:spindle/page/library/library_page.dart' as _i4;
import 'package:spindle/page/lyrics_editor/lyrics_editor_page.dart' as _i5;
import 'package:spindle/page/main/main_page.dart' as _i6;
import 'package:spindle/page/player/player_page.dart' as _i7;
import 'package:spindle/page/queue/queue_page.dart' as _i8;
import 'package:spindle/page/search/search_page.dart' as _i9;
import 'package:spindle/page/settings/settings_page.dart' as _i10;

/// generated route for
/// [_i1.FavoritesPage]
class FavoritesRoute extends _i11.PageRouteInfo<void> {
  const FavoritesRoute({List<_i11.PageRouteInfo>? children})
    : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i1.FavoritesPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i11.PageRouteInfo<void> {
  const HomeRoute({List<_i11.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.ImportPage]
class ImportRoute extends _i11.PageRouteInfo<void> {
  const ImportRoute({List<_i11.PageRouteInfo>? children})
    : super(ImportRoute.name, initialChildren: children);

  static const String name = 'ImportRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i3.ImportPage();
    },
  );
}

/// generated route for
/// [_i4.LibraryPage]
class LibraryRoute extends _i11.PageRouteInfo<void> {
  const LibraryRoute({List<_i11.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i4.LibraryPage();
    },
  );
}

/// generated route for
/// [_i5.LyricsEditorPage]
class LyricsEditorRoute extends _i11.PageRouteInfo<LyricsEditorRouteArgs> {
  LyricsEditorRoute({
    _i12.Key? key,
    required _i13.Song song,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         LyricsEditorRoute.name,
         args: LyricsEditorRouteArgs(key: key, song: song),
         initialChildren: children,
       );

  static const String name = 'LyricsEditorRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LyricsEditorRouteArgs>();
      return _i5.LyricsEditorPage(key: args.key, song: args.song);
    },
  );
}

class LyricsEditorRouteArgs {
  const LyricsEditorRouteArgs({this.key, required this.song});

  final _i12.Key? key;

  final _i13.Song song;

  @override
  String toString() {
    return 'LyricsEditorRouteArgs{key: $key, song: $song}';
  }
}

/// generated route for
/// [_i6.MainPage]
class MainRoute extends _i11.PageRouteInfo<void> {
  const MainRoute({List<_i11.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i6.MainPage();
    },
  );
}

/// generated route for
/// [_i7.PlayerPage]
class PlayerRoute extends _i11.PageRouteInfo<void> {
  const PlayerRoute({List<_i11.PageRouteInfo>? children})
    : super(PlayerRoute.name, initialChildren: children);

  static const String name = 'PlayerRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i7.PlayerPage();
    },
  );
}

/// generated route for
/// [_i8.QueuePage]
class QueueRoute extends _i11.PageRouteInfo<void> {
  const QueueRoute({List<_i11.PageRouteInfo>? children})
    : super(QueueRoute.name, initialChildren: children);

  static const String name = 'QueueRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i8.QueuePage();
    },
  );
}

/// generated route for
/// [_i9.SearchPage]
class SearchRoute extends _i11.PageRouteInfo<void> {
  const SearchRoute({List<_i11.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i9.SearchPage();
    },
  );
}

/// generated route for
/// [_i10.SettingsPage]
class SettingsRoute extends _i11.PageRouteInfo<void> {
  const SettingsRoute({List<_i11.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i10.SettingsPage();
    },
  );
}
