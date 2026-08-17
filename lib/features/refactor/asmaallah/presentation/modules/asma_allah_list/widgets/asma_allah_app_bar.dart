import 'package:azkark/util/colors.dart';
import 'package:azkark/widgets/slider_font_size/button_font_size.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _AsmaAllahAppBarMenu { showAllDescription, about }

/// Equivalent of the legacy `CustomAppBar` from `pages/asmaallah`. The
/// "about" menu item is inert (the legacy handler had an empty case too);
/// only the description toggle and font-size slider button do anything.
class AsmaAllahAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AsmaAllahAppBar({
    super.key,
    required this.description,
    required this.sliderFont,
    required this.onTapDescription,
    required this.onTapFontButton,
  });

  final bool description;
  final bool sliderFont;
  final VoidCallback onTapDescription;
  final VoidCallback onTapFontButton;

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: Text(
        tr('asmaallah_bar'),
        style: TextStyle(
          color: teal[50],
          fontWeight: FontWeight.w700,
          fontSize: 18,
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
      child: PopupMenuButton<_AsmaAllahAppBarMenu>(
        offset: const Offset(0, 50),
        onSelected: (_AsmaAllahAppBarMenu result) {
          if (result == _AsmaAllahAppBarMenu.showAllDescription) {
            onTapDescription();
          }
        },
        itemBuilder: (context) => [
          _buildMenuItem(
            value: _AsmaAllahAppBarMenu.showAllDescription,
            text: description
                ? tr('popup_menu_asmaallah_true')
                : tr('popup_menu_asmaallah_false'),
            icon: FaIcon(
              description
                  ? FontAwesomeIcons.toggleOn
                  : FontAwesomeIcons.toggleOff,
              color: description ? teal[500] : teal,
              size: 20,
            ),
          ),
          _buildMenuItem(
            value: _AsmaAllahAppBarMenu.about,
            enable: false,
            text: tr('about'),
            icon: const Icon(
              Icons.help_outline,
              color: teal,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_AsmaAllahAppBarMenu> _buildMenuItem({
    required _AsmaAllahAppBarMenu value,
    bool enable = true,
    required Widget icon,
    required String text,
  }) {
    return PopupMenuItem<_AsmaAllahAppBarMenu>(
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
              style: TextStyle(
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
