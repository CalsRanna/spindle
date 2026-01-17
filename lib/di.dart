import 'package:get_it/get_it.dart';
import 'package:spindle/page/desktop/favorites/favorites_view_model.dart';
import 'package:spindle/page/desktop/import/import_view_model.dart';
import 'package:spindle/page/desktop/library/library_view_model.dart';
import 'package:spindle/page/desktop/player/player_view_model.dart';
import 'package:spindle/page/desktop/queue/queue_view_model.dart';
import 'package:spindle/page/desktop/search/search_view_model.dart';
import 'package:spindle/page/desktop/wifi_transfer/wifi_transfer_view_model.dart';

class DI {
  static Future<void> ensureInitialized() async {
    final getIt = GetIt.instance;

    // ViewModels (shared between desktop and mobile)
    getIt.registerLazySingleton<LibraryViewModel>(() => LibraryViewModel());
    getIt.registerLazySingleton<PlayerViewModel>(() => PlayerViewModel());
    getIt.registerLazySingleton<FavoritesViewModel>(() => FavoritesViewModel());
    getIt.registerLazySingleton<WiFiTransferViewModel>(() => WiFiTransferViewModel());
    getIt.registerFactory<ImportViewModel>(() => ImportViewModel());
    getIt.registerFactory<SearchViewModel>(() => SearchViewModel());
    getIt.registerFactory<QueueViewModel>(() => QueueViewModel());

    // Set up favorite change callback to sync state across ViewModels
    PlayerViewModel.onFavoriteChanged = () {
      getIt.get<FavoritesViewModel>().loadFavorites();
      getIt.get<LibraryViewModel>().loadSongs();
    };

    FavoritesViewModel.onFavoriteChanged = () {
      getIt.get<LibraryViewModel>().loadSongs();
    };
  }
}
