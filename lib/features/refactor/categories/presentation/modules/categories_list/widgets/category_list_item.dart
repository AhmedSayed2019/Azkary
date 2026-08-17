import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:azkark/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A single row in the refactored categories list — the equivalent of the
/// legacy `Category` widget, but driven purely by [CategoryEntity] +
/// callbacks instead of reading a global `CategoriesProvider`.
class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final CategoryEntity category;
  final VoidCallback onTap;
  final ValueChanged<CategoryEntity> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diacritics = Provider.of<SettingsProvider>(context, listen: false)
        .getsettingField('diacritics');
    final fontSize =
        Provider.of<SettingsProvider>(context, listen: false)
                .getsettingField('font_size') -
            2;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: size.width,
        child: InkWell(
          highlightColor: teal[100],
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    diacritics
                        ? category.nameWithDiacritics
                        : category.nameWithoutDiacritics,
                    style: TextStyle(
                      color: teal,
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                _buildFavoriteButton(),
              ],
            ),
          ),
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
        onTap: () => onToggleFavorite(category),
        child: Container(
          height: 45,
          width: 45,
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            category.favorite
                ? 'assets/images/icons/favorites/favorite_128px.png'
                : 'assets/images/icons/favorites/nonfavorite_128px.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
