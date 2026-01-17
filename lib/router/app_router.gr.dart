// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i19;
import 'package:flutter/material.dart' as _i20;
import 'package:spindle/entity/song.dart' as _i21;
import 'package:spindle/page/desktop/favorites/favorites_page.dart' as _i1;
import 'package:spindle/page/desktop/import/import_page.dart' as _i2;
import 'package:spindle/page/desktop/library/library_page.dart' as _i3;
import 'package:spindle/page/desktop/lyrics_editor/lyrics_editor_page.dart'
    as _i4;
import 'package:spindle/page/desktop/main/main_page.dart' as _i5;
import 'package:spindle/page/desktop/player/player_page.dart' as _i6;
import 'package:spindle/page/desktop/queue/queue_page.dart' as _i7;
import 'package:spindle/page/desktop/search/search_page.dart' as _i8;
import 'package:spindle/page/desktop/settings/settings_page.dart' as _i9;
import 'package:spindle/page/mobile/favorites/favorites_page.dart' as _i10;
import 'package:spindle/page/mobile/import/import_page.dart' as _i11;
import 'package:spindle/page/mobile/library/library_page.dart' as _i12;
import 'package:spindle/page/mobile/lyrics_editor/lyrics_editor_page.dart'
    as _i13;
import 'package:spindle/page/mobile/main/main_page.dart' as _i14;
import 'package:spindle/page/mobile/player/player_page.dart' as _i15;
import 'package:spindle/page/mobile/queue/queue_page.dart' as _i16;
import 'package:spindle/page/mobile/search/search_page.dart' as _i17;
import 'package:spindle/page/mobile/settings/settings_page.dart' as _i18;

/// generated route for
/// [_i1.DesktopFavoritesPage]
class DesktopFavoritesRoute extends _i19.PageRouteInfo<void> {
  const DesktopFavoritesRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopFavoritesRoute.name, initialChildren: children);

  static const String name = 'DesktopFavoritesRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i1.DesktopFavoritesPage();
    },
  );
}

/// generated route for
/// [_i2.DesktopImportPage]
class DesktopImportRoute extends _i19.PageRouteInfo<void> {
  const DesktopImportRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopImportRoute.name, initialChildren: children);

  static const String name = 'DesktopImportRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i2.DesktopImportPage();
    },
  );
}

/// generated route for
/// [_i3.DesktopLibraryPage]
class DesktopLibraryRoute extends _i19.PageRouteInfo<void> {
  const DesktopLibraryRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopLibraryRoute.name, initialChildren: children);

  static const String name = 'DesktopLibraryRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i3.DesktopLibraryPage();
    },
  );
}

/// generated route for
/// [_i4.DesktopLyricsEditorPage]
class DesktopLyricsEditorRoute
    extends _i19.PageRouteInfo<DesktopLyricsEditorRouteArgs> {
  DesktopLyricsEditorRoute({
    _i20.Key? key,
    required _i21.Song song,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         DesktopLyricsEditorRoute.name,
         args: DesktopLyricsEditorRouteArgs(key: key, song: song),
         initialChildren: children,
       );

  static const String name = 'DesktopLyricsEditorRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DesktopLyricsEditorRouteArgs>();
      return _i4.DesktopLyricsEditorPage(key: args.key, song: args.song);
    },
  );
}

class DesktopLyricsEditorRouteArgs {
  const DesktopLyricsEditorRouteArgs({this.key, required this.song});

  final _i20.Key? key;

  final _i21.Song song;

  @override
  String toString() {
    return 'DesktopLyricsEditorRouteArgs{key: $key, song: $song}';
  }
}

/// generated route for
/// [_i5.DesktopMainPage]
class DesktopMainRoute extends _i19.PageRouteInfo<void> {
  const DesktopMainRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopMainRoute.name, initialChildren: children);

  static const String name = 'DesktopMainRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i5.DesktopMainPage();
    },
  );
}

/// generated route for
/// [_i6.DesktopPlayerPage]
class DesktopPlayerRoute extends _i19.PageRouteInfo<void> {
  const DesktopPlayerRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopPlayerRoute.name, initialChildren: children);

  static const String name = 'DesktopPlayerRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i6.DesktopPlayerPage();
    },
  );
}

/// generated route for
/// [_i7.DesktopQueuePage]
class DesktopQueueRoute extends _i19.PageRouteInfo<void> {
  const DesktopQueueRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopQueueRoute.name, initialChildren: children);

  static const String name = 'DesktopQueueRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i7.DesktopQueuePage();
    },
  );
}

