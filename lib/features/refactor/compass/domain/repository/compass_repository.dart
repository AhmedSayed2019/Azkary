import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/compass/domain/entity/compass_location_status_entity.dart';
import 'package:azkark/features/refactor/compass/domain/entity/qibla_direction_entity.dart';

/// Contract for reading GPS/permission status and streaming live qibla
/// direction readings. Implemented by [CompassRepositoryImp] in the data
/// layer; use cases depend on this abstraction only.
abstract interface class CompassRepository {
  /// Checks whether location services are enabled and what permission the
  /// app currently holds, without prompting the user.
  Future<Result<CompassLocationStatusEntity>> checkLocationStatus();

  /// Prompts the user for location permission and returns the resulting
  /// status.
  Future<Result<CompassLocationStatusEntity>> requestPermission();

  /// Live stream combining the compass heading with the calculated qibla
  /// bearing. Only safe to subscribe to once [checkLocationStatus] (or
  /// [requestPermission]) reports `isReady == true`.
  Stream<QiblaDirectionEntity> qiblaDirectionStream();

  /// Releases the underlying sensor/location stream subscriptions.
  void disposeSensors();
}
