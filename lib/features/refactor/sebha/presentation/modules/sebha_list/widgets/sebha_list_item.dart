import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/models/sebha_model.dart' as legacy;
import 'package:azkark/pages/sebha/tasbih_page.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/util/helpers.dart';
import 'package:azkark/util/navigate_between_pages/size_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A single row in the refactored sebha list — the equivalent of the legacy
/// `Tasbih` widget, but driven purely by [SebhaEntity] + callbacks instead
/// of reading a global [SebhaProvider]/[FavoritesProvider].
class SebhaListItem extends StatelessWidget {
  const SebhaListItem({
    super.key,
    required this.sebha,
    required this.number,
    required this.onToggleFavorite,
    required this.onOpenMenu,
  });

  final SebhaEntity sebha;
  final int number;
  final ValueChanged<SebhaEntity> onToggleFavorite;
  final ValueChanged<SebhaEntity> onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        highlightColor: teal[100],
        splashColor: teal[100],
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          SizeRoute(page: SebhaPage(_toLegacyModel())),
        ),
        onLongPress: () => onOpenMenu(sebha),
        onDoubleTap: () => copyText(context, sebha.name),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildNumberField(),
                Row(
                  children: <Widget>[
                    _buildFavoriteButton(),
                    _buildMenuButton(),
                  ],
                ),
              ],
            ),
            _buildNameField(context),
            _buildBottomWidget(context, size),
          ],
        ),
      ),
    );
  }

  /// Bridge to the still-legacy counting screen ([SebhaPage]), which is out
  /// of scope for this migration and still expects the old model type.
  legacy.SebhaModel _toLegacyModel() => legacy.SebhaModel(
        id: sebha.id,
        name: sebha.name,
        counter: sebha.counter,
        favorite: sebha.favorite ? 1 : 0,
      );

  Widget _buildMenuButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: teal[400]!.withAlpha(100),
        splashColor: teal[400],
        borderRadius: BorderRadius.circular(10),
        onTap: () => onOpenMenu(sebha),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.more_vert,
            size: 22,
            color: teal,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: teal[200],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Text(
        '$number',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: teal[700],
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        sebha.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: teal,
          fontFamily:
              settingsProvider.getsettingField('font_family').toString(),
          fontSize: settingsProvider.getsettingField('font_size'),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: teal[400]!.withAlpha(100),
        splashColor: teal[400],
        borderRadius: BorderRadius.circular(10),
        onTap: () => onToggleFavorite(sebha),
        child: Container(
          height: 35,
          width: 35,
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            sebha.favorite
                ? 'assets/images/icons/favorites/favorite_128px.png'
                : 'assets/images/icons/favorites/nonfavorite_128px.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget(BuildContext context, Size size) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: teal[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Text(
        sebha.counter == 0
            ? 'عدد الحبات : بدون'
            : 'عدد الحبات : ${sebha.counter}',
        style: TextStyle(
          color: teal[700],
          fontWeight: sebha.counter == 0 ? FontWeight.w500 : null,
          fontFamily:
              settingsProvider.getsettingField('font_family').toString(),
          fontSize: settingsProvider.getsettingField('font_size'),
        ),
      ),
    );
  }
}
