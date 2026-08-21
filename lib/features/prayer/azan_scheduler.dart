// جدولة صوت الأذان محليًا (يعمل بدون إنترنت) اعتمادًا على
// [PrayerTimesService] — نفس مصدر المواقيت المعروض في الرئيسية وشاشة
// المواقيت — ومفاتيح كتم الصوت لكل صلاة من شاشة المواقيت.
//
// أندرويد: إشعار مجدول بدقة (exactAllowWhileIdle) بصوت الأذان الكامل
// المضمّن في التطبيق (res/raw/azan.mp3).
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

  /// كم يومًا نجدول مقدمًا.
  ///
  /// لا شيء يعيد الجدولة والتطبيق مغلق: لا مهمة خلفية ولا استيقاظ عند
  /// إطلاق الإشعار — الجدولة تُبنى عند فتح التطبيق فقط (ويعيد النظام
  /// بناء المعلّق منها بعد الإقلاع عبر ScheduledNotificationBootReceiver).
  /// فأي أفق قصير يعني توقّف الأذان بصمت متى تُرك التطبيق مغلقًا أطول
  /// منه — بيومين كان يصمت في اليوم الثالث.
  ///
  /// أندرويد: ٧ أيام = ٣٥ إشعارًا، أقل بكثير من سقف ٥٠٠ منبّه للتطبيق.
  /// iOS: سقف النظام ٦٤ إشعارًا معلّقًا للتطبيق كله، وتشاركه تذكيرات
  /// الأذكار، فنُبقي يومين حتى لا يزاحمها الأذان.
  static int get _daysAhead => Platform.isAndroid ? 7 : 2;

  /// معرّف منبّه النظام القديم (AndroidAlarmManager في notifiers.dart).
  static const int _legacyAlarmId = 0;

  /// نُنظّف بقايا النظام القديم مرة واحدة فقط لكل جهاز.
  static const String _legacyClearedKey = 'azan_legacy_alarms_cleared';

  /// قناة إشعار الأذان. إعدادات القناة (الصوت والأهمية ومجرى الصوت)
  /// تُجمَّد لحظة إنشائها على الجهاز ولا يمكن تعديلها بعدها، فأي تغيير
  /// في ملف الأذان يستلزم معرّف قناة جديدًا + حذف القديمة.
  static const String _channelId = 'azan_channel_v2';

  /// القناة السابقة (صوت adhan_mecca على مجرى الإشعارات) — تُحذف مرة
  /// واحدة حتى لا تبقى معلّقة في إعدادات إشعارات التطبيق.
  static const String _staleChannelId = 'azan_channel';

  /// ملف الأذان المضمّن (res/raw/azan.mp3).
  static const String _azanSound = 'azan';

  /// أيقونة الإشعار الصغيرة (res/drawable/ic_stat_azkary.xml).
  /// قناع أبيض شفاف كما يشترط أندرويد — `icon` كان شعارًا ملوّنًا يظهر
  /// مربّعًا داكنًا مصمتًا في شريط الحالة.
  static const String _smallIcon = 'ic_stat_azkary';

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
      // المسمّى القديم 'ic_notify' غير موجود وكان يُفشل التهيئة
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
      // حذف القناة القديمة (لا يضر تكراره) — بدونه يبقى صوتها المجمّد
      // هو ما يُشغَّل على الأجهزة التي ثبّتت نسخة سابقة.
      await _dropStaleChannel();

      // نظّف نطاقنا بالكامل قبل إعادة الجدولة
      final pending = await plugin.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= _baseId && request.id < _baseId + 100) {
          await plugin.cancel(request.id);
        }
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        'الأذان',
        channelDescription: 'تنبيه صوتي عند دخول وقت الصلاة',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        icon: _smallIcon,
        sound: RawResourceAndroidNotificationSound(_azanSound),
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

  /// يحذف قناة الأذان القديمة إن وُجدت. عملية خفيفة وآمنة التكرار.
  static Future<void> _dropStaleChannel() async {
    try {
      await _android()?.deleteNotificationChannel(_staleChannelId);
    } catch (_) {
      // لا شيء يعتمد عليها — القناة الجديدة تُنشأ عند أول إشعار
    }
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
