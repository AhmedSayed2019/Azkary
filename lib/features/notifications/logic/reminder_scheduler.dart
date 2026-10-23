// محرّك تذكيرات الأذكار / الأحاديث / الآيات — إشعارات محلية مجدولة.
//
// لماذا استُبدل WorkManager؟ (سبب «يظهر مفعّلًا لكنه لا يعمل عند إغلاق التطبيق»)
//   • `flutterLocalNotificationsPlugin` متغيّر عام يُهيَّأ داخل `initMessaging()`
//     التي تُستدعى من `home_page` فقط، أي في عزلة الواجهة. مهام WorkManager
//     تعمل في عزلة Dart مستقلة تبدأ بنسخة **غير مهيّأة** من الإضافة، فنداء
//     `show()` هناك لا يُظهر شيئًا. ما دام التطبيق مفتوحًا تبدو الإعدادات
//     سليمة، وبمجرد إغلاقه لا يصل أي إشعار.
//   • فرع الآيات (`ayahNot`) معلّق بالكامل داخل `callbackDispatcher`، فمفتاح
//     «إشعارات الآيات» كان يُفعَّل ويُسجّل مهمة دورية لا تفعل شيئًا إطلاقًا.
//   • الفترة كانت تُقرأ `periods[..]["index"]` (‏٠..٦) بدل `["minutes"]`،
//     فكل الخيارات تنهار إلى الحد الأدنى — و`Duration(minutes: 0)` مرفوضة.
//   • حتى لو صحّ كل ما سبق: WorkManager الدوري حدّه الأدنى ١٥ دقيقة، لا يضمن
//     وقتًا محددًا، تقتله أنظمة توفير الطاقة على أجهزة Xiaomi/Huawei/Samsung،
//     ولا ينفّذ مهامًا دورية على iOS أصلًا.
//
// البديل هنا هو نفس الآلية المجرَّبة في [AzanScheduler]: `zonedSchedule` من
// flutter_local_notifications مع `DateTimeComponents.time`، فيصير كل تذكير
// منبّهًا يوميًا مسجّلًا لدى النظام:
//   • يعمل والتطبيق مغلق تمامًا (النظام هو من يُطلقه، لا عملية التطبيق).
//   • ينجو من إعادة التشغيل عبر `ScheduledNotificationBootReceiver` المسجَّل
//     في المانيفست.
//   • يعمل على iOS بنفس الكود.
//
// المقايضة: نص الإشعار يُجمَّد لحظة الجدولة. لذلك نعيد التسليح (`arm`) عند كل
// فتح للتطبيق بإزاحة عشوائية داخل المجموعة، فيتبدّل المحتوى كلما فُتح التطبيق،
// وتختلف كل خانة عن أختها في اليوم نفسه.

import 'package:azkark/features/prayer/azan_alarm.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:azkark/core/utils/constants.dart' show zikrNotfications;
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/notifications/data/40hadith.dart';
import 'package:azkark/features/notifications/logic/overlay_scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:azkark/core/utils/timezone_init.dart';
import 'package:azkark/features/quran/quran_init.dart';
import 'package:quran_library/quran.dart' show QuranCtrl;
import 'package:timezone/timezone.dart' as tz;

/// أنواع التذكيرات المجدولة. كل نوع له قناته ونطاق معرّفاته ومفاتيحه
/// المحفوظة في Hive (نفس المفاتيح القديمة حتى لا تضيع إعدادات المستخدمين).
enum ReminderKind {
  zikr(
    enabledKey: 'shouldShowZikrNotification2',
    intervalKey: 'timesForShowingZikrNotifications2',
    deliveryKey: 'zikr_delivery_mode_v1',
    channelId: 'zikr_reminder_v1',
    channelNameKey: 'reminder_zikr_channel',
    baseId: 7100,
    overlayBaseId: 7600,
    titleKey: 'zikr',
  ),
  hadith(
    enabledKey: 'shouldShowhadithNotification',
    intervalKey: 'timesForShowinghadithNotifications',
    deliveryKey: 'hadith_delivery_mode_v1',
    channelId: 'hadith_reminder_v1',
    channelNameKey: 'reminder_hadith_channel',
    baseId: 7200,
    overlayBaseId: 7700,
    titleKey: 'hadith_title',
  ),
  ayah(
    enabledKey: 'shouldShowAyahNotification',
    intervalKey: 'timesForShowingAyahNotifications',
    deliveryKey: 'ayah_delivery_mode_v1',
    channelId: 'ayah_reminder_v1',
    channelNameKey: 'reminder_ayah_channel',
    baseId: 7300,
    overlayBaseId: 7800,
    titleKey: 'ayah',
  );

