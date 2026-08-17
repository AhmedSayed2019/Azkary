import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/sebha/data/datasource/local/sebha_local_datasource.dart';
import 'package:azkark/features/refactor/sebha/data/repository/sebha_repository_imp.dart';
import 'package:azkark/features/refactor/sebha/domain/repository/sebha_repository.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/add_sebha_use_case.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/delete_sebha_use_case.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/get_all_sebha_use_case.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/update_sebha_favorite_use_case.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/update_sebha_use_case.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/add_edit_sebha/add_edit_sebha_view_model.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/sebha_list/sebha_list_view_model.dart';
import 'package:azkark/providers.dart';

/// Registers the sebha (tasbih) refactor slice with GetIt. Called once from
/// `lib/injection.dart` alongside the app's other init calls.
Future<void> initSebhaRefactorFeatures() async {
  // DatabaseHelper() is already an internal singleton (see its `factory`
  // constructor); registering it here just lets it be resolved via GetIt
  // like the rest of this feature's dependencies.
  if (!getIt.isRegistered<DatabaseHelper>()) {
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  }

  if (!getIt.isRegistered<SebhaLocalDataSource>()) {
    getIt.registerLazySingleton<SebhaLocalDataSource>(
      () => SebhaLocalDataSource(getIt<DatabaseHelper>()),
    );
  }

  if (!getIt.isRegistered<SebhaRepository>()) {
    getIt.registerLazySingleton<SebhaRepository>(
      () => SebhaRepositoryImp(getIt<SebhaLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetAllSebhaUseCase>()) {
    getIt.registerLazySingleton<GetAllSebhaUseCase>(
      () => GetAllSebhaUseCase(getIt<SebhaRepository>()),
    );
  }
  if (!getIt.isRegistered<AddSebhaUseCase>()) {
    getIt.registerLazySingleton<AddSebhaUseCase>(
      () => AddSebhaUseCase(getIt<SebhaRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateSebhaUseCase>()) {
    getIt.registerLazySingleton<UpdateSebhaUseCase>(
      () => UpdateSebhaUseCase(getIt<SebhaRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteSebhaUseCase>()) {
    getIt.registerLazySingleton<DeleteSebhaUseCase>(
      () => DeleteSebhaUseCase(getIt<SebhaRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateSebhaFavoriteUseCase>()) {
    getIt.registerLazySingleton<UpdateSebhaFavoriteUseCase>(
      () => UpdateSebhaFavoriteUseCase(getIt<SebhaRepository>()),
    );
  }

  if (!getIt.isRegistered<SebhaListViewModel>()) {
    getIt.registerFactory<SebhaListViewModel>(
      () => SebhaListViewModel(
        getAllSebha: getIt<GetAllSebhaUseCase>(),
        deleteSebha: getIt<DeleteSebhaUseCase>(),
        updateSebhaFavorite: getIt<UpdateSebhaFavoriteUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<AddEditSebhaViewModel>()) {
    getIt.registerFactory<AddEditSebhaViewModel>(
      () => AddEditSebhaViewModel(
        addSebha: getIt<AddSebhaUseCase>(),
        updateSebha: getIt<UpdateSebhaUseCase>(),
      ),
    );
  }
}
