// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:flutter/material.dart' as _i23;
import 'package:spindle/entity/song.dart' as _i24;
import 'package:spindle/page/desktop/favorites/favorites_page.dart' as _i1;
import 'package:spindle/page/desktop/import/import_page.dart' as _i2;
import 'package:spindle/page/desktop/library/library_page.dart' as _i3;
import 'package:spindle/page/desktop/main/main_page.dart' as _i4;
import 'package:spindle/page/desktop/metadata_editor/metadata_editor_page.dart'
    as _i5;
import 'package:spindle/page/desktop/player/player_page.dart' as _i6;
import 'package:spindle/page/desktop/queue/queue_page.dart' as _i7;
import 'package:spindle/page/desktop/search/search_page.dart' as _i8;
import 'package:spindle/page/desktop/settings/settings_page.dart' as _i9;
import 'package:spindle/page/desktop/wifi_transfer/wifi_transfer_page.dart'
    as _i10;
import 'package:spindle/page/mobile/favorites/favorites_page.dart' as _i11;
import 'package:spindle/page/mobile/import/import_page.dart' as _i12;
import 'package:spindle/page/mobile/library/library_page.dart' as _i13;
import 'package:spindle/page/mobile/lyrics_editor/lyrics_editor_page.dart'
    as _i14;
import 'package:spindle/page/mobile/main/main_page.dart' as _i15;
import 'package:spindle/page/mobile/metadata_editor/metadata_editor_page.dart'
    as _i16;
import 'package:spindle/page/mobile/player/player_page.dart' as _i17;
import 'package:spindle/page/mobile/queue/queue_page.dart' as _i18;
import 'package:spindle/page/mobile/search/search_page.dart' as _i19;
import 'package:spindle/page/mobile/settings/settings_page.dart' as _i20;
import 'package:spindle/page/mobile/wifi_transfer/wifi_transfer_page.dart'
    as _i21;

/// generated route for
/// [_i1.DesktopFavoritesPage]
class DesktopFavoritesRoute extends _i22.PageRouteInfo<void> {
  const DesktopFavoritesRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopFavoritesRoute.name, initialChildren: children);

  static const String name = 'DesktopFavoritesRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i1.DesktopFavoritesPage();
    },
  );
}

/// generated route for
/// [_i2.DesktopImportPage]
class DesktopImportRoute extends _i22.PageRouteInfo<void> {
  const DesktopImportRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopImportRoute.name, initialChildren: children);

  static const String name = 'DesktopImportRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.DesktopImportPage();
    },
  );
}

/// generated route for
/// [_i3.DesktopLibraryPage]
class DesktopLibraryRoute extends _i22.PageRouteInfo<void> {
  const DesktopLibraryRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopLibraryRoute.name, initialChildren: children);

  static const String name = 'DesktopLibraryRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i3.DesktopLibraryPage();
    },
  );
}

/// generated route for
/// [_i4.DesktopMainPage]
class DesktopMainRoute extends _i22.PageRouteInfo<void> {
  const DesktopMainRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopMainRoute.name, initialChildren: children);

  static const String name = 'DesktopMainRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i4.DesktopMainPage();
    },
  );
}

/// generated route for
/// [_i5.DesktopMetadataEditorPage]
class DesktopMetadataEditorRoute
    extends _i22.PageRouteInfo<DesktopMetadataEditorRouteArgs> {
  DesktopMetadataEditorRoute({
    _i23.Key? key,
    required _i24.Song song,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         DesktopMetadataEditorRoute.name,
         args: DesktopMetadataEditorRouteArgs(key: key, song: song),
         initialChildren: children,
       );

  static const String name = 'DesktopMetadataEditorRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DesktopMetadataEditorRouteArgs>();
      return _i5.DesktopMetadataEditorPage(key: args.key, song: args.song);
    },
  );
}

class DesktopMetadataEditorRouteArgs {
  const DesktopMetadataEditorRouteArgs({this.key, required this.song});

  final _i23.Key? key;

  final _i24.Song song;

  @override
  String toString() {
    return 'DesktopMetadataEditorRouteArgs{key: $key, song: $song}';
  }
}

/// generated route for
/// [_i6.DesktopPlayerPage]
class DesktopPlayerRoute extends _i22.PageRouteInfo<void> {
  const DesktopPlayerRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopPlayerRoute.name, initialChildren: children);

  static const String name = 'DesktopPlayerRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i6.DesktopPlayerPage();
    },
  );
}

/// generated route for
/// [_i7.DesktopQueuePage]
class DesktopQueueRoute extends _i22.PageRouteInfo<void> {
  const DesktopQueueRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopQueueRoute.name, initialChildren: children);

  static const String name = 'DesktopQueueRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i7.DesktopQueuePage();
    },
  );
}

/// generated route for
/// [_i8.DesktopSearchPage]
class DesktopSearchRoute extends _i22.PageRouteInfo<void> {
  const DesktopSearchRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopSearchRoute.name, initialChildren: children);

  static const String name = 'DesktopSearchRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i8.DesktopSearchPage();
    },
  );
}

/// generated route for
/// [_i9.DesktopSettingsPage]
class DesktopSettingsRoute extends _i22.PageRouteInfo<void> {
  const DesktopSettingsRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopSettingsRoute.name, initialChildren: children);

  static const String name = 'DesktopSettingsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i9.DesktopSettingsPage();
    },
  );
}

