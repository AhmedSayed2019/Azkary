import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/res/theme_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/background.dart';
import '../../util/colors.dart';
import '../../widgets/settings_widget/setting_font_size.dart';
import '../../widgets/settings_widget/setting_font_type.dart';
import '../../widgets/settings_widget/settings_item.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            'الضبط',
            style: new TextStyle(
              color: teal[50],
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              _buildPublicSettings(context),
              _buildAzkarSettingsCard(context),
              // _buildThemeCart(context),
              // _buildCommunicate(size)
            ],
          ),
        ),
      ),
    ]);
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          topLeft: Radius.circular(20)),
      border: Border.all(color: teal[600]!),
    );
  }

  Widget _buildAzkarSettingsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: _buildTitle(context,'إعدادات الأذكار'),
          ),
          Container(
            decoration: _decoration(context),
            child: Column(
              children: <Widget>[
                SettingsItem(
                  activeTitle: tr( 'popup_menu_counter_true'),
                  inactiveTitle: tr( 'popup_menu_counter_false'),
                  nameField: 'counter',
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
                ),
                SettingsItem(
                  activeTitle: tr( 'popup_menu_diacritics_true'),
                  inactiveTitle:
                      tr( 'popup_menu_diacritics_false'),
                  nameField: 'diacritics',
                ),
                SettingsItem(
                  activeTitle: tr( 'popup_menu_sanad_true'),
                  inactiveTitle: tr( 'popup_menu_sanad_false'),
                  nameField: 'sanad',
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCart(BuildContext context) {
    bool isDarkMode = context.watch<ThemeHelper>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: _buildTitle(context,'اللوان'),
          ),
          Container(
            decoration: _decoration(context),
            child: Column(
              children: <Widget>[

                SettingsItem(
                  activeTitle: tr( 'popup_menu_sanad_true'),
                  inactiveTitle: tr( 'popup_menu_sanad_false'),
                  nameField: 'theme',
                   switchValue: isDarkMode,
                   onChanged: (isDarkMode)=>Provider.of<ThemeHelper>(context,listen: false).changeTheme(isDarkMode,reload: true),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicSettings(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Align(alignment: Alignment.topRight, child: _buildTitle(context,'الإعدادات العامة')),
          Container(
            decoration: _decoration(context),
            child:  Column(
              children: <Widget>[
                SettingFontType(borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
                SettingFontSize(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context,String text) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: Text(
          text,
          style:  const TextStyle().semiBoldStyle(fontSize: 16).primaryTextColor(),
          // style:  TextStyle(color: teal[50], fontSize: 14),
        ),
      ),
    );
  }
}
