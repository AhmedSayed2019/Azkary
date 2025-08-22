import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/categories_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../util/background.dart';
import '../../util/colors.dart';
import '../../widgets/categories_widget/category.dart';
import 'components/empty_favorite.dart';

class ViewFavoriteCategories extends StatefulWidget {
  @override
  _ViewFavoriteCategoriesState createState() => _ViewFavoriteCategoriesState();
}

class _ViewFavoriteCategoriesState extends State<ViewFavoriteCategories> {
  @override
  Widget build(BuildContext context) {
    final categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
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
        body: favoritesProvider.isEmpty(0)
            ? EmptyFavorite()
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: favoritesProvider.length(0),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: index == 0
                        ? const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0)
                        : index == favoritesProvider.length(0) - 1
                            ? const EdgeInsets.only(
                                bottom: 5.0, left: 5.0, right: 5.0)
                            : const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Category(
                      categoriesProvider
                          .getCategory(favoritesProvider.getItemId(0, index)),
                    ),
                  );
                }),
      ),
    ]);
  }
}
