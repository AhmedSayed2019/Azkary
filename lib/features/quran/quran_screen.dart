import 'package:flutter/material.dart';
import 'package:quran_library/quran.dart';

class QuranPagesPro extends StatefulWidget {
  const QuranPagesPro({Key? key}) : super(key: key);

  @override
  State<QuranPagesPro> createState() => _QuranPagesProState();
}

class _QuranPagesProState extends State<QuranPagesPro> {
  @override
  void initState() {
    super.initState();
    final ctrl = QuranCtrl.instance;
    // hafsMushafTajweed (index 0) is the only recitation this version ships;
    // any other value disables the QPC V4 page layout entirely and renders
    // nothing, so force it back regardless of persisted/stray state.
    ctrl.state.fontsSelected.value = 0;
    // The bundled tajweed fonts are loaded lazily and only start loading once
    // selectRecitation() is called; a fresh install never calls it on its own,
    // so kick off loading here instead of leaving the page blank.
    if (!QuranFontsService.allLoaded) {
      final currentPage = ctrl.state.currentPageNumber.value;
      QuranFontsService.ensurePagesLoaded(currentPage, radius: 10).then((_) {
        if (!mounted) return;
        setState(() {});
        QuranFontsService.loadRemainingInBackground(
          startNearPage: currentPage,
          progress: ctrl.state.fontsLoadProgress,
          ready: ctrl.state.fontsReady,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuranLibraryScreen(
      parentContext: context,
    );
  }
}