/// generated route for
/// [_i8.DesktopSearchPage]
class DesktopSearchRoute extends _i19.PageRouteInfo<void> {
  const DesktopSearchRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopSearchRoute.name, initialChildren: children);

  static const String name = 'DesktopSearchRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i8.DesktopSearchPage();
    },
  );
}

/// generated route for
/// [_i9.DesktopSettingsPage]
class DesktopSettingsRoute extends _i19.PageRouteInfo<void> {
  const DesktopSettingsRoute({List<_i19.PageRouteInfo>? children})
    : super(DesktopSettingsRoute.name, initialChildren: children);

  static const String name = 'DesktopSettingsRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i9.DesktopSettingsPage();
    },
  );
}

/// generated route for
/// [_i10.MobileFavoritesPage]
class MobileFavoritesRoute extends _i19.PageRouteInfo<void> {
  const MobileFavoritesRoute({List<_i19.PageRouteInfo>? children})
    : super(MobileFavoritesRoute.name, initialChildren: children);

  static const String name = 'MobileFavoritesRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i10.MobileFavoritesPage();
    },
  );
}

/// generated route for
/// [_i11.MobileImportPage]
class MobileImportRoute extends _i19.PageRouteInfo<void> {
  const MobileImportRoute({List<_i19.PageRouteInfo>? children})
    : super(MobileImportRoute.name, initialChildren: children);

  static const String name = 'MobileImportRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i11.MobileImportPage();
    },
  );
}

/// generated route for
/// [_i12.MobileLibraryPage]
class MobileLibraryRoute extends _i19.PageRouteInfo<void> {
  const MobileLibraryRoute({List<_i19.PageRouteInfo>? children})
    : super(MobileLibraryRoute.name, initialChildren: children);

  static const String name = 'MobileLibraryRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i12.MobileLibraryPage();
    },
  );
}

/// generated route for
/// [_i13.MobileLyricsEditorPage]
class MobileLyricsEditorRoute
    extends _i19.PageRouteInfo<MobileLyricsEditorRouteArgs> {
  MobileLyricsEditorRoute({
    _i20.Key? key,
    required _i21.Song song,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         MobileLyricsEditorRoute.name,
         args: MobileLyricsEditorRouteArgs(key: key, song: song),
         initialChildren: children,
       );

  static const String name = 'MobileLyricsEditorRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MobileLyricsEditorRouteArgs>();
      return _i13.MobileLyricsEditorPage(key: args.key, song: args.song);
    },
  );
}

class MobileLyricsEditorRouteArgs {
  const MobileLyricsEditorRouteArgs({this.key, required this.song});

  final _i20.Key? key;

  final _i21.Song song;

  @override
  String toString() {
    return 'MobileLyricsEditorRouteArgs{key: $key, song: $song}';
  }
}

/// generated route for
/// [_i14.MobileMainPage]
class MobileMainRoute extends _i19.PageRouteInfo<void> {
  const MobileMainRoute({List<_i19.PageRouteInfo>? children})
    : super(MobileMainRoute.name, initialChildren: children);

  static const String name = 'MobileMainRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i14.MobileMainPage();
    },
  );
}

/// generated route for
/// [_i15.MobilePlayerPage]
class MobilePlayerRoute extends _i19.PageRouteInfo<void> {
  const MobilePlayerRoute({List<_i19.PageRouteInfo>? children})
    : super(MobilePlayerRoute.name, initialChildren: children);

  static const String name = 'MobilePlayerRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i15.MobilePlayerPage();
    },
  );
}

/// generated route for
/// [_i16.MobileQueuePage]
class MobileQueueRoute extends _i19.PageRouteInfo<void> {
  const MobileQueueRoute({List<_i19.PageRouteInfo>? children})
    : super(MobileQueueRoute.name, initialChildren: children);

  static const String name = 'MobileQueueRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i16.MobileQueuePage();
    },
  );
}

/// generated route for
/// [_i17.MobileSearchPage]
class MobileSearchRoute extends _i19.PageRouteInfo<void> {
  const MobileSearchRoute({List<_i19.PageRouteInfo>? children})
    : super(MobileSearchRoute.name, initialChildren: children);

  static const String name = 'MobileSearchRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i17.MobileSearchPage();
    },
  );
}

/// generated route for
/// [_i18.MobileSettingsPage]
class MobileSettingsRoute extends _i19.PageRouteInfo<void> {
  const MobileSettingsRoute({List<_i19.PageRouteInfo>? children})
    : super(MobileSettingsRoute.name, initialChildren: children);

  static const String name = 'MobileSettingsRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i18.MobileSettingsPage();
    },
  );
}