  const ReminderKind({
    required this.enabledKey,
    required this.intervalKey,
    required this.deliveryKey,
    required this.channelId,
    required this.channelNameKey,
    required this.baseId,
    required this.overlayBaseId,
    required this.titleKey,
  });

  final String enabledKey;
  final String intervalKey;

  /// مفتاح Hive لطريقة العرض المختارة لهذا النوع — انظر [ReminderDelivery].
  final String deliveryKey;
  final String channelId;
  /// مفتاح ترجمة لا نصًا جاهزًا: اسم القناة يُقرأ بلغة المستخدم وقت
  /// الجدولة. القناة تُجمَّد على الجهاز بعد إنشائها، فتغيير اللغة لاحقًا
  /// لا يعيد تسميتها — لكن الإشعار نفسه يظل بلغة الجدولة.
  final String channelNameKey;

  /// بداية نطاق معرّفات الإشعارات لهذا النوع (١٠٠ معرّف لكل نوع).
  final int baseId;

  /// بداية نطاق معرّفات منبّهات النافذة العائمة لهذا النوع. نطاق مستقل عن
  /// [baseId]: المنبّهات يديرها `AndroidAlarmManager` لا الإشعارات، والفصل
  /// يجعل استنتاج النوع من معرّف المنبّه ممكنًا داخل العزلة الموقَظة.
  final int overlayBaseId;

  /// عنوان الإشعار الظاهر أعلى النص.
  final String titleKey;
}

/// كيف يصل تذكير هذا النوع إلى المستخدم.
///
/// كان الاختيار سابقًا مفتاحًا عامًا واحدًا (`zikr_overlay_enabled`) يسري
/// على الأذكار وحدها ويعمل *فوق* الإشعارات لا بديلًا عنها، فلم يكن للمستخدم
/// أي وسيلة لقول «الأحاديث كنافذة عائمة فقط» أو «الآيات كإشعار فقط».
enum ReminderDelivery {
  notification,
  floating,
  both;

  bool get hasNotification => this != ReminderDelivery.floating;

  bool get hasFloating => this != ReminderDelivery.notification;

  /// القيمة المحفوظة في Hive نصًّا لا فهرسًا: إعادة ترتيب الثوابت لاحقًا
  /// يجب ألا تُبدّل اختيار المستخدم بصمت.
  static ReminderDelivery fromStorage(Object? raw) {
    return ReminderDelivery.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ReminderDelivery.notification,
    );
  }
}

/// خيارات الفترة. الفهارس مطابقة للقائمة القديمة في شاشة الإشعارات حتى
/// تظل القيمة المحفوظة لدى المستخدم صالحة بعد التحديث.
const List<int> kReminderIntervalsMinutes = [15, 30, 45, 60, 90, 120, 180];

class ReminderScheduler {
  ReminderScheduler._();

  /// إشعار «صلِّ على النبي ﷺ» الدائم — إشعار واحد ثابت لا يُجدول.
  static const int _sallyId = 7400;
  static const String _sallyChannelId = 'sally_persistent_v1';

  /// معرّفات النظام القديم (WorkManager كان يستخدم 1 و2 و3) — تُلغى مرة
  /// واحدة حتى لا يبقى إشعار «دائم» عالقًا من النسخة السابقة.
  static const List<int> _legacyIds = [1, 2, 3];
  static const String _legacyClearedKey = 'reminders_legacy_cleared_v1';

