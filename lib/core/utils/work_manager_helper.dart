import 'dart:async';
import 'dart:math';

import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/messaging_helper.dart';
import 'package:azkark/core/utils/notifications/data/40hadith.dart';
import 'package:azkark/core/utils/notifications/views/small_notification_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notificationPlugin;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:quran/quran.dart';
import 'package:workmanager/workmanager.dart';


class WorkManagerHelper{



 static init(){
   Workmanager().initialize(
       callbackDispatcher, // The top level function, aka callbackDispatcher
       isInDebugMode:
       false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
   );
  }
 @pragma("vm:entry-point")
 void overlayMain() {
   WidgetsFlutterBinding.ensureInitialized();
   runApp(
     const TrueCallerOverlay(),
   );
 }
 @pragma(  'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
 static callbackDispatcher() {
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
                   "channelId2",
                   importance: notificationPlugin.Importance.max,
                   groupKey: "zikr,",
                   "Zikr")));

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
                   "channelId2",
                   importance: notificationPlugin.Importance.max,
                   groupKey: "zikr,",
                   "Zikr" //,ongoing: true
               )));

       ///show local notification
       ///
     } else if (task == "ayahNot") {
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
     } else if (task == "hadithNot") {
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
     print(
         "Native called background task: $task"); //simpleTask will be emitted here.
     return Future.value(true);
   });
 }

}