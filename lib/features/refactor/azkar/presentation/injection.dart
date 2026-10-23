import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/azkar/data/datasource/local/azkar_local_datasource.dart';
import 'package:azkark/features/refactor/azkar/data/repository/azkar_repository_imp.dart';
import 'package:azkark/features/refactor/azkar/domain/repository/azkar_repository.dart';
import 'package:azkark/features/refactor/azkar/domain/usecase/get_azkar_use_case.dart';
import 'package:azkark/features/refactor/azkar/presentation/modules/azkar_list/azkar_list_view_model.dart';
import 'package:azkark/features/refactor/categories/domain/usecase/update_category_favorite_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/get_settings_use_case.dart';
import 'package:azkark/providers.dart';

/// Registers the azkar refactor slice with GetIt. Called once from
/// `lib/injection.dart` — **after** the categories and settings slices,
/// whose use cases [AzkarListViewModel] depends on.
Future<void> initAzkarRefactorFeatures() async {
  // Registered by the categories slice as well; guarded there and here so
  // whichever init runs first wins.
  if (!getIt.isRegistered<DatabaseHelper>()) {
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  }

  if (!getIt.isRegistered<AzkarLocalDataSource>()) {
    getIt.registerLazySingleton<AzkarLocalDataSource>(
      () => AzkarLocalDataSource(getIt<DatabaseHelper>()),
    );
  }

  if (!getIt.isRegistered<AzkarRepository>()) {
    getIt.registerLazySingleton<AzkarRepository>(
      () => AzkarRepositoryImp(getIt<AzkarLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetAzkarUseCase>()) {
    getIt.registerLazySingleton<GetAzkarUseCase>(
      () => GetAzkarUseCase(getIt<AzkarRepository>()),
    );
  }

  if (!getIt.isRegistered<AzkarListViewModel>()) {
    getIt.registerFactory<AzkarListViewModel>(
      () => AzkarListViewModel(
        getAzkar: getIt<GetAzkarUseCase>(),
        getSettings: getIt<GetSettingsUseCase>(),
        updateCategoryFavorite: getIt<UpdateCategoryFavoriteUseCase>(),
      ),
    );
  }
}
