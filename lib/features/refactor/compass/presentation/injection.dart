import 'package:azkark/features/refactor/compass/data/datasource/local/compass_local_datasource.dart';
import 'package:azkark/features/refactor/compass/data/repository/compass_repository_imp.dart';
import 'package:azkark/features/refactor/compass/domain/repository/compass_repository.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/check_compass_location_status_use_case.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/dispose_compass_sensors_use_case.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/get_qibla_direction_stream_use_case.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/request_compass_location_permission_use_case.dart';
import 'package:azkark/features/refactor/compass/presentation/modules/compass/compass_view_model.dart';
import 'package:azkark/providers.dart';

/// Registers the compass (qibla direction) refactor slice with GetIt. Called
/// once from `lib/injection.dart` alongside the app's other init calls.
Future<void> initCompassRefactorFeatures() async {
  if (!getIt.isRegistered<CompassLocalDataSource>()) {
    getIt.registerLazySingleton<CompassLocalDataSource>(
      () => const CompassLocalDataSource(),
    );
  }

  if (!getIt.isRegistered<CompassRepository>()) {
    getIt.registerLazySingleton<CompassRepository>(
      () => CompassRepositoryImp(getIt<CompassLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<CheckCompassLocationStatusUseCase>()) {
    getIt.registerLazySingleton<CheckCompassLocationStatusUseCase>(
      () => CheckCompassLocationStatusUseCase(getIt<CompassRepository>()),
    );
  }
  if (!getIt.isRegistered<RequestCompassLocationPermissionUseCase>()) {
    getIt.registerLazySingleton<RequestCompassLocationPermissionUseCase>(
      () => RequestCompassLocationPermissionUseCase(getIt<CompassRepository>()),
    );
  }
  if (!getIt.isRegistered<GetQiblaDirectionStreamUseCase>()) {
    getIt.registerLazySingleton<GetQiblaDirectionStreamUseCase>(
      () => GetQiblaDirectionStreamUseCase(getIt<CompassRepository>()),
    );
  }
  if (!getIt.isRegistered<DisposeCompassSensorsUseCase>()) {
    getIt.registerLazySingleton<DisposeCompassSensorsUseCase>(
      () => DisposeCompassSensorsUseCase(getIt<CompassRepository>()),
    );
  }

  if (!getIt.isRegistered<CompassViewModel>()) {
    getIt.registerFactory<CompassViewModel>(
      () => CompassViewModel(
        checkLocationStatus: getIt<CheckCompassLocationStatusUseCase>(),
        requestPermission: getIt<RequestCompassLocationPermissionUseCase>(),
        getQiblaDirectionStream: getIt<GetQiblaDirectionStreamUseCase>(),
        disposeSensors: getIt<DisposeCompassSensorsUseCase>(),
      ),
    );
  }
}
