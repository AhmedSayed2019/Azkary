import 'package:flutter/foundation.dart';
import 'package:mq_prayer_time/mq_prayer_time.dart';

class LocationProvider extends ChangeNotifier {

  LocationProvider(this.client) {
    _position = client.initialPosition;
    _locationName = client.initialLocationName;
    _timeZoneLocation = client.initialTimeZoneLocation;
    _eventState = const LocationEventInitial();
  }

  final MqLocationClient client;

  Position _position = MqLocationStatic.makkahPosition;
  String _locationName = MqLocationStatic.makkahName;
  String _timeZoneLocation = MqLocationStatic.makkahTimezone;
  LocationEventState _eventState = const LocationEventInitial();

  // Getters
  Position get position => _position;
  String get locationName => _locationName;
  String get timeZoneLocation => _timeZoneLocation;
  LocationEventState get eventState => _eventState;

  Future<void> init() async {
    await client.init(
      onInitailLocation: _onInitailLocation,
      onNewLocation: _updateLocation,
      onKeepLocation: _keepLocation,
    );
  }

  Future<void> updateLocation() async {
    _eventState = const LocationEventInitial();
    notifyListeners();

    await client.saveData(
      position: _position,
      locationName: _locationName,
      timeZoneLocation: _timeZoneLocation,
    );
  }

  void _onInitailLocation(Position newPosition, String newLocationName, String newTimeZoneLocation) {
    _position = newPosition;
    _locationName = newLocationName;
    _timeZoneLocation = newTimeZoneLocation;
    updateLocation();
  }

  void _updateLocation(Position newPosition, String newLocationName, String newTimeZoneLocation) {
    _position = newPosition;
    _locationName = newLocationName;
    _timeZoneLocation = newTimeZoneLocation;
    _eventState = LocationEventNewLocation(
      newPosition: newPosition,
      newLocationName: newLocationName,
      newTimeZoneLocation: newTimeZoneLocation,
    );
    notifyListeners();
  }

  void _keepLocation(Position keepPosition, String keepLocationName, String keepTimeZoneLocation) {
    _position = keepPosition;
    _locationName = keepLocationName;
    _timeZoneLocation = keepTimeZoneLocation;
    _eventState = LocationEventKeepLocation(
      keepPosition: keepPosition,
      keepLocationName: keepLocationName,
      keepTimeZoneLocation: keepTimeZoneLocation,
    );
    notifyListeners();
  }
}

@immutable
sealed class LocationEventState {
  const LocationEventState();
}

@immutable
final class LocationEventInitial extends LocationEventState {
  const LocationEventInitial();
}

@immutable
final class LocationEventKeepLocation extends LocationEventState {
  const LocationEventKeepLocation({
    required this.keepPosition,
    required this.keepLocationName,
    required this.keepTimeZoneLocation,
  });

  final Position keepPosition;
  final String keepLocationName;
  final String keepTimeZoneLocation;
}

@immutable
final class LocationEventNewLocation extends LocationEventState {
  const LocationEventNewLocation({
    required this.newPosition,
    required this.newLocationName,
    required this.newTimeZoneLocation,
  });

  final Position newPosition;
  final String newLocationName;
  final String newTimeZoneLocation;
}

