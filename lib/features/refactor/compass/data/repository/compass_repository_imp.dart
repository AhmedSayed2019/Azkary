import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/compass/data/datasource/local/compass_local_datasource.dart';
import 'package:azkark/features/refactor/compass/domain/entity/compass_location_status_entity.dart';
import 'package:azkark/features/refactor/compass/domain/entity/qibla_direction_entity.dart';
import 'package:azkark/features/refactor/compass/domain/repository/compass_repository.dart';

class CompassRepositoryImp implements CompassRepository {
  const CompassRepositoryImp(this._localDataSource);

  final CompassLocalDataSource _localDataSource;

  @override
  Future<Result<CompassLocationStatusEntity>> checkLocationStatus() async {
    final result = await _localDataSource.checkLocationStatus();
    return switch (result) {
      Ok(:final data) => Ok(data.toEntity()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<CompassLocationStatusEntity>> requestPermission() async {
    final result = await _localDataSource.requestPermission();
    return switch (result) {
      Ok(:final data) => Ok(data.toEntity()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Stream<QiblaDirectionEntity> qiblaDirectionStream() {
    return _localDataSource.qiblaDirectionStream().map((m) => m.toEntity());
  }

  @override
  void disposeSensors() => _localDataSource.disposeSensors();
}
