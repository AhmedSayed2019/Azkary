

import 'package:azkark/data/models/surah_model.dart';
import 'package:azkark/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constant.dart';
import '../../../../providers/settings_provider.dart';
import '../../widget/basmala_widget.dart';

class SurahWithListWidget extends StatefulWidget {
  final int _suraIndex;
  final List<SurahModel> _ayatElQuran;
  final int _previousVerses;

  const SurahWithListWidget({
    required int suraIndex,
    required List<SurahModel> ayatElQuran,
    required int previousVerses,
  })  : _suraIndex = suraIndex,
        _ayatElQuran = ayatElQuran,
        _previousVerses = previousVerses;

  @override
  State<SurahWithListWidget> createState() => _SurahWithListWidgetState();
}

class _SurahWithListWidgetState extends State<SurahWithListWidget> {

  late double _fontSize;
  @override
  void initState() {
    _fontSize = Provider.of<SettingsProvider>(context, listen: false).getsettingField('font_size');

    super.initState();
  }



  Row _verseBuilder({required int index , required int previousIndex}){

    return Row(
      children: [
        Expanded(
          child: Text(widget._ayatElQuran[index+previousIndex].ayaText,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              // fontSize: arabicFontSize,
                fontFamily: arabicFont,
                // fontFamily: _fontType.toString(),
                fontSize: _fontSize,
                color: const Color.fromARGB(196, 0, 0, 0)
            ),
          ),
        ),
      ],
    );

  }

  _saveBookMark({required int surah,required int aya})async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('surah', surah);
    await prefs.setInt('ayah', surah);
  }

  @override
  Widget build(BuildContext context) {
    int lengthOfSura = noOfVerses[widget._suraIndex];

    return ScrollablePositionedList.builder(
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            if(index == 0)
              BasmalaWidget(suraIndex: widget._suraIndex),


            Container(
              color: index % 2 != 0?teal[50]:teal[100],
                  // ? const Color.fromARGB(255, 253, 251, 240)
                  // : const Color.fromARGB(255, 253, 247, 230),
              child: PopupMenuButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _verseBuilder(index: index, previousIndex:widget._previousVerses),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _saveBookMark(surah: widget._suraIndex + 1, aya: index),
                      child: Row(
                        children: const [
                          Icon(Icons.bookmark_add, color: Color.fromARGB(255, 56, 115, 59)),
                          SizedBox(width: 10),
                          Text('Bookmark'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {

                      },
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Icon(Icons.share, color: Color.fromARGB(255, 56, 115, 59)),
                          SizedBox(width: 10),
                          Text('Share'),
                        ],
                      ),
                    ),
                  ]),
            ),
          ],
        );
      },
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemCount: lengthOfSura,
    );
  }
}
