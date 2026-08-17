import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/compass/domain/entity/compass_location_status_entity.dart';
import 'package:azkark/features/refactor/compass/domain/repository/compass_repository.dart';

class CheckCompassLocationStatusUseCase {
  const CheckCompassLocationStatusUseCase(this._repository);

  final CompassRepository _repository;

  Future<Result<CompassLocationStatusEntity>> call() =>
      _repository.checkLocationStatus();
}
