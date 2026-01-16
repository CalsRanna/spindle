import 'package:auto_route/auto_route.dart';
import 'package:spindle/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainRoute.page,
      initial: true,
      children: [
        AutoRoute(page: LibraryRoute.page, initial: true),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: FavoritesRoute.page),
        AutoRoute(page: SettingsRoute.page),
      ],
    ),
    AutoRoute(page: PlayerRoute.page),
    AutoRoute(page: QueueRoute.page),
    AutoRoute(page: ImportRoute.page),
    AutoRoute(page: LyricsEditorRoute.page),
  ];
}

final router = AppRouter();
