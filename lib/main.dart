import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/core/utils/messaging_helper.dart';
import 'package:azkark/core/utils/notifications/data/40hadith.dart';
import 'package:azkark/data/local/cache_consumer.dart';
import 'package:azkark/data/models/preference.dart';
import 'package:azkark/features/home/widgets/azan/islamic_header_background.dart';
import 'package:azkark/features/notifications/views/small_notification_popup.dart';
import 'package:azkark/firebase_options.dart';
import 'package:azkark/injection.dart';
import 'package:azkark/providers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_overlay/easy_overlay.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
as notificationPlugin;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:quran_library/quran.dart';
import 'package:workmanager/workmanager.dart';

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

Future<void> safeInitMetadataGod() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  try {
    await MetadataGod.initialize();
  } catch (e, st) {
    debugPrint('MetadataGod init skipped: $e');
    // optionally report/log
  }
}

// // overlay entry point
// @pragma("vm:entry-point")
// void overlayMain() {
//   runApp(const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Material(child: Text("My overlay"))
//   ));
// }


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection();


  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // await permissions.request();

  // setOptimalDisplayMode();
  // MediaStore.appFolder = "Skoon";
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
      false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  //adan
  await initPreferences();
  //Quran
  await QuranLibrary.init();
  // await QuranLibrary.initTafsir();
  // await q.QuranLibrary.init();



  // await safeInitMetadataGod(); // <- won’t crash if .so not found

  await EasyLocalization.ensureInitialized();
  // WorkManagerHelper.init();

  CacheConsumer.init();
  await initializeHive();
  // نسيج هيدر الرئيسية — تحميله مسبقًا يمنع ومضة الخلفية عند أول بناء
  await precacheIslamicPattern();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));

  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale("ar"),
          // Locale('en'),
          // Locale('de'),
          // Locale("am"),
          // Locale("ms"),
          // Locale("pt"),
          // Locale("tr"),
          // Locale("ru")
        ],
        path: 'assets/translations',
        // fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        child: const GenerateMultiProvider(
          child: MyApp(),
        ),
      ),
    );
  // });
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(TrueCallerOverlay());
}


