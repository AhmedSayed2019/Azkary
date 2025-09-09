// import 'package:device_preview/device_preview.dart';
import 'dart:developer' show log;

import 'package:azkark/core/quran_library/audio/audio.dart';
import 'package:azkark/core/quran_library/quran_library.dart';
import 'package:flutter/material.dart';




class QuranPagesTest extends StatefulWidget {
  const QuranPagesTest({super.key});

  @override
  State<QuranPagesTest> createState() => _QuranPagesTestState();
}

class _QuranPagesTestState extends State<QuranPagesTest> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primaryColor: Theme.of(context).primaryColor,
        useMaterial3: false,
      ),
      home: Scaffold(
        body: SurahDisplayScreen(
          surahNumber: 18,
          isDark: false,
          languageCode: 'ar',
          useDefaultAppBar: false,
          anotherMenuChild:
              Icon(Icons.play_arrow_outlined, size: 28, color: Colors.grey),
          anotherMenuChildOnTap: (ayah) {
            // SurahAudioController.instance.state.currentAyahUnequeNumber =
            //     ayah.ayahUQNumber;
            AudioCtrl.instance
                .playAyah(context, ayah.ayahUQNumber, playSingleAyah: true);
            log('Another Menu Child Tapped: ${ayah.ayahUQNumber}');
          },
          secondMenuChild:
              Icon(Icons.playlist_play, size: 28, color: Colors.grey),
          secondMenuChildOnTap: (ayah) {
            // SurahAudioController.instance.state.currentAyahUnequeNumber =
            //     ayah.ayahUQNumber;
            AudioCtrl.instance
                .playAyah(context, ayah.ayahUQNumber, playSingleAyah: false);
            log('Second Menu Child Tapped: ${ayah.ayahUQNumber}');
          }, parentContext: context,
        ),
        // body: QuranLibraryScreen(
        //   parentContext: context,
        //   isDark: false,
        //   showAyahBookmarkedIcon: true,
        //   ayahIconColor: const Color(0xffcdad80),
        //   // backgroundColor: Colors.white,
        //   // textColor: Colors.black,
        //   isFontsLocal: false,
        //   anotherMenuChild:
        //   const Icon(Icons.play_arrow_outlined, size: 28, color: Colors.grey),
        //   anotherMenuChildOnTap: (ayah) {
        //     // SurahAudioController.instance.state.currentAyahUnequeNumber =
        //     //     ayah.ayahUQNumber;
        //     AudioCtrl.instance
        //         .playAyah(context, ayah.ayahUQNumber, playSingleAyah: true);
        //     log('Another Menu Child Tapped: ${ayah.ayahUQNumber}');
        //   },
        //   secondMenuChild:
        //   const Icon(Icons.playlist_play, size: 28, color: Colors.grey),
        //   secondMenuChildOnTap: (ayah) {
        //     // SurahAudioController.instance.state.currentAyahUnequeNumber =
        //     //     ayah.ayahUQNumber;
        //     AudioCtrl.instance
        //         .playAyah(context, ayah.ayahUQNumber, playSingleAyah: false);
        //     log('Second Menu Child Tapped: ${ayah.ayahUQNumber}');
        //   },
        // ),
      ),
    );
  }
}