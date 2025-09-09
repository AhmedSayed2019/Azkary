import 'package:flutter/material.dart';

import '../../util/colors.dart';

class Surah extends StatelessWidget {
  final int _number;
  final double _fontSize;
  final String _surah;
  final bool _showAlAyat;
  final  GestureTapCallback? _onTap;

  const Surah({
    required int number,
    required double fontSize,
    required String surah,
    required bool showAlAyat,
    required  GestureTapCallback? onTap,
  })  : _number = number,
        _fontSize = fontSize,
        _surah = surah,
        _showAlAyat = showAlAyat,
        _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: teal[200],
        borderRadius: BorderRadius.circular(10),
        onTap: _onTap,
        child: Stack(
          children: <Widget>[
            Align(alignment: Alignment.topRight, child: _buildNumberField()),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 15.0, right: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildNameField(),
                  Icon(
                    _showAlAyat
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: teal[700],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
          color: teal[200],
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), bottomLeft: Radius.circular(10))),
      child: Text(
        '$_number',
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: teal[700],
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        'سورة $_surah',
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: teal,
          fontWeight: FontWeight.w700,
          fontSize: _fontSize,
        ),
      ),
    );
  }


}
