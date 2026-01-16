import 'package:get_it/get_it.dart';
import 'package:spindle/page/favorites/favorites_view_model.dart';
import 'package:spindle/page/home/home_view_model.dart';
import 'package:spindle/page/import/import_view_model.dart';
import 'package:spindle/page/library/library_view_model.dart';
import 'package:spindle/page/player/player_view_model.dart';
import 'package:spindle/page/queue/queue_view_model.dart';
import 'package:spindle/page/search/search_view_model.dart';

class DI {
  static Future<void> ensureInitialized() async {
    final getIt = GetIt.instance;

    // ViewModels
    getIt.registerLazySingleton<HomeViewModel>(() => HomeViewModel());
    getIt.registerLazySingleton<LibraryViewModel>(() => LibraryViewModel());
    getIt.registerLazySingleton<PlayerViewModel>(() => PlayerViewModel());
    getIt.registerLazySingleton<FavoritesViewModel>(() => FavoritesViewModel());
    getIt.registerFactory<ImportViewModel>(() => ImportViewModel());
    getIt.registerFactory<SearchViewModel>(() => SearchViewModel());
    getIt.registerFactory<QueueViewModel>(() => QueueViewModel());
  }
}
