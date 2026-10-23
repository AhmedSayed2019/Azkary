import 'dart:ui' as ui;

import 'package:azkark/core/res/resources.dart';
import 'package:azkark/widgets/islamic_header_background.dart';
import 'package:azkark/widgets/slider_font_size/button_font_size.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _AzkarMenu { favorite, counter, diacritics, sanad, refresh, about }

/// Replaces the legacy `CustomAppBar` of `features/azkar`: a collapsing
/// header that shows the category title large over the star pattern and
/// shrinks to a plain bar as the list scrolls.
class AzkarAppBar extends StatelessWidget {
  const AzkarAppBar({
    super.key,
    required this.title,
    required this.favorite,
    required this.counter,
    required this.diacritics,
    required this.sanad,
    required this.sliderFont,
    required this.onTapFavorite,
    required this.onTapCounter,
    required this.onTapDiacritics,
    required this.onTapSanad,
    required this.onTapRefresh,
    required this.onTapFontButton,
  });

  final String title;
  final bool favorite;
  final bool counter;
  final bool diacritics;
  final bool sanad;
  final bool sliderFont;
  final VoidCallback onTapFavorite;
  final VoidCallback onTapCounter;
  final VoidCallback onTapDiacritics;
  final VoidCallback onTapSanad;
  final VoidCallback onTapRefresh;
  final VoidCallback onTapFontButton;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0.0,
      expandedHeight: 140,
      backgroundColor: AppColor.primaryColor.themeColor,
      // النسيج خارج FlexibleSpaceBar حتى يبقى ظاهرًا حتى بعد الانكماش
      // (خلفية FlexibleSpaceBar تتلاشى عند التمرير، عكس شريط الرئيسية)
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const IslamicHeaderBackground(child: SizedBox.expand()),
          FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            // start: 56 لا 16 — عند انكماش الشريط ينتقل العنوان إلى صف
            // الأدوات حيث يجلس زر الرجوع على الحافة البادئة، فكان النص
            // يرتكب فوقه. القيمة تساوي عرض زر الرجوع القياسي وتصلح في
            // الاتجاهين لأن EdgeInsetsDirectional.start يتبع لغة الواجهة.
            titlePadding: const EdgeInsetsDirectional.only(
              start: 56,
              bottom: kFormPaddingAllLarge,
              end: 96,
            ),
            title: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle()
                  .semiBoldStyle(fontSize: 16)
                  .customColor(AppColor.appBarTextColor.themeColor),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ButtonFontSize(showSider: sliderFont, onTap: onTapFontButton),
        _AzkarPopUpMenu(
          favorite: favorite,
          counter: counter,
          diacritics: diacritics,
          sanad: sanad,
          onTapFavorite: onTapFavorite,
          onTapCounter: onTapCounter,
          onTapDiacritics: onTapDiacritics,
          onTapSanad: onTapSanad,
          onTapRefresh: onTapRefresh,
        ),
      ],
    );
  }
}

class _AzkarPopUpMenu extends StatelessWidget {
  const _AzkarPopUpMenu({
    required this.favorite,
    required this.counter,
    required this.diacritics,
    required this.sanad,
    required this.onTapFavorite,
    required this.onTapCounter,
    required this.onTapDiacritics,
    required this.onTapSanad,
    required this.onTapRefresh,
  });

  final bool favorite;
  final bool counter;
  final bool diacritics;
  final bool sanad;
  final VoidCallback onTapFavorite;
  final VoidCallback onTapCounter;
  final VoidCallback onTapDiacritics;
  final VoidCallback onTapSanad;
  final VoidCallback onTapRefresh;

  void _onSelected(_AzkarMenu result) {
    switch (result) {
      case _AzkarMenu.favorite:
        onTapFavorite();
      case _AzkarMenu.counter:
        onTapCounter();
      case _AzkarMenu.diacritics:
        onTapDiacritics();
      case _AzkarMenu.sanad:
        onTapSanad();
      case _AzkarMenu.refresh:
        onTapRefresh();
      case _AzkarMenu.about:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor.themeColor;

    return Padding(
      padding: const EdgeInsets.only(left: kFormPaddingAllSmall),
      child: PopupMenuButton<_AzkarMenu>(
        offset: const Offset(0, 50),
        onSelected: _onSelected,
        itemBuilder: (context) => [
          _menuItem(
            value: _AzkarMenu.favorite,
            text: favorite
                ? tr('popup_menu_favorite_true')
                : tr('popup_menu_favorite_false'),
            icon: Container(
              height: 25,
              width: 25,
              decoration: const BoxDecoration()
                  .customColor(AppColor.primaryColorLight.themeColor)
                  .circle(),
              padding: const EdgeInsets.all(3.0),
              child: Image.asset(
                favorite
                    ? 'assets/images/icons/favorites/favorite_128px.png'
                    : 'assets/images/icons/favorites/nonfavorite_128px.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          _menuItem(
            value: _AzkarMenu.counter,
            text: counter
                ? tr('popup_menu_counter_true')
                : tr('popup_menu_counter_false'),
            icon: FaIcon(
              counter ? FontAwesomeIcons.toggleOn : FontAwesomeIcons.toggleOff,
              color: primary,
              size: 20,
            ),
          ),
          _menuItem(
            value: _AzkarMenu.diacritics,
            text: diacritics
                ? tr('popup_menu_diacritics_true')
                : tr('popup_menu_diacritics_false'),
            icon: FaIcon(
              diacritics
                  ? FontAwesomeIcons.toggleOn
                  : FontAwesomeIcons.toggleOff,
              color: primary,
              size: 20,
            ),
          ),
          _menuItem(
            value: _AzkarMenu.sanad,
            text: sanad
                ? tr('popup_menu_sanad_true')
                : tr('popup_menu_sanad_false'),
            icon: FaIcon(
              sanad ? FontAwesomeIcons.toggleOn : FontAwesomeIcons.toggleOff,
              color: primary,
              size: 20,
            ),
          ),
          _menuItem(
            value: _AzkarMenu.refresh,
            text: tr('popup_menu_refresh'),
            // تصفير العدّاد بلا عدّاد لا معنى له
            enable: counter,
            icon: Icon(
              Icons.refresh,
              textDirection: ui.TextDirection.rtl,
              color: primary,
              size: 25,
            ),
          ),
          _menuItem(
            value: _AzkarMenu.about,
            text: tr('about'),
            // كما في النسخة القديمة: العنصر معروض بلا سلوك بعد
            enable: false,
            icon: Icon(Icons.help_outline, color: primary, size: 25),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_AzkarMenu> _menuItem({
    required _AzkarMenu value,
    required Widget icon,
    required String text,
    bool enable = true,
  }) {
    final textColor = AppColor.textColor.themeColor;

    return PopupMenuItem<_AzkarMenu>(
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
              style: const TextStyle()
                  .regularStyle(fontSize: 14, fontWeight: FontWeight.w300)
                  .customColor(
                    enable ? textColor : textColor.withValues(alpha: 0.5),
                  ),
            ),
          ),
          icon,
        ],
      ),
    );
  }
}
