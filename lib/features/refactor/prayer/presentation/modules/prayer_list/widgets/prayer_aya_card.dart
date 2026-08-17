import 'package:azkark/features/refactor/prayer/domain/entity/prayer_entity.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/util/helpers.dart';
import 'package:flutter/material.dart';

/// A single verse (aya) card — the refactored equivalent of the legacy
/// `Aya` widget, driven purely by [PrayerEntity] + a callback instead of
/// reading `PrayerProvider`/`FavoritesProvider` directly.
class PrayerAyaCard extends StatelessWidget {
  const PrayerAyaCard({
    super.key,
    required this.prayer,
    required this.fontSize,
    required this.onToggleFavorite,
  });

  final PrayerEntity prayer;
  final double fontSize;
  final ValueChanged<PrayerEntity> onToggleFavorite;

  String get _copyText =>
      'بسم الله الرحمن الرحيم \n ﴿ ${prayer.aya} ﴾ \n***********\nسورة : ${prayer.surah}\n***********\nالأية : ${prayer.ayaNumber}';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(
      color: teal[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: size.width,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: teal[100],
          borderRadius: BorderRadius.circular(10),
          onLongPress: () => copyText(context, _copyText),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: _buildFavoriteButton(),
              ),
              Align(
                alignment: Alignment.center,
                child: _buildBesmellahField(size),
              ),
              _buildAyaField(),
              _buildBottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBesmellahField(Size size) {
    return Image.asset(
      'assets/images/icons/prayer/al_basmalla.png',
      fit: BoxFit.contain,
      height: size.width * 0.065,
    );
  }

  Widget _buildAyaField() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 10.0, bottom: 15.0, right: 10.0, left: 10.0),
      child: Text(
        '﴿ ${prayer.aya} ﴾',
        style: TextStyle(
          color: teal,
          fontFamily: '3',
          fontSize: fontSize + 2,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: teal[400],
        splashColor: teal[400],
        borderRadius: BorderRadius.circular(10),
        onTap: () => onToggleFavorite(prayer),
        child: Container(
          height: 35,
          width: 35,
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            prayer.favorite
                ? 'assets/images/icons/favorites/favorite_128px.png'
                : 'assets/images/icons/favorites/nonfavorite_128px.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: teal[600],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'سورة ${prayer.surah}',
            style: TextStyle(color: teal[50], fontSize: 13),
          ),
          Text(
            'الآية ${prayer.ayaNumber}',
            style: TextStyle(color: teal[50], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
