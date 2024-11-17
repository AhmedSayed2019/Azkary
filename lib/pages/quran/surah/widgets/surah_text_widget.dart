import 'package:flutter/material.dart';

import '../../../../core/constant.dart';
import '../../widget/basmala_widget.dart';

class SurahTextWidget extends StatelessWidget {
  final int _suraIndex;
  final String _fullSura;
  final double _fontSize;
  const SurahTextWidget({
    required int suraIndex,
    required String fullSura,
    required double fontSize,
  })  : _suraIndex = suraIndex,
        _fullSura = fullSura,
        _fontSize = fontSize;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BasmalaWidget(suraIndex:  _suraIndex),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _fullSura,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: arabicFont,
                        // fontFamily: _fontType.toString(),
                        fontSize: _fontSize,
                        color: const Color.fromARGB(196, 44, 44, 44),
                        // color: const Color.fromARGB(196, 44, 44, 44),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }


}

