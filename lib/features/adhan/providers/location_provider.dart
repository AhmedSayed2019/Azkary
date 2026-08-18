import 'package:azkark/core/utils/helpers/gps_location_helper.dart';
import 'package:azkark/core/utils/helpers/preferences.dart';
import 'package:azkark/data/models/locationInfo.dart';
import 'package:flutter/cupertino.dart';


class AdanLocationProvider with ChangeNotifier {

  AdanLocationProvider._() : _locationHelper = const LocationHelper();

  static AdanLocationProvider? _instance;

  static AdanLocationProvider getInstance() {
    _instance ??= AdanLocationProvider._();
    return _instance!;
  }


  final LocationHelper _locationHelper;
  static LocationState _locationState =
      LocationNotAvailable(locationNACauseFinding);

  LocationState get locationState => _locationState;

  Future<void> init() async {
    final loc = getPersistentLocation();
    print('AdanLocationProvider getPersistentLocation::${loc?.latitude} }');

    if (loc != null) {
      _locationState = LocationAvailable(loc);
    } else {
      _locationState = await _locationHelper.getLocationFromGPS(background: false);
      print('AdanLocationProvider getLocationFromGPS::${loc?.latitude} }');


      // final welcomeShown = sharedPrefWelcomeShown.value;
      // if (welcomeShown) {
      //   _locationState = await _locationHelper.getLocationFromGPS(background: false);
      //   print('AdanLocationProvider getLocationFromGPS::${loc?.latitude} }');
      //
      // } else {
      //   _locationState = LocationNotAvailable(locationNACausePermissionDenied);
      //   print('AdanLocationProvider locationNACausePermissionDenied::${loc?.latitude} }');
      //
      // }
    }
    print('AdanLocationProvider :: https://www.google.com/maps/search/mosque+near+me/@${loc?.latitude},${loc?.longitude}');

  }

  Future<void> updateLocationWithGPS({required bool background}) async {
    if (!background) {
      _locationState = LocationFinding();
      notifyListeners();
    }

    LocationState state =
        await _locationHelper.getLocationFromGPS(background: background);
    if (state is LocationNotAvailable) {
      final loc = getPersistentLocation();
      if (loc != null) {
        state = LocationAvailable(loc);
      }
    }
    _locationState = state;
    notifyListeners();
  }

  ///Get Location from sharedpref and returns a LocationInfo obj
  LocationInfo? getPersistentLocation() {
    final lat = sharedPrefLocationLatitude.value;
    final long = sharedPrefLocationLongitude.value;
    final adr = sharedPrefLocationAddress.value;

    LocationInfo? newLoc;
    if (lat != null && long != null && adr != null) {
      newLoc = LocationInfo(lat, long, adr, LocationMode.CACHED);
    }
    return newLoc;
  }

  @override
  void notifyListeners() async {
    // جدولة الأذان انتقلت إلى AzanScheduler + PrayerTimesService، وهما
    // مصدر المواقيت الوحيد في الرئيسية وشاشة المواقيت. استدعاء
    // scheduleNotification هنا كان يُطلق أذانًا ثانيًا بمواقيت وإعدادات
    // مختلفة، لذا عُطّل عمدًا. هذا المزوّد ما زال يُستخدم للموقع فقط
    // (القبلة، المساجد القريبة).
    super.notifyListeners();
  }


}
