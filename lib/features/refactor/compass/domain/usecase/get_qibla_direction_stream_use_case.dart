import 'package:azkark/features/refactor/compass/domain/entity/qibla_direction_entity.dart';
import 'package:azkark/features/refactor/compass/domain/repository/compass_repository.dart';

class GetQiblaDirectionStreamUseCase {
  const GetQiblaDirectionStreamUseCase(this._repository);

  final CompassRepository _repository;

  Stream<QiblaDirectionEntity> call() => _repository.qiblaDirectionStream();
}
