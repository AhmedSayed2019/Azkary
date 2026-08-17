import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/asmaallah/data/datasource/local/asma_allah_local_datasource.dart';
import 'package:azkark/features/refactor/asmaallah/data/repository/asma_allah_repository_imp.dart';
import 'package:azkark/features/refactor/asmaallah/domain/repository/asma_allah_repository.dart';
import 'package:azkark/features/refactor/asmaallah/domain/usecase/get_all_asma_allah_use_case.dart';
import 'package:azkark/features/refactor/asmaallah/presentation/modules/asma_allah_list/asma_allah_list_view_model.dart';
import 'package:azkark/providers.dart';

/// Registers the asmaallah (99 names of Allah) refactor slice with GetIt.
/// Called once from `lib/injection.dart` alongside the app's other init
/// calls.
Future<void> initAsmaAllahRefactorFeatures() async {
  // DatabaseHelper() is already an internal singleton (see its `factory`
  // constructor); registering it here just lets it be resolved via GetIt
  // like the rest of this feature's dependencies.
  if (!getIt.isRegistered<DatabaseHelper>()) {
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  }

  if (!getIt.isRegistered<AsmaAllahLocalDataSource>()) {
    getIt.registerLazySingleton<AsmaAllahLocalDataSource>(
      () => AsmaAllahLocalDataSource(getIt<DatabaseHelper>()),
    );
  }

  if (!getIt.isRegistered<AsmaAllahRepository>()) {
    getIt.registerLazySingleton<AsmaAllahRepository>(
      () => AsmaAllahRepositoryImp(getIt<AsmaAllahLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetAllAsmaAllahUseCase>()) {
    getIt.registerLazySingleton<GetAllAsmaAllahUseCase>(
      () => GetAllAsmaAllahUseCase(getIt<AsmaAllahRepository>()),
    );
  }

  if (!getIt.isRegistered<AsmaAllahListViewModel>()) {
    getIt.registerFactory<AsmaAllahListViewModel>(
      () => AsmaAllahListViewModel(
        getAllAsmaAllah: getIt<GetAllAsmaAllahUseCase>(),
      ),
    );
  }
}