/// generated route for
/// [_i10.DesktopWifiTransferPage]
class DesktopWifiTransferRoute extends _i22.PageRouteInfo<void> {
  const DesktopWifiTransferRoute({List<_i22.PageRouteInfo>? children})
    : super(DesktopWifiTransferRoute.name, initialChildren: children);

  static const String name = 'DesktopWifiTransferRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i10.DesktopWifiTransferPage();
    },
  );
}

/// generated route for
/// [_i11.MobileFavoritesPage]
class MobileFavoritesRoute extends _i22.PageRouteInfo<void> {
  const MobileFavoritesRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileFavoritesRoute.name, initialChildren: children);

  static const String name = 'MobileFavoritesRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.MobileFavoritesPage();
    },
  );
}

/// generated route for
/// [_i12.MobileImportPage]
class MobileImportRoute extends _i22.PageRouteInfo<void> {
  const MobileImportRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileImportRoute.name, initialChildren: children);

  static const String name = 'MobileImportRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i12.MobileImportPage();
    },
  );
}

/// generated route for
/// [_i13.MobileLibraryPage]
class MobileLibraryRoute extends _i22.PageRouteInfo<void> {
  const MobileLibraryRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileLibraryRoute.name, initialChildren: children);

  static const String name = 'MobileLibraryRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i13.MobileLibraryPage();
    },
  );
}

/// generated route for
/// [_i14.MobileLyricsEditorPage]
class MobileLyricsEditorRoute
    extends _i22.PageRouteInfo<MobileLyricsEditorRouteArgs> {
  MobileLyricsEditorRoute({
    _i23.Key? key,
    required _i24.Song song,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         MobileLyricsEditorRoute.name,
         args: MobileLyricsEditorRouteArgs(key: key, song: song),
         initialChildren: children,
       );

  static const String name = 'MobileLyricsEditorRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MobileLyricsEditorRouteArgs>();
      return _i14.MobileLyricsEditorPage(key: args.key, song: args.song);
    },
  );
}

class MobileLyricsEditorRouteArgs {
  const MobileLyricsEditorRouteArgs({this.key, required this.song});

  final _i23.Key? key;

  final _i24.Song song;

  @override
  String toString() {
    return 'MobileLyricsEditorRouteArgs{key: $key, song: $song}';
  }
}

/// generated route for
/// [_i15.MobileMainPage]
class MobileMainRoute extends _i22.PageRouteInfo<void> {
  const MobileMainRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileMainRoute.name, initialChildren: children);

  static const String name = 'MobileMainRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i15.MobileMainPage();
    },
  );
}

/// generated route for
/// [_i16.MobileMetadataEditorPage]
class MobileMetadataEditorRoute
    extends _i22.PageRouteInfo<MobileMetadataEditorRouteArgs> {
  MobileMetadataEditorRoute({
    _i23.Key? key,
    required _i24.Song song,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         MobileMetadataEditorRoute.name,
         args: MobileMetadataEditorRouteArgs(key: key, song: song),
         initialChildren: children,
       );

  static const String name = 'MobileMetadataEditorRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MobileMetadataEditorRouteArgs>();
      return _i16.MobileMetadataEditorPage(key: args.key, song: args.song);
    },
  );
}

class MobileMetadataEditorRouteArgs {
  const MobileMetadataEditorRouteArgs({this.key, required this.song});

  final _i23.Key? key;

  final _i24.Song song;

  @override
  String toString() {
    return 'MobileMetadataEditorRouteArgs{key: $key, song: $song}';
  }
}

/// generated route for
/// [_i17.MobilePlayerPage]
class MobilePlayerRoute extends _i22.PageRouteInfo<void> {
  const MobilePlayerRoute({List<_i22.PageRouteInfo>? children})
    : super(MobilePlayerRoute.name, initialChildren: children);

  static const String name = 'MobilePlayerRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i17.MobilePlayerPage();
    },
  );
}

/// generated route for
/// [_i18.MobileQueuePage]
class MobileQueueRoute extends _i22.PageRouteInfo<void> {
  const MobileQueueRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileQueueRoute.name, initialChildren: children);

  static const String name = 'MobileQueueRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i18.MobileQueuePage();
    },
  );
}

/// generated route for
/// [_i19.MobileSearchPage]
class MobileSearchRoute extends _i22.PageRouteInfo<void> {
  const MobileSearchRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileSearchRoute.name, initialChildren: children);

  static const String name = 'MobileSearchRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i19.MobileSearchPage();
    },
  );
}

/// generated route for
/// [_i20.MobileSettingsPage]
class MobileSettingsRoute extends _i22.PageRouteInfo<void> {
  const MobileSettingsRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileSettingsRoute.name, initialChildren: children);

  static const String name = 'MobileSettingsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i20.MobileSettingsPage();
    },
  );
}

/// generated route for
/// [_i21.MobileWifiTransferPage]
class MobileWifiTransferRoute extends _i22.PageRouteInfo<void> {
  const MobileWifiTransferRoute({List<_i22.PageRouteInfo>? children})
    : super(MobileWifiTransferRoute.name, initialChildren: children);

  static const String name = 'MobileWifiTransferRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i21.MobileWifiTransferPage();
    },
  );
}
