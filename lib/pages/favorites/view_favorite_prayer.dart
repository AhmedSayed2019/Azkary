import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../util/background.dart';
import '../../util/colors.dart';
import '../../widgets/prayer_widget/aya.dart';
import 'components/empty_favorite.dart';

class ViewFavoritePrayer extends StatefulWidget {
  @override
  _ViewFavoritePrayerState createState() => _ViewFavoritePrayerState();
}

class _ViewFavoritePrayerState extends State<ViewFavoritePrayer> {
  @override
  Widget build(BuildContext context) {
    final parayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);

    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            tr( 'favorite_bar'),
            style: new TextStyle(
              color: teal[50],
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: favoritesProvider.isEmpty(1)
            ? EmptyFavorite()
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: favoritesProvider.length(1),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: index == 0
                        ? const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0)
                        : index == favoritesProvider.length(1) - 1
                            ? const EdgeInsets.only(
                                bottom: 5.0, left: 5.0, right: 5.0)
                            : const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Aya(
                      prayer: parayerProvider
                          .getPrayer(favoritesProvider.getItemId(1, index)),
                      fontSize:
                          Provider.of<SettingsProvider>(context, listen: false)
                              .getsettingField('font_size'),
                    ),
                  );
                }),
      ),
    ]);
  }
}
