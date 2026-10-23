import 'dart:async';

import 'package:azkark/core/res/theme_helper.dart';
import 'package:azkark/features/quran/quran_init.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:quran_library/quran.dart';

class QuranPagesPro extends StatefulWidget {
  const QuranPagesPro({Key? key}) : super(key: key);

  @override
  State<QuranPagesPro> createState() => _QuranPagesProState();
}

class _QuranPagesProState extends State<QuranPagesPro> {
  /// Created once in initState so rebuilds never restart the wait.
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = _prepare();
  }

  Future<void> _prepare() async {
    // Library init is no longer awaited at launch (see quran_init.dart); if
    // the Quran is opened before it finishes, wait here before touching
    // QuranCtrl / QuranFontsService.
    await ensureQuranReady();

    final ctrl = QuranCtrl.instance;
    // hafsMushafTajweed (index 0) is the only recitation this version ships;
    // any other value disables the QPC V4 page layout entirely and renders
    // nothing, so force it back regardless of persisted/stray state.
    ctrl.state.fontsSelected.value = 0;

    // Only a small window of page fonts around the current page is loaded up
    // front; the reader loads the next window on every page change. Loading
    // all 604 pages (x5 colour variants) in the background re-laid-out every
    // text in the app for minutes and held hundreds of MB of font data.
    final currentPage = ctrl.state.currentPageNumber.value;
    // نمرّر سمة التطبيق الفعلية حتى يُسجَّل متغيّر الخط الصحيح وحده
    final isDark = context.read<ThemeHelper>().isDarkMode;
    unawaited(QuranFontsService.ensurePagesLoaded(currentPage,
        radius: 1, isDark: isDark));
    // Start loading the QPC v4 layout data now instead of on the first page
    // build (it is decoded off the UI isolate).
    unawaited(ctrl.prewarmQpcV4Pages(currentPage - 1));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          // QuranCtrl.onInit still loads the core data on its own, so show
          // the reader rather than a dead end.
          debugPrint('QuranPagesPro: Quran init failed: ${snapshot.error}');
        }
        return QuranLibraryScreen(
          parentContext: context,
        );
      },
    );
  }
}
