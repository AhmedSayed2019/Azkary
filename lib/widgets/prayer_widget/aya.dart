import 'package:azkark/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prayer_model.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../util/colors.dart';

class Aya extends StatefulWidget {
  final PrayerModel _prayer;
  final double _fontSize;

  @override
  _AyaState createState() => _AyaState();

  const Aya({
    required PrayerModel prayer,
    required double fontSize,
  })  : _prayer = prayer,
        _fontSize = fontSize;
}

class _AyaState extends State<Aya> {
  String get text =>
      'بسم الله الرحمن الرحيم \n ﴿ ${widget._prayer.aya} ﴾ \n***********\nسورة : ${widget._prayer.surah}\n***********\nالأية : ${widget._prayer.ayaNumber}';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(
      color: teal[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: size.width,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: teal[100],
          borderRadius: BorderRadius.circular(10),
          onLongPress: () => copyText(context, text),
          child: Column(
            children: <Widget>[
              Align(
                  alignment: Alignment.centerLeft,
                  child: _buildFavoriteButton()),
              Align(
                  alignment: Alignment.center,
                  child: _buildBesmellahField(size)),
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
        '﴿ ${widget._prayer.aya} ﴾',
        style: TextStyle(
          color: teal,
          fontFamily: '3',
          // fontWeight: FontWeight.w700,
          fontSize: widget._fontSize + 2,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    final parayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: teal[400],
        splashColor: teal[400],
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          print('You clicked on Favorite');
          setState(() {
            widget._prayer.favorite == 1
                ? widget._prayer.setFavorite(0)
                : widget._prayer.setFavorite(1);
          });
          await parayerProvider.updateFavorite(
              widget._prayer.favorite, widget._prayer.id);
          if (widget._prayer.favorite == 1)
            await Provider.of<FavoritesProvider>(context, listen: false)
                .addFavorite(1, widget._prayer.id);
          else if (widget._prayer.favorite == 0)
            await Provider.of<FavoritesProvider>(context, listen: false)
                .deleteFavorite(1, widget._prayer.id);
        },
        child: Container(
          height: 35,
          width: 35,
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            widget._prayer.favorite == 1
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
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildNameSurahField(),
          _buildAyaNumberField(),
        ],
      ),
    );
  }

  Widget _buildNameSurahField() {
    return Text(
      'سورة ${widget._prayer.surah}',
      style: TextStyle(
        color: teal[50],
        fontSize: 13,
      ),
    );
  }

  Widget _buildAyaNumberField() {
    return Text(
      'الآية ${widget._prayer.ayaNumber}',
      style: TextStyle(
        color: teal[50],
        fontSize: 13,
      ),
    );
  }
}
