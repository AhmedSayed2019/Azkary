// جدولة صوت الأذان محليًا (يعمل بدون إنترنت) اعتمادًا على
// [PrayerTimesService] — نفس مصدر المواقيت المعروض في الرئيسية وشاشة
// المواقيت — ومفاتيح كتم الصوت لكل صلاة من شاشة المواقيت.
//
// أندرويد: إشعار مجدول بدقة (exactAllowWhileIdle) بصوت الأذان الكامل
// المضمّن في التطبيق (res/raw/adhan_mecca.mp3).
// iOS: نفس الجدولة بصوت النظام الافتراضي — أصوات إشعارات iOS محدودة
// بثلاثين ثانية ويلزم ملف ‎.caf يُضاف عبر Xcode لصوت أذان مخصص.

import 'dart:io' show Platform;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:azkark/features/prayer/prayer_times_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class AzanScheduler {
  AzanScheduler._();

  /// نطاق معرّفات خاص بهذه الجدولة حتى لا يتعارض مع إشعارات النظام القديم
  /// (`notifiers.dart` يستخدم 0..5) أو إشعارات الأذكار.
  static const int _baseId = 7000;

  /// كم يومًا نجدول مقدمًا (يُعاد الجدولة عند كل فتح للتطبيق أو تغيير إعداد).
  static const int _daysAhead = 2;

  /// معرّف منبّه النظام القديم (AndroidAlarmManager في notifiers.dart).
  static const int _legacyAlarmId = 0;

  /// نُنظّف بقايا النظام القديم مرة واحدة فقط لكل جهاز.
  static const String _legacyClearedKey = 'azan_legacy_alarms_cleared';

  /// أيقونة الإشعار الصغيرة (res/drawable/icon.png).
  static const String _smallIcon = 'icon';

  static bool _tzReady = false;

  /// إعادة الجدولة تُستدعى من أماكن عدة قد تتزامن (الإقلاع + قسم الأذان
  /// في الرئيسية). نسلسلها حتى لا يتداخل الإلغاء مع الجدولة.
  static Future<void> _inFlight = Future<void>.value();

  static Future<void> _ensureTimezone() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // نبقى على tz.local الافتراضي — الأوقات محلية أصلًا فالفارق معدوم غالبًا
    }
    _tzReady = true;
  }

  static Future<FlutterLocalNotificationsPlugin> _plugin() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      // 'icon' = res/drawable/icon.png — المورد الوحيد الموجود فعلًا
      // (المسمّى القديم 'ic_notify' غير موجود وكان يُفشل التهيئة).
      android: AndroidInitializationSettings(_smallIcon),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(settings);
    return plugin;
  }

  /// يلغي جدولة الأذان الحالية ويعيد بناءها من مواقيت
  /// [PrayerTimesService] ومفاتيح الصوت المحفوظة. تُستدعى عند فتح
  /// التطبيق وبعد تغيير الموقع/طريقة الحساب/مفاتيح الصوت.
  static Future<void> reschedule({PrayerTimesService? service}) {
    final next = _inFlight.then((_) => _reschedule(service));
    _inFlight = next;
    return next;
  }

  static Future<void> _reschedule(PrayerTimesService? service) async {
    try {
      await _ensureTimezone();

      final svc = service ?? (PrayerTimesService());
      if (service == null) await svc.loadCache();

      final prefs = await SharedPreferences.getInstance();
      final plugin = await _plugin();

      // نظام الأذان القديم قد يكون ترك منبّهًا معلّقًا يعيد نفسه بعد
      // كل إقلاع — نُسكته مرة واحدة حتى لا يُسمع أذانان.
      await _clearLegacyAlarms(plugin, prefs);

      // نظّف نطاقنا بالكامل قبل إعادة الجدولة
      final pending = await plugin.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= _baseId && request.id < _baseId + 100) {
          await plugin.cancel(request.id);
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'azan_channel',
        'الأذان',
        channelDescription: 'تنبيه صوتي عند دخول وقت الصلاة',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        icon: _smallIcon,
        sound: RawResourceAndroidNotificationSound('adhan_mecca'),
        playSound: true,
        // الأذان ينتمي لمجرى المنبّه لا الإشعارات: يُسمع بمستوى صوت
        // المنبّه ولا يُقصّ. لا يُغيَّر بعد إنشاء القناة على الجهاز.
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
      const details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      final now = DateTime.now();
      var id = _baseId;
      var scheduled = 0;

      for (var dayOffset = 0; dayOffset < _daysAhead; dayOffset++) {
        // منتصف اليوم المستهدف حتى يحسب compute مواقيت ذلك اليوم كاملة
        final day = DateTime(now.year, now.month, now.day)
            .add(Duration(days: dayOffset, hours: 12));
        final prayerDay = svc.compute(now: day);

        for (final slot in prayerDay.five) {
          if (!slot.time.isAfter(now)) continue;
          final soundOn =
              prefs.getBool('prayer_sound_${slot.id.name}') ?? true;
          if (!soundOn) continue;

          final when = tz.TZDateTime.from(slot.time, tz.local);
          try {
            await plugin.zonedSchedule(
              id++,
              'حان الآن وقت صلاة ${slot.name}',
              '${svc.city} — ${_formatTime(slot.time)}',
              when,
              details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          } on PlatformException catch (e) {
            // أندرويد ١٢+ بدون إذن المنبهات الدقيقة — نتراجع لجدولة تقريبية
            if (e.code == 'exact_alarms_not_permitted') {
              await plugin.zonedSchedule(
                id++,
                'حان الآن وقت صلاة ${slot.name}',
                '${svc.city} — ${_formatTime(slot.time)}',
                when,
                details,
                androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              );
            } else {
              rethrow;
            }
          }
          scheduled++;
        }
      }

      debugPrint('AzanScheduler: scheduled $scheduled azan notifications');
    } catch (e) {
      // الجدولة تحسينية — فشلها يجب ألا يكسر تشغيل التطبيق أبدًا
      debugPrint('AzanScheduler.reschedule failed: $e');
    }
  }

  /// واجهة أندرويد للإضافة — null على المنصات الأخرى أو عند فشل الحلّ.
  static AndroidFlutterLocalNotificationsPlugin? _android() {
    if (!Platform.isAndroid) return null;
    return FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
  }

  /// هل يسمح النظام بجدولة المنبهات الدقيقة؟ أندرويد ١٢+ يطلب إذن
  /// «المنبهات والتذكيرات» صراحةً؛ بدونه يتأخر الأذان دقائق.
  /// يعيد true على المنصات/الإصدارات التي لا تحتاج الإذن.
  static Future<bool> canScheduleExact() async {
    try {
      return await _android()?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return true;
    }
  }

  /// يفتح شاشة إعدادات «المنبهات والتذكيرات» ثم يعيد الجدولة إن مُنح
  /// الإذن. يعيد الحالة النهائية للإذن.
  static Future<bool> requestExactAlarmPermission(
      {PrayerTimesService? service}) async {
    try {
      await _android()?.requestExactAlarmsPermission();
      final granted = await canScheduleExact();
      if (granted) await reschedule(service: service);
      return granted;
    } catch (e) {
      debugPrint('AzanScheduler.requestExactAlarmPermission failed: $e');
      return false;
    }
  }

  /// يُلغي منبّه الأذان القديم (AndroidAlarmManager) وإشعاره الدائم.
  /// النظام القديم كان يعيد جدولة نفسه ذاتيًا بعد كل إطلاق، فلا يكفي
  /// تعطيل استدعائه في الكود — لا بد من إلغاء المنبّه المعلّق أيضًا.
  static Future<void> _clearLegacyAlarms(
    FlutterLocalNotificationsPlugin plugin,
    SharedPreferences prefs,
  ) async {
    if (prefs.getBool(_legacyClearedKey) ?? false) return;
    try {
      if (Platform.isAndroid) {
        await AndroidAlarmManager.initialize();
        await AndroidAlarmManager.cancel(_legacyAlarmId);
      }
      await plugin.cancel(_legacyAlarmId);
      await prefs.setBool(_legacyClearedKey, true);
      debugPrint('AzanScheduler: legacy adhan alarm cleared');
    } catch (e) {
      // نتركها لمحاولة لاحقة — لا نضع العلامة عند الفشل
      debugPrint('AzanScheduler: legacy cleanup failed: $e');
    }
  }

  static String _formatTime(DateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final suffix = time.hour < 12 ? 'ص' : 'م';
    return '$hour12:${time.minute.toString().padLeft(2, '0')} $suffix';
  }
}
