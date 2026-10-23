// جدولة النافذة العائمة للتذكيرات — أذكارًا كانت أم أحاديث أم آيات.
//
// لماذا AndroidAlarmManager لا flutter_local_notifications؟ لأن الإشعار
// المجدول يعرضه النظام بنفسه ولا يُشغّل شيفرة Dart، بينما إظهار نافذة
// عائمة يستلزم استدعاء `FlutterOverlayWindow.showOverlay` — أي شيفرة
// تعمل فعلًا والتطبيق مغلق. `AndroidAlarmManager` يوقظ عزلة Dart بلا
// واجهة، وهو الطريق الوحيد المتاح هنا.
//
// خلَف `ZikrOverlayScheduler`: كان مفتاحًا عامًا واحدًا يعرض الأذكار فقط
// و«فوق» الإشعارات لا بديلًا عنها. الآن لكل نوع في [ReminderKind] طريقة
// عرضه الخاصة ([ReminderDelivery])، وهذا الملف يخدم النطاق العائم منها.
//
// العزلة التي يوقظها المنبّه لا Hive فيها ولا مصحف محمّل ولا ترجمات، فلا
// سبيل لها لتعرف ماذا تعرض. لذلك نُودع لكل نوع — لحظة التسليح، من عزلة
// الواجهة — عنوانه ومجموعة من نصوصه في SharedPreferences، ونستنتج النوع
// داخل العزلة من نطاق معرّف المنبّه نفسه. لا شيء آخر يعبر الحدّ.

import 'dart:convert';
import 'dart:math';
import 'dart:ui' show DartPluginRegistrant;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/notifications/logic/overlay_palette.dart';
import 'package:azkark/features/notifications/logic/reminder_scheduler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ارتفاع نافذة الحبّة بالبكسل الفيزيائي — الإضافة لا تتعامل بالـ dp.
///
/// النافذة شفافة لكنها تلتقط اللمس في كامل مساحتها، فكل بكسل زائد فوق ما
/// تشغله الحبّة حجبٌ أعمى لأعلى الشاشة طوال ثلاث ثوانٍ. ٤٤٠ هو سقف ما
/// تحتاجه حبّة من سطرين (شريط الحالة + هامش + الحبّة ≈ ١١٠dp) عند أعلى
/// كثافة شائعة (dpr ٤)، وأوسعُ منه على ما دونها.
const int kZikrOverlayHeightPx = 440;

/// مفاتيح القناة العابرة بين العزلتين. نصّ لا كائن: SharedPreferences هو
/// المخزن الوحيد الذي تقرؤه العزلتان بلا تهيئة مسبقة.
String _poolKey(ReminderKind kind) => 'overlay_pool_${kind.name}';

String _titleKey(ReminderKind kind) => 'overlay_title_${kind.name}';

/// لون الحبّة المختار — مفتاح واحد لكل الأنواع: المستخدم يختار هيئة نافذةٍ
/// واحدة يعرفها بلونها، لا لونًا لكل نوع.
///
/// في SharedPreferences لا في Hive كبقية الإعدادات: العزلة التي يوقظها
/// المنبّه تقرأ من هنا أصلًا (النصوص والعنوان)، وفتح صندوق Hive فيها
/// مِحنةٌ لا داعي لها من أجل عدد واحد.
const String kOverlayColorKey = 'overlay_pill_color_v1';