  /// قنوات النسخة القديمة. إعدادات القناة تُجمَّد لحظة إنشائها على الجهاز،
  /// فلا سبيل لتحسينها سوى قناة جديدة + حذف القديمة.
  /// أيقونة الإشعار الصغيرة (res/drawable/ic_stat_azkary.xml) — قناع أبيض
  /// شفاف. `@drawable/icon` كان شعارًا ملوّنًا يظهر مربّعًا مصمتًا.
  static const String _smallIcon = 'ic_stat_azkary';

  static const List<String> _staleChannelIds = [
    'channelId',
    'channelId22',
    'channelId3',
  ];

  /// مفاتيح نافذة التذكير النشطة (لا نُزعج المستخدم أثناء النوم).
  static const String startHourKey = 'reminderStartHour';
  static const String endHourKey = 'reminderEndHour';
  static const int defaultStartHour = 7;
  static const int defaultEndHour = 23;

  /// سقف الإشعارات المعلّقة: iOS يسمح بـ ٦٤ إشعارًا معلّقًا للتطبيق كله،
  /// والأذان يحجز عشرة منها. أندرويد يتحمل مئات المنبهات فنتركه أوسع.
  static const int _iosBudget = 50;

  /// أوسع نافذة معقولة (٧ص–١١م) على أقصر فترة (١٥ دقيقة) = ٦٥ موعدًا،
  /// فسبعون تكفي لتغطيتها كاملة بلا تخفيف — التخفيف يجعل الفواصل غير
  /// منتظمة (١٥ ثم ٣٠) وهو ما يناقض ما اختاره المستخدم.
  static const int _androidSlotsPerKind = 72;

  /// نداءات التسليح قد تتزامن (الإقلاع + الشاشة). نسلسلها حتى لا يتداخل
  /// الإلغاء مع الجدولة فتبقى خانات نصف مبنية.
  static Future<void> _inFlight = Future<void>.value();

  static final Random _random = Random();

  /// بصمة آخر تسليح ناجح (Hive) — انظر [armOnLaunch].
  static const String _armedSignatureKey = 'reminders_armed_signature';

  // ---------------------------------------------------------------- التهيئة

  /// مشتركة مع [AzanScheduler] — القاعدة تُفكّ مرة واحدة لا مرتين.
  static Future<void> _ensureTimezone() => ensureTimeZones();

