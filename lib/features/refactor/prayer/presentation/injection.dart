import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/prayer/data/datasource/local/prayer_local_datasource.dart';
import 'package:azkark/features/refactor/prayer/data/repository/prayer_repository_imp.dart';
import 'package:azkark/features/refactor/prayer/domain/repository/prayer_repository.dart';
import 'package:azkark/features/refactor/prayer/domain/usecase/get_all_prayer_use_case.dart';
import 'package:azkark/features/refactor/prayer/domain/usecase/update_prayer_favorite_use_case.dart';
import 'package:azkark/features/refactor/prayer/presentation/modules/prayer_list/prayer_list_view_model.dart';
import 'package:azkark/providers.dart';

/// Registers the prayer (prayer-guide verses) refactor slice with GetIt.
/// Called once from `lib/injection.dart` alongside the app's other init
/// calls.
Future<void> initPrayerRefactorFeatures() async {
  // DatabaseHelper() is already an internal singleton (see its `factory`
  // constructor); registering it here just lets it be resolved via GetIt
  // like the rest of this feature's dependencies.
  if (!getIt.isRegistered<DatabaseHelper>()) {
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  }

  if (!getIt.isRegistered<PrayerLocalDataSource>()) {
    getIt.registerLazySingleton<PrayerLocalDataSource>(
      () => PrayerLocalDataSource(getIt<DatabaseHelper>()),
    );
  }

  if (!getIt.isRegistered<PrayerRepository>()) {
    getIt.registerLazySingleton<PrayerRepository>(
      () => PrayerRepositoryImp(getIt<PrayerLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetAllPrayerUseCase>()) {
    getIt.registerLazySingleton<GetAllPrayerUseCase>(
      () => GetAllPrayerUseCase(getIt<PrayerRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdatePrayerFavoriteUseCase>()) {
    getIt.registerLazySingleton<UpdatePrayerFavoriteUseCase>(
      () => UpdatePrayerFavoriteUseCase(getIt<PrayerRepository>()),
    );
  }

  if (!getIt.isRegistered<PrayerListViewModel>()) {
    getIt.registerFactory<PrayerListViewModel>(
      () => PrayerListViewModel(
        getAllPrayer: getIt<GetAllPrayerUseCase>(),
        updatePrayerFavorite: getIt<UpdatePrayerFavoriteUseCase>(),
      ),
    );
  }
}
