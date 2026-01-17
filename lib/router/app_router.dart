import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:spindle/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Desktop routes
    AutoRoute(
      page: DesktopMainRoute.page,
      initial: _isDesktop,
      children: [
        AutoRoute(page: DesktopLibraryRoute.page, initial: true),
        AutoRoute(page: DesktopSearchRoute.page),
        AutoRoute(page: DesktopFavoritesRoute.page),
        AutoRoute(page: DesktopSettingsRoute.page),
      ],
    ),
    CustomRoute(
      page: DesktopPlayerRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      opaque: false,
    ),
    AutoRoute(page: DesktopQueueRoute.page),
    AutoRoute(page: DesktopImportRoute.page),
    AutoRoute(page: DesktopMetadataEditorRoute.page),
    AutoRoute(page: DesktopWifiTransferRoute.page),

    // Mobile routes
    AutoRoute(
      page: MobileMainRoute.page,
      initial: !_isDesktop,
      children: [
        AutoRoute(page: MobileLibraryRoute.page, initial: true),
      ],
    ),
    AutoRoute(page: MobileSearchRoute.page),
    AutoRoute(page: MobileFavoritesRoute.page),
    AutoRoute(page: MobileSettingsRoute.page),
    CustomRoute(
      page: MobilePlayerRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      opaque: false,
    ),
    AutoRoute(page: MobileQueueRoute.page),
    AutoRoute(page: MobileImportRoute.page),
    AutoRoute(page: MobileLyricsEditorRoute.page),
    AutoRoute(page: MobileMetadataEditorRoute.page),
    AutoRoute(page: MobileWifiTransferRoute.page),
  ];

  static bool get _isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

final router = AppRouter();
