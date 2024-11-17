import 'package:azkark/util/helpers.dart';
import 'package:azkark/widgets/slider_font_size/button_font_size.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../util/colors.dart';
import 'package:flutter/material.dart';

enum PopUpMenu {
  Favorite,
  TurnOnCounter,
  TurnOnDiacritics,
  TurnOnSanad,
  RefreshAll,
  About
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool favorite, counter, diacritics, sanad, sliderFont;
  final VoidCallback onTapFontButton,
      onTapFavorite,
      onTapCounter,
      onTapDiacritics,
      onTapSanad,
      onTapRefresh;

  CustomAppBar({
   required this.title,
   required this.favorite,
   required this.counter,
   required this.diacritics,
   required this.sanad,
   required this.sliderFont,
   required this.onTapFavorite,
   required this.onTapCounter,
   required this.onTapDiacritics,
   required this.onTapRefresh,
   required this.onTapSanad,
   required this.onTapFontButton,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: new TextStyle(
          color: teal[50],
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      actions: <Widget>[
        ButtonFontSize(
          showSider: sliderFont,
          onTap: onTapFontButton,
        ),
        _buildPopUpMenu(context),
      ],
    );
  }

  Widget _buildPopUpMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: PopupMenuButton<PopUpMenu>(
        offset: Offset(0, 50),
        onSelected: (PopUpMenu result) async {
          switch (result) {
            case PopUpMenu.Favorite:
              onTapFavorite();
              break;

            case PopUpMenu.TurnOnCounter:
              onTapCounter();
              break;

            case PopUpMenu.TurnOnDiacritics:
              onTapDiacritics();
              break;

            case PopUpMenu.RefreshAll:
              onTapRefresh();
              break;

            case PopUpMenu.TurnOnSanad:
              onTapSanad();
              break;

            case PopUpMenu.About:
              break;
          }
        },
        itemBuilder: (context) => [
          _buildMenuItem(
            value: PopUpMenu.Favorite,
            text: favorite
                ? translate(context, 'popup_menu_favorite_true')
                : translate(context, 'popup_menu_favorite_false'),
            icon: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                color: teal[100],
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(3.0),
              child: Image.asset(
                favorite
                    ? 'assets/images/icons/favorites/favorite_128px.png'
                    : 'assets/images/icons/favorites/nonfavorite_128px.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          _buildMenuItem(
            value: PopUpMenu.TurnOnCounter,
            text: counter
                ? translate(context, 'popup_menu_counter_true')
                : translate(context, 'popup_menu_counter_false'),
            icon: FaIcon(
              counter ? FontAwesomeIcons.toggleOn : FontAwesomeIcons.toggleOff,
              color: counter ? teal[500] : teal,
              size: 20,
            ),
          ),
          _buildMenuItem(
            value: PopUpMenu.TurnOnDiacritics,
            text: diacritics
                ? translate(context, 'popup_menu_diacritics_true')
                : translate(context, 'popup_menu_diacritics_false'),
            icon: FaIcon(
              diacritics
                  ? FontAwesomeIcons.toggleOn
                  : FontAwesomeIcons.toggleOff,
              color: diacritics ? teal[500] : teal,
              size: 20,
            ),
          ),
          _buildMenuItem(
            value: PopUpMenu.TurnOnSanad,
            text: sanad
                ? translate(context, 'popup_menu_sanad_true')
                : translate(context, 'popup_menu_sanad_false'),
            icon: FaIcon(
              sanad ? FontAwesomeIcons.toggleOn : FontAwesomeIcons.toggleOff,
              color: sanad ? teal[500] : teal,
              size: 20,
            ),
          ),
          _buildMenuItem(
            value: PopUpMenu.RefreshAll,
            text: translate(context, 'popup_menu_refresh'),
            enable: counter,
            icon: Icon(
              Icons.refresh,
              textDirection: TextDirection.rtl,
              color: teal,
              size: 25,
            ),
          ),
          _buildMenuItem(
            value: PopUpMenu.About,
            text: translate(context, 'about'),
            icon: Icon(
              Icons.help_outline,
              color: teal,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<PopUpMenu> _buildMenuItem(
      {required PopUpMenu value, bool enable = true,required Widget icon,required String text}) {
    return PopupMenuItem<PopUpMenu>(
      value: value,
      enabled: enable,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 150,
            alignment: Alignment.centerRight,
            child: Text(
              text,
              style: new TextStyle(
                color: enable ? teal[900] : teal[900]!.withAlpha(125),
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
          ),
          icon,
        ],
      ),
    );
  }
}