  /// نسخة مهيّأة من الإضافة. نُهيّئها هنا صراحةً بدل الاعتماد على المتغيّر
  /// العام: الإضافة كائن لكل عزلة، والاعتماد على تهيئة تمت في مكان آخر هو
  /// بالضبط ما كان يُسقط الإشعارات القديمة.
  static Future<FlutterLocalNotificationsPlugin> _plugin() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      // قناع أبيض شفاف — انظر res/drawable/ic_stat_azkary.xml
      android: AndroidInitializationSettings(_smallIcon),
      iOS: DarwinInitializationSettings(
        // الأذونات تُطلب صراحةً من [AppPermissions] لا تلقائيًا عند الإقلاع
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    // الاستجابة تذهب لآخر تهيئة فقط — نمرّر معالج الأذان حتى لا نمسحه
    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: AzanAlarm.onResponse,
    );
    return plugin;
  }

  static AndroidFlutterLocalNotificationsPlugin? _android() {
    if (!Platform.isAndroid) return null;
    return FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
  }

  // ---------------------------------------------------------------- الإعدادات

  static bool isEnabled(ReminderKind kind) =>
      getValue(kind.enabledKey) == true;

  static int intervalIndex(ReminderKind kind) {
    final raw = getValue(kind.intervalKey);
    final index = raw is int ? raw : 0;
    return index.clamp(0, kReminderIntervalsMinutes.length - 1);
  }

  static int intervalMinutes(ReminderKind kind) =>
      kReminderIntervalsMinutes[intervalIndex(kind)];

  /// طريقة العرض المختارة لهذا النوع. الافتراضي إشعار — وهو سلوك النسخ
  /// السابقة، فالترقية لا تُغيّر شيئًا لمن لم يختر بعد.
  static ReminderDelivery deliveryOf(ReminderKind kind) =>
      ReminderDelivery.fromStorage(getValue(kind.deliveryKey));

  static int get startHour {
    final raw = getValue(startHourKey);
    return raw is int ? raw.clamp(0, 23) : defaultStartHour;
  }

  static int get endHour {
    final raw = getValue(endHourKey);
    return raw is int ? raw.clamp(0, 23) : defaultEndHour;
  }

  /// تغيير مفتاح تشغيل نوع + إعادة التسليح فورًا.
  ///
  /// `updateValue` تعيد Future من Hive؛ إهمالها يعني أن المفتاح قد لا يصل
  /// القرص قبل أن يقتل النظام العملية، فيعود الإعداد لسابقه عند التشغيل
  /// التالي بينما الإشعارات مجدولة بالفعل (أو العكس). ننتظرها دائمًا.
  static Future<void> setEnabled(ReminderKind kind, bool value) async {
    await updateValue(kind.enabledKey, value);
    await arm();
  }

  static Future<void> setIntervalIndex(ReminderKind kind, int index) async {
    await updateValue(
        kind.intervalKey, index.clamp(0, kReminderIntervalsMinutes.length - 1));
    await arm();
  }

  /// تغيير طريقة العرض. الإذن (إشعارات / عرض فوق التطبيقات) تفحصه الشاشة
  /// قبل النداء: المُجدوِل لا يملك سياق واجهة يطلب به إذنًا.
  static Future<void> setDelivery(
      ReminderKind kind, ReminderDelivery mode) async {
    await updateValue(kind.deliveryKey, mode.name);
    await arm();
  }

  static Future<void> setActiveWindow({int? start, int? end}) async {
    if (start != null) await updateValue(startHourKey, start.clamp(0, 23));
    if (end != null) await updateValue(endHourKey, end.clamp(0, 23));
    await arm();
  }

  static Future<void> setSallyEnabled(bool value) async {
    await updateValue('shouldShowSallyNotification', value);
    await arm();
  }

  // ---------------------------------------------------------------- التسليح

  /// يلغي كل تذكيراتنا ويعيد بناءها من الإعدادات المحفوظة.
  /// تُستدعى عند الإقلاع وبعد كل تغيير في الشاشة.
  static Future<void> arm() {
    // النافذة العائمة تشترك مع الإشعارات في الفترة والنافذة النشطة وطريقة
    // العرض، فأي تغيير يمسّ القناتين معًا. تسليحها هنا يعني أن كل مستدعٍ
    // (الإقلاع، الشاشة، منح إذن) يحصل على الاثنتين متسقتين بنداء واحد.
    final next = _inFlight.then((_) => _arm()).then((ok) async {
      await OverlayScheduler.arm();
      // لا تُحفظ البصمة عند الفشل، فيُعاد المحاولة في الإقلاع التالي
      if (ok) await updateValue(_armedSignatureKey, _signature());
    });
    _inFlight = next;
    return next;
  }

  /// تسليح الإقلاع: يُتخطّى إن لم يتغيّر شيء منذ آخر تسليح ناجح اليوم.
  ///
  /// كل تسليح مئات من نداءات الإلغاء والجدولة، وكل نداء في الإضافة يعيد
  /// كتابة قائمتها المحفوظة كاملة على الخيط الرئيسي لأندرويد — فتكراره مع
  /// كل فتح للتطبيق كان يُقطّع الرئيسية. الإشعارات متكررة يوميًا فتبقى
  /// قائمة بلا إعادة. الشاشة وتغيير الإعدادات ومنح الأذونات تستدعي [arm]
  /// مباشرةً فلا تمرّ بهذا الفحص.
  static Future<void> armOnLaunch() {
    if (getValue(_armedSignatureKey) == _signature()) {
      debugPrint('ReminderScheduler: unchanged since last arm today — skipped');
      return Future<void>.value();
    }
    return arm();
  }

  /// كل ما يؤثّر في الجدولة. اليوم ضمنها لأن المحتوى يُدوَّر مع كل تسليح
  /// والنوافذ العائمة لا تغطّي إلا اليوم والغد. العنوان المترجم يمثّل اللغة.
  static String _signature() {
    final now = DateTime.now();
    return [
      '${now.year}-${now.month}-${now.day}',
      for (final kind in ReminderKind.values)
        '${kind.name}:${isEnabled(kind)}:${intervalIndex(kind)}:${deliveryOf(kind).name}',
      startHour,
      endHour,
      getValue('shouldShowSallyNotification') == true,
      ReminderKind.values.first.titleKey.tr(),
    ].join('|');
  }

  static Future<bool> _arm() async {
    try {
      await _ensureTimezone();
      final plugin = await _plugin();

      await _clearLegacy(plugin);
      await _dropStaleChannels();

      // نوع مفعّل بطريقة «عائمة» فقط لا يحجز خانة إشعار ولا حصة من ميزانية
      // iOS: الخانات المحجوزة له كانت ستُهدر على إشعارات لا تُعرض.
      final enabled = ReminderKind.values
          .where((k) => isEnabled(k) && deliveryOf(k).hasNotification)
          .toList(growable: false);
      final slotBudget = _slotBudgetPerKind(enabled.length);

      // نحسب المعرّفات التي ستُعاد جدولتها قبل التنظيف: `cancel` تُسقط
      // الإشعار المعروض أيضًا لا الجدولة وحدها، وإعادة الجدولة بنفس
      // المعرّف تستبدل الموعد القديم أصلًا — فلا داعي لإلغائه.
      final keep = <int>{};
      for (final kind in enabled) {
        final count = _slots(intervalMinutes(kind), slotBudget).length;
        for (var i = 0; i < count; i++) {
          keep.add(kind.baseId + i);
        }
      }
      await _cancelOurRange(plugin, keep: keep);

      var total = 0;
      for (final kind in enabled) {
        total += await _scheduleKind(plugin, kind, slotBudget);
      }

      await _applySally(plugin);

      debugPrint('ReminderScheduler: armed $total reminder slots '
          '(${enabled.map((k) => k.name).join(", ")})');
      return true;
    } catch (e) {
      // الجدولة تحسينية — فشلها يجب ألا يكسر إقلاع التطبيق
      debugPrint('ReminderScheduler.arm failed: $e');
      return false;
    }
  }

  static int _slotBudgetPerKind(int enabledCount) {
    if (enabledCount == 0) return 0;
    if (Platform.isIOS) return max(1, _iosBudget ~/ enabledCount);
    return _androidSlotsPerKind;
  }

  /// يلغي كل ما هو داخل نطاقنا عدا المعرّفات في [keep] — وهي التي ستُعاد
  /// جدولتها بعد قليل بنفس المعرّف.
  static Future<void> _cancelOurRange(
    FlutterLocalNotificationsPlugin plugin, {
    required Set<int> keep,
  }) async {
    final pending = await plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (keep.contains(request.id)) continue;
      for (final kind in ReminderKind.values) {
        if (request.id >= kind.baseId && request.id < kind.baseId + 100) {
          await plugin.cancel(request.id);
        }
      }
    }
  }

  static Future<int> _scheduleKind(
    FlutterLocalNotificationsPlugin plugin,
    ReminderKind kind,
    int slotBudget,
  ) async {
    final pool = await contentPool(kind);
    if (pool.isEmpty) {
      debugPrint('ReminderScheduler: ${kind.name} pool empty — skipped');
      return 0;
    }

    final slots = _slots(intervalMinutes(kind), slotBudget);
    if (slots.isEmpty) return 0;

    // إزاحة عشوائية تتغيّر مع كل تسليح، فيتبدّل المحتوى كلما فُتح التطبيق
    final offset = _random.nextInt(pool.length);
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = 0;
    for (var i = 0; i < slots.length; i++) {
      final body = pool[(offset + i) % pool.length];
      var when = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        slots[i] ~/ 60,
        slots[i] % 60,
      );
      // موعد اليوم فات؟ نبدأ من الغد — والتكرار اليومي يتكفّل بالباقي
      if (!when.isAfter(now)) {
        when = when.add(const Duration(days: 1));
      }

      final ok = await _schedule(
        plugin,
        id: kind.baseId + i,
        title: kind.titleKey.tr(),
        body: body,
        when: when,
        details: _detailsFor(kind, body),
      );
      if (ok) scheduled++;
    }
    return scheduled;
  }

  /// يجدول إشعارًا واحدًا متكررًا يوميًا، مع التراجع لجدولة تقريبية إذا
  /// منع أندرويد ١٢+ المنبهات الدقيقة.
  static Future<bool> _schedule(
    FlutterLocalNotificationsPlugin plugin, {
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required NotificationDetails details,
  }) async {
    Future<void> attempt(AndroidScheduleMode mode) => plugin.zonedSchedule(
          id,
          title,
          body,
          when,
          details,
          androidScheduleMode: mode,
          // التكرار اليومي هو ما يجعل التذكيرات تستمر بلا حاجة لفتح التطبيق
          matchDateTimeComponents: DateTimeComponents.time,
        );

    try {
      await attempt(AndroidScheduleMode.exactAllowWhileIdle);
      return true;
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') {
        debugPrint('ReminderScheduler: schedule $id failed: $e');
        return false;
      }
      try {
        await attempt(AndroidScheduleMode.inexactAllowWhileIdle);
        return true;
      } catch (e2) {
        debugPrint('ReminderScheduler: inexact fallback $id failed: $e2');
        return false;
      }
    } catch (e) {
      debugPrint('ReminderScheduler: schedule $id failed: $e');
      return false;
    }
  }

  /// مواعيد اليوم بالدقائق منذ منتصف الليل، داخل النافذة النشطة، مُخفَّفة
  /// إلى [budget] موعدًا كحد أقصى بتوزيع متساوٍ.
  static List<int> _slots(int intervalMinutes, int budget) {
    final start = startHour * 60;
    // نافذة تعبر منتصف الليل (مثلًا ٢٢ ← ٦) تُعامل كامتداد لليوم التالي
    final rawEnd = endHour * 60;
    final end = rawEnd > start ? rawEnd : rawEnd + 24 * 60;

    final all = <int>[];
    for (var t = start; t <= end; t += intervalMinutes) {
      all.add(t % (24 * 60));
    }
    if (all.isEmpty || all.length <= budget) return all;

    // تخفيف متساوي البُعد بدل قصّ الذيل، حتى يبقى التذكير موزّعًا على اليوم
    final step = all.length / budget;
    return List<int>.generate(budget, (i) => all[(i * step).floor()]);
  }

  // ---------------------------------------------------------------- المحتوى

  /// عامة لا خاصة: [OverlayScheduler] يقرأ منها ليُودع نصوص النوع في
  /// SharedPreferences قبل أن توقظه المنبّهات في عزلة بلا Hive ولا مصحف
  /// محمّل.
  static Future<List<String>> contentPool(ReminderKind kind) async {
    switch (kind) {
      case ReminderKind.zikr:
        return zikrNotfications
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);

      case ReminderKind.hadith:
        return hadithes
            .map((e) => (e['hadith'] ?? '').toString().trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);

      case ReminderKind.ayah:
        return _ayahPool();
    }
  }

  /// آيات من نص المصحف المحمّل في `quran_library`. نستخدم `ayaTextEmlaey`
  /// (الرسم الإملائي) لا `text`: الأخير يعتمد خطوط المصحف المضمّنة ولن
  /// يُرسم صحيحًا داخل إشعار النظام.
  static Future<List<String>> _ayahPool() async {
    try {
      // تهيئة المكتبة أولًا: QuranCtrl.instance قبلها يقرأ إعدادات المصحف
      // المحفوظة قبل أن تُهيّأ. التهيئة مشتركة فلا تُحمَّل البيانات مرتين.
      await ensureQuranReady();
      final ctrl = QuranCtrl.instance;
      if (ctrl.state.allAyahs.isEmpty) {
        await ctrl.ensureCoreDataLoaded();
      }
      return ctrl.state.allAyahs
          .map((a) => a.ayaTextEmlaey.trim())
          .where((t) => t.length > 15 && t.length < 220)
          .toList(growable: false);
    } catch (e) {
      debugPrint('ReminderScheduler: ayah pool unavailable: $e');
      return const [];
    }
  }

  /// [body] يمرّ إلى BigTextStyleInformation أيضًا: بدونه يظهر الإشعار
  /// الموسّع فارغًا، والأذكار والأحاديث أطول من سطر الإشعار المطوي.
  static NotificationDetails _detailsFor(ReminderKind kind, String body) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        kind.channelId,
        kind.channelNameKey.tr(),
        channelDescription: 'reminder_channel_desc'.tr(namedArgs: {'kind': kind.titleKey.tr()}),
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        icon: _smallIcon,
        styleInformation:
            BigTextStyleInformation(body, contentTitle: kind.titleKey.tr()),
        groupKey: 'azkary_reminders',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        threadIdentifier: 'azkary_reminders',
      ),
    );
  }

  // ------------------------------------------------- إشعار الصلاة على النبي

  static bool get isSallyEnabled =>
      getValue('shouldShowSallyNotification') == true;

  /// إشعار دائم لا يُمسح بالسحب. يُعاد عرضه عند كل تسليح لأن إشعارات
  /// أندرويد لا تنجو من إعادة تشغيل الجهاز.
  static Future<void> _applySally(FlutterLocalNotificationsPlugin plugin) async {
    if (!isSallyEnabled) {
      await plugin.cancel(_sallyId);
      return;
    }
    await plugin.show(
      _sallyId,
      'sally_title'.tr(),
      'اللهم صلِّ وسلِّم على نبينا محمد',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _sallyChannelId,
          'sally_channel_name'.tr(),
          channelDescription: 'sally_channel_desc'.tr(),
          // منخفض عمدًا: إشعار مقيم لا ينبغي أن يُصدر صوتًا أو يقفز للشاشة
          importance: Importance.low,
          priority: Priority.low,
          icon: _smallIcon,
          ongoing: true,
          autoCancel: false,
          playSound: false,
          onlyAlertOnce: true,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(presentSound: false),
      ),
    );
  }

  // ---------------------------------------------------------------- التجربة

  /// إشعار فوري بنموذج من محتوى النوع — زر «عرض مثال» في الشاشة.
  static Future<bool> showSample(ReminderKind kind) async {
    try {
      final pool = await contentPool(kind);
      if (pool.isEmpty) return false;
      final plugin = await _plugin();
      final body = pool[_random.nextInt(pool.length)];
      await plugin.show(
        kind.baseId + 99,
        kind.titleKey.tr(),
        body,
        _detailsFor(kind, body),
      );
      return true;
    } catch (e) {
      debugPrint('ReminderScheduler.showSample failed: $e');
      return false;
    }
  }

  /// عدد التذكيرات المعلّقة فعليًا لدى النظام — تُستخدم في الشاشة لتأكيد
  /// أن الجدولة تمت حقًا بدل الاكتفاء بمظهر المفتاح.
  static Future<int> pendingCount() async {
    try {
      final plugin = await _plugin();
      final pending = await plugin.pendingNotificationRequests();
      return pending
          .where((r) => ReminderKind.values
              .any((k) => r.id >= k.baseId && r.id < k.baseId + 100))
          .length;
    } catch (_) {
      return 0;
    }
  }

  // ---------------------------------------------------------------- التنظيف

  static Future<void> _dropStaleChannels() async {
    final android = _android();
    if (android == null) return;
    for (final id in _staleChannelIds) {
      try {
        await android.deleteNotificationChannel(id);
      } catch (_) {
        // لا شيء يعتمد عليها — القنوات الجديدة تُنشأ عند أول إشعار
      }
    }
  }

  static Future<void> _clearLegacy(FlutterLocalNotificationsPlugin plugin) async {
    if (getValue(_legacyClearedKey) == true) return;
    try {
      for (final id in _legacyIds) {
        await plugin.cancel(id);
      }
      await updateValue(_legacyClearedKey, true);
      debugPrint('ReminderScheduler: legacy WorkManager notifications cleared');
    } catch (e) {
      // نتركها لمحاولة لاحقة — لا نضع العلامة عند الفشل
      debugPrint('ReminderScheduler: legacy cleanup failed: $e');
    }
  }
}
