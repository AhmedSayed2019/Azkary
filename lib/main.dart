import 'dart:io';

import 'package:azkark/core/quran_library/quran_library.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/core/utils/work_manager_helper.dart';
import 'package:azkark/data/local/cache_consumer.dart';
import 'package:azkark/firebase_options.dart';
import 'package:azkark/injection.dart';
import 'package:azkark/providers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metadata_god/metadata_god.dart';

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


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );




  await QuranLibrary.init();
  await QuranLibrary.initTafsir();




  // await safeInitMetadataGod(); // <- won’t crash if .so not found

  await EasyLocalization.ensureInitialized();
  WorkManagerHelper.init();

  CacheConsumer.init();
  await initializeHive();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);



  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
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
  });
}
