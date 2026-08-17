import 'package:azkark/features/refactor/compass/domain/repository/compass_repository.dart';

/// Stops the underlying compass/location sensor stream. Must be called when
/// the compass screen is left, otherwise the plugin keeps the GPS + magnetic
/// sensor listeners alive (and draining battery) in the background.
class DisposeCompassSensorsUseCase {
  const DisposeCompassSensorsUseCase(this._repository);

  final CompassRepository _repository;

  void call() => _repository.disposeSensors();
}