/// تُستدعى في عزلة منفصلة يوقظها النظام — لا حالة مشتركة مع التطبيق.
///
/// `vm:entry-point` إلزامي: لا مُستدعي ظاهر لها في الشيفرة، فيحذفها
/// مُحسِّن وضع الإصدار بدونه.
@pragma('vm:entry-point')
Future<void> reminderOverlayAlarmCallback(int id) async {
  try {
    // العزلة الموقَظة تبدأ بلا إضافات مسجَّلة؛ بدون هذا السطر ترمي
    // SharedPreferences MissingPluginException.
    DartPluginRegistrant.ensureInitialized();

    final kind = OverlayScheduler.kindForAlarmId(id);
    if (kind == null) return;

    if (!await FlutterOverlayWindow.isPermissionGranted()) return;
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }

    final prefs = await SharedPreferences.getInstance();
    final pool = prefs.getStringList(_poolKey(kind)) ?? const <String>[];
    final title = prefs.getString(_titleKey(kind)) ?? '';
    final color = OverlayPillColor.fromValue(prefs.getInt(kOverlayColorKey));

    await FlutterOverlayWindow.showOverlay(
      height: kZikrOverlayHeightPx,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.topCenter,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      enableDrag: true,
      overlayTitle: title.isEmpty ? 'zikr'.tr() : title,
      overlayContent: title.isEmpty ? 'zikr_from_app'.tr() : title,
    );

    // النص يصل بعد الإظهار: العزلة الأخرى لم تكن قائمة قبله
    if (pool.isNotEmpty) {
      await FlutterOverlayWindow.shareData(
        OverlayScheduler.encodePayload(
          title: title,
          body: pool[Random().nextInt(pool.length)],
          color: color,
        ),
      );
    }
  } catch (e) {
    debugPrint('reminderOverlayAlarmCallback failed: $e');
  }
}

class OverlayScheduler {
  OverlayScheduler._();

  /// عدد المواعيد المحجوزة لكل نوع. نطاقات [ReminderKind.overlayBaseId]
  /// متباعدة ١٠٠، فـ٤٠ خانة لا تتجاوز نطاق النوع أبدًا.
  static const int _maxSlotsPerKind = 40;

  /// سقف النصوص المُودعة لكل نوع. مجموعة الآيات تتجاوز ستة آلاف نص —
  /// كتابتها كاملة في SharedPreferences تعني ملفًا بمِيغابايتات يُقرأ
  /// بالكامل عند كل إقلاع، بلا فائدة: النافذة تعرض نصًا واحدًا.
  static const int _poolCap = 120;

  /// مفتاح النسخة السابقة (تبديل عام للأذكار وحدها). يُقرأ مرة واحدة
  /// لترحيل من كان مفعّلًا له إلى [ReminderDelivery.both]، ثم يُمحى.
  static const String _legacyEnabledKey = 'zikr_overlay_enabled';
  static const String _legacyMigratedKey = 'overlay_delivery_migrated_v1';

  static SharedPreferences? _prefs;

  static final Random _random = Random();

  static Future<SharedPreferences> _load() async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ---------------------------------------------------------------- الاستعلام

  /// الأنواع التي طلب المستخدم عرضها كنافذة عائمة.
  static List<ReminderKind> get floatingKinds => ReminderKind.values
      .where((k) =>
          ReminderScheduler.isEnabled(k) &&
          ReminderScheduler.deliveryOf(k).hasFloating)
      .toList(growable: false);

