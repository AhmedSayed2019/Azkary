import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/categories/data/datasource/local/category_local_datasource.dart';
import 'package:azkark/features/refactor/categories/data/repository/category_repository_imp.dart';
import 'package:azkark/features/refactor/categories/domain/repository/category_repository.dart';
import 'package:azkark/features/refactor/categories/domain/usecase/get_all_categories_use_case.dart';
import 'package:azkark/features/refactor/categories/domain/usecase/update_category_favorite_use_case.dart';
import 'package:azkark/features/refactor/categories/presentation/modules/categories_list/categories_list_view_model.dart';
import 'package:azkark/providers.dart';

/// Registers the categories refactor slice with GetIt. Called once from
/// `lib/injection.dart` alongside the app's other init calls.
Future<void> initCategoriesRefactorFeatures() async {
  // DatabaseHelper() is already an internal singleton (see its `factory`
  // constructor); registering it here just lets it be resolved via GetIt
  // like the rest of this feature's dependencies.
  if (!getIt.isRegistered<DatabaseHelper>()) {
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  }

  if (!getIt.isRegistered<CategoryLocalDataSource>()) {
    getIt.registerLazySingleton<CategoryLocalDataSource>(
      () => CategoryLocalDataSource(getIt<DatabaseHelper>()),
    );
  }

  if (!getIt.isRegistered<CategoryRepository>()) {
    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImp(getIt<CategoryLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetAllCategoriesUseCase>()) {
    getIt.registerLazySingleton<GetAllCategoriesUseCase>(
      () => GetAllCategoriesUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateCategoryFavoriteUseCase>()) {
    getIt.registerLazySingleton<UpdateCategoryFavoriteUseCase>(
      () => UpdateCategoryFavoriteUseCase(getIt<CategoryRepository>()),
    );
  }

  if (!getIt.isRegistered<CategoriesListViewModel>()) {
    getIt.registerFactory<CategoriesListViewModel>(
      () => CategoriesListViewModel(
        getAllCategories: getIt<GetAllCategoriesUseCase>(),
        updateCategoryFavorite: getIt<UpdateCategoryFavoriteUseCase>(),
      ),
    );
  }
}
