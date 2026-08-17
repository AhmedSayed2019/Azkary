import 'dart:async';

import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/compass/domain/entity/compass_location_status_entity.dart';
import 'package:azkark/features/refactor/compass/domain/entity/qibla_direction_entity.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/check_compass_location_status_use_case.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/dispose_compass_sensors_use_case.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/get_qibla_direction_stream_use_case.dart';
import 'package:azkark/features/refactor/compass/domain/usecase/request_compass_location_permission_use_case.dart';
import 'package:flutter/foundation.dart';

/// Replaces the legacy `_QiblaCompassScreenState` location-status
/// `StreamController` + the `QiblahCompassWidget` sensor `StreamBuilder`
/// with a single VM owning both the one-shot permission check and the live
/// sensor subscription.
class CompassViewModel extends ChangeNotifier {
  final _tag = 'CompassViewModel';

  CompassViewModel({
    required CheckCompassLocationStatusUseCase checkLocationStatus,
    required RequestCompassLocationPermissionUseCase requestPermission,
    required GetQiblaDirectionStreamUseCase getQiblaDirectionStream,
    required DisposeCompassSensorsUseCase disposeSensors,
  })  : _checkLocationStatus = checkLocationStatus,
        _requestPermission = requestPermission,
        _getQiblaDirectionStream = getQiblaDirectionStream,
        _disposeSensors = disposeSensors;

  final CheckCompassLocationStatusUseCase _checkLocationStatus;
  final RequestCompassLocationPermissionUseCase _requestPermission;
  final GetQiblaDirectionStreamUseCase _getQiblaDirectionStream;
  final DisposeCompassSensorsUseCase _disposeSensors;
  bool _disposed = false;
  StreamSubscription<QiblaDirectionEntity>? _directionSubscription;

  ///Variables
  bool _isLoading = true;
  String? _error;
  CompassLocationStatusEntity? _status;
  QiblaDirectionEntity? _direction;
  String? _sensorError;

  ///Getters
  bool get isLoading => _isLoading;

  String? get error => _error;

  CompassLocationStatusEntity? get status => _status;

  QiblaDirectionEntity? get direction => _direction;

  String? get sensorError => _sensorError;

  ///Calling API functions

  Future<void> init() => checkStatus();

  /// Checks GPS + permission status. If the permission is merely `denied`
  /// (not permanently), transparently prompts once — mirroring the legacy
  /// `_checkLocationStatus` behaviour — then subscribes to the live compass
  /// stream once the device is ready.
  Future<void> checkStatus() async {
    _isLoading = true;
    _error = null;
    _notify();

    var result = await _checkLocationStatus();
    if (result case Ok(data: final status)
        when status.serviceEnabled &&
            status.permission == CompassPermissionStatus.denied) {
      result = await _requestPermission();
    }

    switch (result) {
      case Ok(:final data):
        _status = data;
        if (data.isReady) {
          _subscribeToDirection();
        } else {
          _cancelDirectionSubscription();
        }
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.checkStatus: $message');
    }

    _isLoading = false;
    _notify();
  }

  Future<void> retry() => checkStatus();

  void _subscribeToDirection() {
    _cancelDirectionSubscription();
    _sensorError = null;
    _directionSubscription = _getQiblaDirectionStream().listen(
      (reading) {
        _direction = reading;
        _sensorError = null;
        _notify();
      },
      onError: (Object e) {
        // The plugin can fail mid-stream (GPS disabled, unsupported
        // hardware, …) — the legacy `StreamBuilder` never handled this and
        // would silently freeze on the last reading.
        _sensorError = '$e';
        debugPrint('$_tag._subscribeToDirection: $e');
        _notify();
      },
    );
  }

  void _cancelDirectionSubscription() {
    _directionSubscription?.cancel();
    _directionSubscription = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelDirectionSubscription();
    _disposeSensors();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
