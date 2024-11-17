import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'aya.dart';
import '../../providers/prayer_provider.dart';

class AlAyat extends StatelessWidget {
  final String _surah;
  final double _fontSize;

  const AlAyat({
    required String surah,
    required double fontSize,
  })  : _surah = surah,
        _fontSize = fontSize;

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: prayerProvider.getAyatSurah(_surah).length,
      itemBuilder: (context, index) {
        return Aya(
          prayer: prayerProvider
              .getPrayer(prayerProvider.getAyaOfSurah(_surah, index)),
          fontSize: _fontSize,
        );
      },
    );
  }


}
