
import 'package:azkark/data/models/surah_model.dart';
import 'package:azkark/pages/quran/surah/widgets/surah_text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/constant.dart';
import '../../../providers/settings_provider.dart';
import '../../../util/background.dart';
import '../../../util/colors.dart';
import 'widgets/surah_with_list_widget.dart';

final ItemScrollController itemScrollController = ItemScrollController();
final ItemPositionsListener itemPositionsListener =
    ItemPositionsListener.create();

class SurahBuilder extends StatefulWidget {
  final int _suraIndex;
  final List<SurahModel> _ayatElQuran;
  final String _suraName;
  final int _ayah;
  const SurahBuilder({
    required int suraIndex,
    required List<SurahModel> ayatElQuran,
    required String suraName,
    required int ayah,
  })  : _suraIndex = suraIndex,
        _ayatElQuran = ayatElQuran,
        _suraName = suraName,
        _ayah = ayah;
  @override
  State<SurahBuilder> createState() => _SurahBuilderState();


}

class _SurahBuilderState extends State<SurahBuilder> {
  bool _isView = false;
  late double _fontSize;
  late int _fontType;
  @override
  void initState() {
    _fontSize = Provider.of<SettingsProvider>(context, listen: false).getsettingField('font_size');
    _fontType = Provider.of<SettingsProvider>(context, listen: false).getsettingField('font_family');

    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToAyah());
    super.initState();
  }

  _jumpToAyah() {
    if (fabIsClicked) {
      itemScrollController.scrollTo(
          index: widget._ayah,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOutCubic);
    }
    fabIsClicked = false;
  }


  SafeArea _singleSuraBuilder(lengthOfSura) {
    String fullSura = '';
    int previousVerses = 0;
    if (widget._suraIndex + 1 != 1) {
      for (int i = widget._suraIndex - 1; i >= 0; i--) {
        previousVerses = previousVerses + noOfVerses[i];
      }
    }

    // if (!_isView)
      for (int i = 0; i < lengthOfSura; i++) {
        fullSura += (widget._ayatElQuran[i + previousVerses].ayaText);
      }



    return SafeArea(
      child: Container(
        // margin: EdgeInsets.all(16),
        color:  teal[50],
        // color: const Color.fromARGB(255, 253, 251, 240),
        child: _isView
            ? SurahWithListWidget(suraIndex:  widget._suraIndex , ayatElQuran: ayatElQuran,   previousVerses: previousVerses)
            : fullSura.isEmpty
            ? CupertinoActivityIndicator()
            :SurahTextWidget(suraIndex:  widget._suraIndex , fullSura: fullSura, fontSize: _fontSize),

      ),
    );

  }





  @override
  Widget build(BuildContext context) {
    int lengthOfSura = noOfVerses[widget._suraIndex];

      return Stack(
        children: [
          Background(),

          Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(
                widget._suraName,
                style:  TextStyle(
                  color: teal[50],
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              actions: [
                Tooltip(
                  message: _isView?'عرض بطريقة النص':'عرض بطريقة التتابع',
                  child: TextButton(
                    child: const Icon(
                      Icons.chrome_reader_mode,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isView = !_isView;
                      });
                    },
                  ),
                ),
              ]
            ),
            body: _singleSuraBuilder(lengthOfSura),
          ),
        ],
      );
  }
}