  /// النوع صاحب معرّف المنبّه — الطريقة الوحيدة لمعرفة ماذا نعرض داخل
  /// العزلة الموقَظة، فهي لا تستقبل شيئًا سوى هذا العدد.
  static ReminderKind? kindForAlarmId(int id) {
    for (final kind in ReminderKind.values) {
      if (id >= kind.overlayBaseId &&
          id < kind.overlayBaseId + _maxSlotsPerKind) {
        return kind;
      }
    }
    return null;
  }

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
      debugPrint('OverlayScheduler.requestPermission failed: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------- الحمولة

  /// العنوان والنص واللون معًا في سلسلة واحدة: `shareData` تنقل قيمة
  /// واحدة، ولا نريد نافذة الحديث تحمل ترويسة «ذكر».
  ///
  /// اللون يعبر في الحمولة لا يُقرأ في عزلة النافذة: تلك العزلة محرّك
  /// فلاتر آخر، وقناة `shareData` هي الطريق الوحيد المُجرَّب بينهما.
  static String encodePayload({
    required String title,
    required String body,
    OverlayPillColor color = kDefaultOverlayPillColor,
  }) =>
      jsonEncode({'title': title, 'body': body, 'color': color.value});

  // ---------------------------------------------------------------- اللون

  /// اللون الذي اختاره المستخدم للحبّة العائمة.
  static Future<OverlayPillColor> pillColor() async {
    try {
      final prefs = await _load();
      return OverlayPillColor.fromValue(prefs.getInt(kOverlayColorKey));
    } catch (e) {
      debugPrint('OverlayScheduler.pillColor failed: $e');
      return kDefaultOverlayPillColor;
    }
  }

  /// يحفظ اللون. لا إعادة تسليح بعده: المنبّهات لا تحمل اللون، والعزلة
  /// الموقَظة تقرأ المفتاح لحظة الإطلاق — فالتغيير يسري على أول نافذة
  /// تالية بلا لمس جدولة قائمة.
  static Future<void> setPillColor(OverlayPillColor color) async {
    final prefs = await _load();
    await prefs.setInt(kOverlayColorKey, color.value);
  }

  // ---------------------------------------------------------------- التسليح

  /// هل ترك آخر تسليح منبّهات عائمة معلّقة؟ انظر [arm].
  static const String _armedKey = 'overlay_alarms_armed';

  /// يعيد بناء منبّهات النافذة العائمة لليوم ولليوم التالي، لكل نوع اختار
  /// المستخدم عرضه عائمًا.
  ///
  /// تُستدعى من [ReminderScheduler.arm] لا مباشرةً: الإعدادات مشتركة بين
  /// القناتين، وفصل النداءين كان يترك إحداهما على فترة قديمة.
  static Future<void> arm() async {
    try {
      await _migrateLegacyToggle();

      final kinds = floatingKinds;
      final prefs = await _load();
      // _cancelAll مئة وعشرون نداءً عبر القناة كانت تجري مع كل تسليح ولو لم
      // يُسلَّح شيء قط. غياب المفتاح (تثبيت سابق له) يُعامل كـ«سُلِّح» احتياطًا.
      final wasArmed = prefs.getBool(_armedKey) ?? true;
      if (kinds.isEmpty && !wasArmed) return;

      await AndroidAlarmManager.initialize();
      if (wasArmed) await _cancelAll();
      await prefs.setBool(_armedKey, false);

      if (kinds.isEmpty) {
        await _clearPools();
        return;
      }
      if (!await hasPermission()) {
        debugPrint('OverlayScheduler: overlay permission not granted');
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var armed = 0;
      // قبل الحلقة لا بعدها: فشل في منتصفها يترك منبّهات يجب أن تُلغى لاحقًا
      await prefs.setBool(_armedKey, true);

      for (final kind in kinds) {
        await _stagePool(kind);

        // كل نوع يتبع فترته الخاصة ونافذة التذكير المشتركة، تمامًا كإشعاره
        final slots = _slots(ReminderScheduler.intervalMinutes(kind));
        var id = kind.overlayBaseId;
        var scheduled = 0;

        for (var dayOffset = 0;
            dayOffset < 2 && scheduled < _maxSlotsPerKind;
            dayOffset++) {
          for (final minutes in slots) {
            if (scheduled >= _maxSlotsPerKind) break;
            final when = today.add(Duration(days: dayOffset, minutes: minutes));
            if (!when.isAfter(now)) continue;

            await AndroidAlarmManager.oneShotAt(
              when,
              id++,
              reminderOverlayAlarmCallback,
              exact: true,
              wakeup: true,
              allowWhileIdle: true,
              rescheduleOnReboot: true,
            );
            scheduled++;
          }
        }
        armed += scheduled;
      }

      debugPrint('OverlayScheduler: armed $armed overlay slots '
          '(${kinds.map((k) => k.name).join(", ")})');
    } catch (e) {
      // تحسينية — لا تكسر الإقلاع
      debugPrint('OverlayScheduler.arm failed: $e');
    }
  }

  /// يُودع عنوان النوع وعيّنة من نصوصه حيث تصل إليها العزلة الموقَظة.
  static Future<void> _stagePool(ReminderKind kind) async {
    final prefs = await _load();
    final pool = await ReminderScheduler.contentPool(kind);
    if (pool.isEmpty) return;

    // الحبّة سطران لا ثلاثة أسطر، فسقف ما يسعها نزل معها. سُلَّم لا حدّ
    // واحد: النوع الذي لا نصّ قصيرًا فيه (متون الأحاديث مثلًا) يُعرض
    // مقصوصًا، وهو خير من ألّا يُعرض له شيء.
    final source = _firstNonEmpty([
      pool.where((t) => t.length <= 90).toList(growable: false),
      pool.where((t) => t.length <= 180).toList(growable: false),
      pool,
    ]);

    final List<String> sample;
    if (source.length <= _poolCap) {
      sample = source;
    } else {
      final shuffled = List<String>.of(source)..shuffle(_random);
      sample = shuffled.take(_poolCap).toList(growable: false);
    }

    await prefs.setStringList(_poolKey(kind), sample);
    await prefs.setString(_titleKey(kind), kind.titleKey.tr());
  }

  /// أول قائمة غير فارغة في السُّلَّم — والأخيرة مهما كانت.
  static List<String> _firstNonEmpty(List<List<String>> tiers) =>
      tiers.firstWhere((t) => t.isNotEmpty, orElse: () => tiers.last);

  static Future<void> _clearPools() async {
    final prefs = await _load();
    for (final kind in ReminderKind.values) {
      await prefs.remove(_poolKey(kind));
      await prefs.remove(_titleKey(kind));
    }
  }

  static Future<void> _cancelAll() async {
    for (final kind in ReminderKind.values) {
      for (var i = 0; i < _maxSlotsPerKind; i++) {
        await AndroidAlarmManager.cancel(kind.overlayBaseId + i);
      }
    }
  }

  /// من كان مفعّلًا المفتاح العام القديم كان يرى الأذكار عائمة *و* كإشعار،
  /// فـ[ReminderDelivery.both] هو ما يحفظ له سلوكه بلا مفاجأة.
  static Future<void> _migrateLegacyToggle() async {
    if (getValue(_legacyMigratedKey) == true) return;
    try {
      final prefs = await _load();
      if (prefs.getBool(_legacyEnabledKey) == true) {
        await updateValue(
            ReminderKind.zikr.deliveryKey, ReminderDelivery.both.name);
      }
      await prefs.remove(_legacyEnabledKey);
      await updateValue(_legacyMigratedKey, true);
    } catch (e) {
      // نتركها لمحاولة لاحقة — لا نضع العلامة عند الفشل
      debugPrint('OverlayScheduler: legacy migration failed: $e');
    }
  }

  // ---------------------------------------------------------------- التجربة

  /// يعرض النافذة العائمة فورًا بنموذج من محتوى النوع — نصف زر «عرض مثال»
  /// في الشاشة، ويُستدعى من عزلة الواجهة لا من منبّه.
  static Future<bool> showSample(ReminderKind kind) async {
    try {
      if (!await hasPermission()) return false;
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }

      final pool = await ReminderScheduler.contentPool(kind);
      if (pool.isEmpty) return false;
      final title = kind.titleKey.tr();

      await FlutterOverlayWindow.showOverlay(
        height: kZikrOverlayHeightPx,
        width: WindowSize.matchParent,
        alignment: OverlayAlignment.topCenter,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.none,
        enableDrag: true,
        overlayTitle: title,
        overlayContent: title,
      );
      await FlutterOverlayWindow.shareData(
        encodePayload(
          title: title,
          body: pool[_random.nextInt(pool.length)],
          color: await pillColor(),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('OverlayScheduler.showSample failed: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------- المواعيد

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
