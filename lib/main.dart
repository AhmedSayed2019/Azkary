import 'dart:async';

import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/data/local/cache_consumer.dart';
import 'package:azkark/data/models/preference.dart';
import 'package:azkark/features/notifications/logic/reminder_scheduler.dart';
import 'package:azkark/features/notifications/logic/zikr_overlay_scheduler.dart';
import 'package:azkark/features/notifications/views/zikr_overlay.dart';
import 'package:azkark/features/prayer/azan_scheduler.dart';
import 'package:azkark/widgets/islamic_header_background.dart';
import 'package:azkark/firebase_options.dart';
import 'package:azkark/injection.dart';
import 'package:azkark/providers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran.dart';

import 'app.dart';
// import 'features/quran/common/storage/repository/storage_manager.dart';




// void start() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final sharedPreferences = await SharedPreferences.getInstance();
//   await StorageManager.init();
//
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
//     runApp(ProviderScope(
//       overrides: [
//         prefServiceProvider.overrideWithValue(PrefService(sharedPreferences)),
//       ],
//       child: App(),
//     ));
//   });
// }

// أُزيلت النافذة العائمة للأذكار (flutter_overlay_window + WorkManager).
//
// السبب ليس تفضيلًا في التصميم بل عطبان يُسقطان التطبيق على أندرويد الحديث:
//
//  ١) `OverlayService` في الإضافة يبني قنواته في مُهيّئات الحقول من
//     `FlutterEngineCache.get(CACHED_TAG).getDartExecutor()` بلا فحص null،
//     والمحرّك لا يوضع في الذاكرة إلا داخل `onAttachedToActivity`. مهمة
//     WorkManager تعمل بلا Activity، فحين يوقظ النظام العملية والتطبيق
//     مغلق — وهو بالضبط ما كان الخيار يَعِد به — ينهار بـ
//     NullPointerException ويسقط التطبيق كله.
//
//  ٢) targetSdk 36: بدء خدمة أمامية بلا `foregroundServiceType` يرمي
//     `MissingForegroundServiceTypeException`. النوع الوحيد المنطبق هو
//     `specialUse` وهو مقيّد بمراجعة يدوية في متجر Play.
//
// المحتوى نفسه (ذكر عشوائي على مدار اليوم) يصل الآن عبر [ReminderScheduler]
// كإشعار نظام مجدول يعمل والتطبيق مغلق ولا يحتاج SYSTEM_ALERT_WINDOW.

// Future<void> setOptimalDisplayMode() async {
//   final List<DisplayMode> supported = await FlutterDisplayMode.supported;
//   final DisplayMode active = await FlutterDisplayMode.active;
// // print(supported);
// // print(active.refreshRate);
//
//   final List<DisplayMode> sameResolution = supported
//       .where((DisplayMode m) =>
//   m.width == active.width && m.height == active.height)
//       .toList()
//     ..sort((DisplayMode a, DisplayMode b) =>
//         b.refreshRate.compareTo(a.refreshRate));
//
//   final DisplayMode mostOptimalMode =
//   sameResolution.isNotEmpty ? sameResolution.first : active;
// // print(mostOptimalMode.refreshRate);
//   /// This setting is per session.
//   /// Please ensure this was placed with `initState` of your root widget.
//   await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
//   //  final activee = await FlutterDisplayMode.active;
//   //   print(mostOptimalMode.refreshRate);
// }

/// نقطة دخول العزلة الخاصة بالنافذة العائمة.
///
/// اسم الدالة `overlayMain` ليس اختياريًا: الإضافة تُشغّل هذا الاسم حرفيًا
/// كـ DartEntrypoint، و`@pragma('vm:entry-point')` يمنع مُحسِّن الشيفرة
/// في وضع الإصدار من حذفها لأنها بلا مُستدعٍ ظاهر في الكود.
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZikrOverlay());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  //adan
  await initPreferences();
  //Quran
  await QuranLibrary.init();

  await EasyLocalization.ensureInitialized();

  CacheConsumer.init();
  await initializeHive();
  // نسيج هيدر الرئيسية — تحميله مسبقًا يمنع ومضة الخلفية عند أول بناء
  await precacheIslamicPattern();

  // إعادة تسليح الجدولة عند كل تشغيل (دون حجب الإقلاع)
  unawaited(AzanScheduler.reschedule());
  unawaited(ReminderScheduler.arm());
  unawaited(ZikrOverlayScheduler.arm());

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale("ar"),
      ],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      child: const GenerateMultiProvider(
        child: MyApp(),
      ),
    ),
  );
}
