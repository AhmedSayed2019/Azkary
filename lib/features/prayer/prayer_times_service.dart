// lib/features/prayer/prayer_times_service.dart
//
// حساب مواقيت الصلاة محلياً بالكامل (يعمل بدون إنترنت)
// الإنترنت / الـ GPS يُستخدم فقط لتحديث الإحداثيات وتخزينها.

import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PrayerId { fajr, sunrise, dhuhr, asr, maghrib, isha }

const Map<PrayerId, String> kPrayerNamesAr = {
  PrayerId.fajr: 'الفجر',
  PrayerId.sunrise: 'الشروق',
  PrayerId.dhuhr: 'الظهر',
  PrayerId.asr: 'العصر',
  PrayerId.maghrib: 'المغرب',
  PrayerId.isha: 'العشاء',
};

class PrayerSlot {
  final PrayerId id;
  final DateTime time; // local time
  final bool isTomorrow;

  const PrayerSlot({
    required this.id,
    required this.time,
    this.isTomorrow = false,
  });

  String get name => kPrayerNamesAr[id]!;
}

class PrayerDay {
  /// كل المواقيت بما فيها الشروق (مطلوب لحساب شريط التقدم)
  final List<PrayerSlot> all;

  /// الصلوات الخمس فقط (بدون الشروق) للعرض في الصف السفلي
  final List<PrayerSlot> five;

  final PrayerSlot next;
  final PrayerSlot previous;
  final String locationName;

  const PrayerDay({
    required this.all,
    required this.five,
    required this.next,
    required this.previous,
    required this.locationName,
  });

  /// نسبة ما مضى بين الوقت السابق والوقت القادم (٠ إلى ١)
  double progress(DateTime now) {
    final total = next.time.difference(previous.time).inSeconds;
    if (total <= 0) return 0;
    final passed = now.difference(previous.time).inSeconds;
    return (passed / total).clamp(0.0, 1.0);
  }

  Duration remaining(DateTime now) {
    final d = next.time.difference(now);
    return d.isNegative ? Duration.zero : d;
  }
}

class PrayerTimesService {
  static const _kLat = 'prayer_lat';
  static const _kLng = 'prayer_lng';
  static const _kCity = 'prayer_city';
  static const _kMethod = 'prayer_method';
  static const _kMadhab = 'prayer_madhab';

  // إحداثيات افتراضية حتى لا تظهر الشاشة فارغة في أول تشغيل (القاهرة)
  static const double _defaultLat = 30.0444;
  static const double _defaultLng = 31.2357;

  double _lat = _defaultLat;
  double _lng = _defaultLng;
  String _city = 'القاهرة';
  bool _hasStoredLocation = false;

  String _methodKey = 'egyptian';
  String _madhabKey = 'shafi';

  double get latitude => _lat;
  double get longitude => _lng;
  String get city => _city;
  bool get hasStoredLocation => _hasStoredLocation;

  /// تُستدعى مرة واحدة عند تشغيل التطبيق قبل أول عرض.
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_kLat);
    final lng = prefs.getDouble(_kLng);
    if (lat != null && lng != null) {
      _lat = lat;
      _lng = lng;
      _hasStoredLocation = true;
    }
    _city = prefs.getString(_kCity) ?? _city;
    _methodKey = prefs.getString(_kMethod) ?? _methodKey;
    _madhabKey = prefs.getString(_kMadhab) ?? _madhabKey;
  }

  Future<void> setMethod(String methodKey, {String? madhabKey}) async {
    _methodKey = methodKey;
    if (madhabKey != null) _madhabKey = madhabKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMethod, _methodKey);
    await prefs.setString(_kMadhab, _madhabKey);
  }

  /// تحديث الموقع من الجهاز. ترجع true لو تغيّرت الإحداثيات فعلاً.
  /// لا ترمي استثناءات — أي فشل يعني الاستمرار بآخر موقع محفوظ.
  Future<bool> refreshLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 12),
      );

      final changed =
          (position.latitude - _lat).abs() > 0.01 ||
          (position.longitude - _lng).abs() > 0.01;

      _lat = position.latitude;
      _lng = position.longitude;
      _hasStoredLocation = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kLat, _lat);
      await prefs.setDouble(_kLng, _lng);

      await _resolveCityName(prefs);
      return changed;
    } catch (_) {
      return false;
    }
  }

  Future<void> _resolveCityName(SharedPreferences prefs) async {
    try {
      final marks = await placemarkFromCoordinates(_lat, _lng);
      if (marks.isNotEmpty) {
        final m = marks.first;
        final name = (m.locality?.isNotEmpty == true)
            ? m.locality!
            : (m.administrativeArea ?? m.country ?? '');
        if (name.isNotEmpty) {
          _city = name;
          await prefs.setString(_kCity, _city);
        }
      }
    } catch (_) {
      // بدون إنترنت: نحتفظ بآخر اسم مدينة محفوظ
    }
  }

  CalculationParameters _params() {
    final method = switch (_methodKey) {
      'ummAlQura' => CalculationMethod.umm_al_qura,      // السعودية
      'muslimWorldLeague' => CalculationMethod.muslim_world_league,
      'dubai' => CalculationMethod.dubai,
      'qatar' => CalculationMethod.qatar,
      'kuwait' => CalculationMethod.kuwait,
      'karachi' => CalculationMethod.karachi,
      'northAmerica' => CalculationMethod.north_america,
      _ => CalculationMethod.egyptian,                    // مصر (افتراضي)
    };
    final params = method.getParameters();
    params.madhab = _madhabKey == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
    return params;
  }

  /// الحساب الأساسي. محلي بالكامل، لا يحتاج شبكة.
  PrayerDay compute({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final coords = Coordinates(_lat, _lng);
    final params = _params();

    final today = PrayerTimes(
      coords,
      DateComponents.from(currentTime),
      params,
    );
    final tomorrow = PrayerTimes(
      coords,
      DateComponents.from(currentTime.add(const Duration(days: 1))),
      params,
    );

    final slots = <PrayerSlot>[
      PrayerSlot(id: PrayerId.fajr, time: today.fajr.toLocal()),
      PrayerSlot(id: PrayerId.sunrise, time: today.sunrise.toLocal()),
      PrayerSlot(id: PrayerId.dhuhr, time: today.dhuhr.toLocal()),
      PrayerSlot(id: PrayerId.asr, time: today.asr.toLocal()),
      PrayerSlot(id: PrayerId.maghrib, time: today.maghrib.toLocal()),
      PrayerSlot(id: PrayerId.isha, time: today.isha.toLocal()),
    ];

    final tomorrowFajr = PrayerSlot(
      id: PrayerId.fajr,
      time: tomorrow.fajr.toLocal(),
      isTomorrow: true,
    );

    PrayerSlot next = tomorrowFajr;
    PrayerSlot previous = slots.last; // العشاء
    for (var i = 0; i < slots.length; i++) {
      if (slots[i].time.isAfter(currentTime)) {
        next = slots[i];
        previous = i == 0
            ? PrayerSlot(
                id: PrayerId.isha,
                time: today.isha.toLocal().subtract(const Duration(days: 1)),
              )
            : slots[i - 1];
        break;
      }
    }

    return PrayerDay(
      all: slots,
      five: slots.where((s) => s.id != PrayerId.sunrise).toList(),
      next: next,
      previous: previous,
      locationName: _city,
    );
  }
}
