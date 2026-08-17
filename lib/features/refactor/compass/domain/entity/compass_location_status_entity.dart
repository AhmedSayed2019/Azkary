import 'package:equatable/equatable.dart';

/// Pure-Dart mirror of the plugin's `LocationPermission` enum so the domain
/// layer never depends on `package:geolocator`.
enum CompassPermissionStatus {
  granted,
  denied,
  deniedForever,
  unavailable,
}

/// Combined GPS-enabled + permission state needed before the qibla compass
/// can start reading the direction sensor.
class CompassLocationStatusEntity extends Equatable {
  const CompassLocationStatusEntity({
    required bool serviceEnabled,
    required CompassPermissionStatus permission,
  })  : _serviceEnabled = serviceEnabled,
        _permission = permission;

  final bool _serviceEnabled;
  final CompassPermissionStatus _permission;

  bool get serviceEnabled => _serviceEnabled;

  CompassPermissionStatus get permission => _permission;

  /// True once the compass sensor stream is safe to subscribe to.
  bool get isReady =>
      _serviceEnabled && _permission == CompassPermissionStatus.granted;

  @override
  List<Object?> get props => [_serviceEnabled, _permission];
}