// @pragma("vm:entry-point")
// void overlayMain() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     const TrueCallerOverlay(),
//   );
// }

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();


    if (task == "zikrNotification") {
      if (await FlutterOverlayWindow.isActive()) {
        FlutterOverlayWindow.closeOverlay();
        // return;
      }
      //300/700 ان الله وملائكته
      //سبحان الله      //  height: 150,
      // width: 240,
      // final SharedPreferences prefs = await SharedPreferences.getInstance();

      // int? index = prefs.getInt("zikrNotificationindex") ?? 0;
// Calculate the text size
      // print(ayahNotfications[index].trim().length *3);
      // print(ayahNotfications[index].trim().length *3);

      // await FlutterOverlayWindow.showOverlay(
      //   height: 50, // (MediaQuery.of(context).size.height*0.6).toInt(),
      //   width: 200,  //WindowSize.matchParent,
      //   alignment: OverlayAlignment.center,
      //   flag: OverlayFlag.defaultFlag,
      //   visibility: NotificationVisibility.visibilityPublic,
      //   enableDrag: true,
      //   overlayTitle: 'test',
      //   overlayContent: 'This is a test overlay',
      //   startPosition: OverlayPosition(0, -259),
      //   // overlayContentPackageName: 'com.example.azkark',
      // );
      EasyOverlay.show(
        child: TrueCallerOverlay(),
      );
      // await FlutterOverlayWindow.showOverlay(
      //   enableDrag: true,
      //   overlayTitle: "ذكر",
      //   alignment: OverlayAlignment.center,
      //   overlayContent: 'ذكر من سكينة',
      //   flag: OverlayFlag.defaultFlag,
      //   visibility: NotificationVisibility.visibilityPublic,
      //   positionGravity: PositionGravity.auto,
      //   startPosition: OverlayPosition(0, -259),
      //   height: 100,
      //   width: (MediaQuery.of(context).size.width*0.9),
      // );
    } else if (task == "zikrNotificationTest") {
      if (await FlutterOverlayWindow.isActive()) {
        FlutterOverlayWindow.closeOverlay();
        // return;
      }
      //300/700 ان الله وملائكته
      //سبحان الله      //  height: 150,
      // width: 240,
      // final SharedPreferences prefs = await SharedPreferences.getInstance();

      // int? index = prefs.getInt("zikrNotificationindex") ?? 0;
// Calculate the text size
      // print(ayahNotfications[index].trim().length *3);
      // print(ayahNotfications[index].trim().length *3);

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Zikr Notification",
        alignment: OverlayAlignment.center,
        overlayContent: 'Overlay Enabled',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: 400,
        width: WindowSize.matchParent,
      );
    } else if (task == "zikrNotification2") {
//  final SharedPreferences prefs = await SharedPreferences.getInstance();

      int? index = Random().nextInt(zikrNotfications.length);

      flutterLocalNotificationsPlugin.show(
        2,
        zikrNotfications[index],
        "",
        notificationPlugin.NotificationDetails(
          android: notificationPlugin.AndroidNotificationDetails(
              styleInformation: notificationPlugin.BigTextStyleInformation(
                zikrNotfications[index], contentTitle: "Zikr",
                htmlFormatBigText: true,
                // htmlFormatBigText: true
              ),
              "channelId22",
              importance: notificationPlugin.Importance.max,
              groupKey: "zikr,",
              "Zikr"),
        ),
      );

      ///show local notification
      ///
    } else if (task == "zikrNotificationTest2") {
      int? index = Random().nextInt(zikrNotfications.length);

      flutterLocalNotificationsPlugin.show(
          2,
          zikrNotfications[index],
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  colorized: true,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    zikrNotfications[index], contentTitle: "Zikr",
                    htmlFormatBigText: true,

                    // htmlFormatBigText: true
                  ),
                  "channelId22",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "zikr,",
                  "Zikr" //,ongoing: true
              )));

      ///show local notification
      ///
    } /*else if (task == "ayahNot") {
      int suraNumber = Random().nextInt(114) + 1;
      int verseNumber = Random().nextInt(getVerseCount(suraNumber)) + 1;
      flutterLocalNotificationsPlugin.show(
          1,
          getVerse(suraNumber, verseNumber),
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    getVerse(suraNumber, verseNumber), contentTitle: "Ayah",
                    htmlFormatBigText: true,

                    // htmlFormatBigText: true
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "verses,",
                  "verses")));

      ///show local notification
      ///
    } else if (task == "ayahNotTest") {
      int suraNumber = Random().nextInt(114) + 1;
      int verseNumber = Random().nextInt(getVerseCount(suraNumber)) + 1;
      flutterLocalNotificationsPlugin.show(
          1,
          getVerse(suraNumber, verseNumber),
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    getVerse(suraNumber, verseNumber),
                    contentTitle: "Ayah",
                    htmlFormatBigText: true,
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "verses,",
                  "verses")));

      ///show local notification
      ///
    }*/ else if (task == "hadithNot") {
      int suraNumber = Random().nextInt(42);
      flutterLocalNotificationsPlugin.show(
          3,
          hadithes[suraNumber]["hadith"],
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    hadithes[suraNumber]["hadith"],
                    contentTitle: "Hadith",
                    htmlFormatBigText: true,
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "vehadith,",
                  "hadith")));
    } else if (task == "hadithNotTest") {
      int suraNumber = Random().nextInt(42);
      flutterLocalNotificationsPlugin.show(
          3,
          hadithes[suraNumber]["hadith"],
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    hadithes[suraNumber]["hadith"],
                    contentTitle: "Hadith",
                    htmlFormatBigText: true,
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "vehadith,",
                  "hadith")));

      ///show local notification
      ///
    } else if (task == "sallahEnable") {
      flutterLocalNotificationsPlugin.show(
          3,
          "صلِّ على النبي ﷺ",
          "",
          const notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  "channelId3",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "sallah",
                  "Sally",
                  ongoing: true)));
    } else if (task == "sallahDisable") {
      flutterLocalNotificationsPlugin.cancel(3);
    }
    print( "Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}


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
