import 'package:azkark/features/refactor/compass/domain/entity/compass_location_status_entity.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart' show LocationStatus;
import 'package:geolocator/geolocator.dart' show LocationPermission;

/// Data-layer DTO wrapping `flutter_qiblah`'s [LocationStatus] plugin type.
class CompassLocationStatusModel {
  const CompassLocationStatusModel({
    required bool enabled,
    required LocationPermission permission,
  })  : _enabled = enabled,
        _permission = permission;

  factory CompassLocationStatusModel.fromPlugin(LocationStatus status) =>
      CompassLocationStatusModel(
        enabled: status.enabled,
        permission: status.status,
      );

  final bool _enabled;
  final LocationPermission _permission;

  bool get enabled => _enabled;

  LocationPermission get permission => _permission;

  CompassLocationStatusEntity toEntity() => CompassLocationStatusEntity(
        serviceEnabled: _enabled,
        permission: switch (_permission) {
          LocationPermission.always ||
          LocationPermission.whileInUse =>
            CompassPermissionStatus.granted,
          LocationPermission.denied => CompassPermissionStatus.denied,
          LocationPermission.deniedForever =>
            CompassPermissionStatus.deniedForever,
          LocationPermission.unableToDetermine =>
            CompassPermissionStatus.unavailable,
        },
      );
}
