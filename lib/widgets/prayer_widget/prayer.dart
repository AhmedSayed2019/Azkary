import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prayer_provider.dart';
import 'surah.dart';
import 'alayat.dart';

class Prayer extends StatelessWidget {
  final double _fontSize;
  final bool _showAlAyat;
  final int _surahNumber;
  final  GestureTapCallback? _onTap;

  const Prayer({
    required double fontSize,
    required bool showAlAyat,
    required int surahNumber,
    required  GestureTapCallback? onTap,
  })  : _fontSize = fontSize,
        _showAlAyat = showAlAyat,
        _surahNumber = surahNumber,
        _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);

    return Container(
      width: size.width,
      child: Column(
        children: <Widget>[
          Surah(
            fontSize: _fontSize,
            number: _surahNumber + 1,
            surah: prayerProvider.allSurah[_surahNumber],
            onTap: _onTap,
            showAlAyat: _showAlAyat,
          ),
          if (_showAlAyat)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: AlAyat(
                fontSize: _fontSize,
                surah: prayerProvider.allSurah[_surahNumber],
              ),
            ),
        ],
      ),
    );
  }

}
