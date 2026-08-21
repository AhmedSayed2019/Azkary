// جدولة النافذة العائمة للأذكار.
//
// لماذا AndroidAlarmManager لا flutter_local_notifications؟ لأن الإشعار
// المجدول يعرضه النظام بنفسه ولا يُشغّل شيفرة Dart، بينما إظهار نافذة
// عائمة يستلزم استدعاء `FlutterOverlayWindow.showOverlay` — أي شيفرة
// تعمل فعلًا والتطبيق مغلق. `AndroidAlarmManager` يوقظ عزلة Dart بلا
// واجهة، وهو الطريق الوحيد المتاح هنا.
//
// النافذة العائمة إضافة فوق إشعارات [ReminderScheduler] لا بديل عنها:
// الإشعارات تبقى تعمل كما هي.

import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:azkark/core/utils/constants.dart' show zikrNotfications;
import 'package:azkark/features/notifications/logic/reminder_scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تُستدعى في عزلة منفصلة يوقظها النظام — لا حالة مشتركة مع التطبيق.
///
/// `vm:entry-point` إلزامي: لا مُستدعي ظاهر لها في الشيفرة، فيحذفها
/// مُحسِّن وضع الإصدار بدونه.
@pragma('vm:entry-point')
Future<void> zikrOverlayAlarmCallback(int id) async {
  try {
    if (!await FlutterOverlayWindow.isPermissionGranted()) return;
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }

    await FlutterOverlayWindow.showOverlay(
      height: kZikrOverlayHeightPx,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      enableDrag: true,
      overlayTitle: 'ذكر',
      overlayContent: 'ذكر من سكينة',
    );

    // النص يصل بعد الإظهار: العزلة الأخرى لم تكن قائمة قبله
    final pool = zikrNotfications
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    if (pool.isNotEmpty) {
      await FlutterOverlayWindow.shareData(pool[Random().nextInt(pool.length)]);
    }
  } catch (e) {
    debugPrint('zikrOverlayAlarmCallback failed: $e');
  }
}

/// ارتفاع الفقاعة بالبكسل الفيزيائي — الإضافة لا تتعامل بالـ dp.
const int kZikrOverlayHeightPx = 420;

class ZikrOverlayScheduler {
  ZikrOverlayScheduler._();

  /// نطاق معرّفات منبّهات خاص بنا — بعيد عن نطاقات الإشعارات (٧١٠٠..٧٤٠٠).
  static const int _baseId = 7600;
  static const int _maxSlots = 40;

  static const String enabledKey = 'zikr_overlay_enabled';

  /// القراءة المتزامنة صالحة فقط بعد [_load]؛ تُستعمل داخليًا في [arm].
  static bool get isEnabled => _prefs?.getBool(enabledKey) ?? false;

  /// القراءة الآمنة من الواجهة — تُحمّل التفضيلات أولًا، وإلا رجعت false
  /// دومًا قبل أول استدعاء لـ [arm].
  static Future<bool> enabled() async {
    await _load();
    return _prefs!.getBool(enabledKey) ?? false;
  }

  static SharedPreferences? _prefs;

  static Future<void> _load() async =>
      _prefs ??= await SharedPreferences.getInstance();

  static Future<bool> hasPermission() async {
    try {
      return await FlutterOverlayWindow.isPermissionGranted();
    } catch (_) {
      return false;
    }
  }

  /// يفتح شاشة «العرض فوق التطبيقات الأخرى». الإذن لا يُمنح بحوار عادي.
  static Future<bool> requestPermission() async {
    try {
      await FlutterOverlayWindow.requestPermission();
      return await hasPermission();
    } catch (e) {
      debugPrint('ZikrOverlayScheduler.requestPermission failed: $e');
      return false;
    }
  }

  static Future<void> setEnabled(bool value) async {
    await _load();
    await _prefs!.setBool(enabledKey, value);
    await arm();
  }

  /// يعيد بناء منبّهات النافذة العائمة لليوم ولليوم التالي.
  static Future<void> arm() async {
    try {
      await _load();
      await AndroidAlarmManager.initialize();
      await _cancelAll();

      if (!isEnabled) return;
      if (!await hasPermission()) {
        debugPrint('ZikrOverlayScheduler: overlay permission not granted');
        return;
      }

      // نتبع نفس نافذة التذكيرات وفترتها حتى لا يتناقض الإعدادان
      final interval = ReminderScheduler.intervalMinutes(ReminderKind.zikr);
      final slots = _slots(interval);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      var id = _baseId;
      var scheduled = 0;
      for (var dayOffset = 0; dayOffset < 2 && scheduled < _maxSlots; dayOffset++) {
        for (final minutes in slots) {
          if (scheduled >= _maxSlots) break;
          final when = today.add(Duration(days: dayOffset, minutes: minutes));
          if (!when.isAfter(now)) continue;

          await AndroidAlarmManager.oneShotAt(
            when,
            id++,
            zikrOverlayAlarmCallback,
            exact: true,
            wakeup: true,
            allowWhileIdle: true,
            rescheduleOnReboot: true,
          );
          scheduled++;
        }
      }
      debugPrint('ZikrOverlayScheduler: armed $scheduled overlay slots');
    } catch (e) {
      // تحسينية — لا تكسر الإقلاع
      debugPrint('ZikrOverlayScheduler.arm failed: $e');
    }
  }

  static Future<void> _cancelAll() async {
    for (var i = 0; i < _maxSlots; i++) {
      await AndroidAlarmManager.cancel(_baseId + i);
    }
  }

  /// مواعيد اليوم بالدقائق من منتصف الليل، داخل نافذة التذكيرات النشطة.
  static List<int> _slots(int intervalMinutes) {
    final start = ReminderScheduler.startHour * 60;
    final rawEnd = ReminderScheduler.endHour * 60;
    final end = rawEnd > start ? rawEnd : rawEnd + 24 * 60;

    final all = <int>[];
    for (var t = start; t <= end; t += intervalMinutes) {
      all.add(t % (24 * 60));
    }
    return all;
  }
}
