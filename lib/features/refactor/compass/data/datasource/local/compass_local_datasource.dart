import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/compass/data/model/compass_location_status_model.dart';
import 'package:azkark/features/refactor/compass/data/model/qibla_direction_model.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

/// Wraps every `flutter_qiblah`/`geolocator` sensor call needed by the
/// compass feature and never throws synchronously for the request/response
/// calls — failures are surfaced as [Err] so the repository/use-case/VM
/// layers above never have to deal with a raw exception.
class CompassLocalDataSource {
  const CompassLocalDataSource();

  Future<Result<CompassLocationStatusModel>> checkLocationStatus() async {
    try {
      final status = await FlutterQiblah.checkLocationStatus();
      return Ok(CompassLocationStatusModel.fromPlugin(status));
    } catch (e) {
      return Err('Failed to read location status: $e');
    }
  }

  Future<Result<CompassLocationStatusModel>> requestPermission() async {
    try {
      await FlutterQiblah.requestPermissions();
      final status = await FlutterQiblah.checkLocationStatus();
      return Ok(CompassLocationStatusModel.fromPlugin(status));
    } catch (e) {
      return Err('Failed to request location permission: $e');
    }
  }

  /// The plugin stream itself can emit a sensor/location error at any time
  /// (e.g. GPS turned off mid-use, unsupported hardware) — those errors are
  /// forwarded downstream rather than swallowed, so the ViewModel can show a
  /// retry affordance instead of silently freezing on the last reading.
  Stream<QiblaDirectionModel> qiblaDirectionStream() {
    return FlutterQiblah.qiblahStream
        .map((direction) => QiblaDirectionModel.fromPlugin(direction));
  }

  void disposeSensors() {
    FlutterQiblah().dispose();
  }
}
