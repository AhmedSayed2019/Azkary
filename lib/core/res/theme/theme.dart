
import 'package:azkark/core/res/color.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/res/theme/button.dart';
import 'package:azkark/core/res/theme/color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import 'text.dart';

ThemeData lightTheme =_buildTheme(false);
ThemeData darkTheme =_buildTheme(true);

_buildTheme(bool isDarkMode ){
  ColorScheme schemeTheme =  buildSchemeTheme(isDarkMode);
  return ThemeData(
    useMaterial3: false,
    fontFamily: FontConstants.fontFamily,

    scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor.getColor(isDarkMode),
    // textTheme: buildTextTheme(schemeTheme),
    cardColor: AppColor.cardColor.getColor(isDarkMode),
    brightness: isDarkMode?Brightness.dark:Brightness.light,
    splashColor: AppColor.primaryColor.getColor(isDarkMode),
    highlightColor: AppColor.highlightColor.getColor(isDarkMode),


    visualDensity: VisualDensity.adaptivePlatformDensity,
    hoverColor: AppColor.hoverColor.getColor(isDarkMode),


    floatingActionButtonTheme: floatingActionButtonTheme,
    dividerColor: AppColor.dividerColor.getColor(isDarkMode),
    hintColor: AppColor.hintColor.getColor(isDarkMode),
    primaryColor: AppColor.primaryColor.getColor(isDarkMode),
    primaryColorDark: AppColor.primaryColorDark.getColor(isDarkMode),

    // buttonTheme: buttonTheme,
    unselectedWidgetColor: AppColor.unselectedWidgetColor.getColor(isDarkMode),


    primaryColorLight: AppColor.primaryColorLight.getColor(isDarkMode),
    disabledColor: AppColor.disabledColor.getColor(isDarkMode),
    // toggleableActiveColor: AppColor.primaryColor.getColor(isDarkMode),

    /// Text fields
    inputDecorationTheme:isDarkMode?kInputDecorationThemeDark: kInputDecorationTheme,

    appBarTheme: AppBarTheme(
      color:AppColor.primaryColor.getColor(isDarkMode) ,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: AppColor.appBarIconsColor.getColor(isDarkMode), statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark),
      toolbarTextStyle: TextStyle(color:AppColor.appBarIconsColor.getColor(isDarkMode) ),
      iconTheme: IconThemeData(color:AppColor.appBarIconsColor.getColor(isDarkMode)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColor.primaryColor.getColor(isDarkMode),
      elevation: 0,
      selectedItemColor: AppColor.primaryColor.getColor(isDarkMode),
      unselectedItemColor: AppColor.hintColor.getColor(isDarkMode),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
    }),
    dialogTheme: DialogThemeData(backgroundColor: AppColor.dialogColor.getColor(isDarkMode), surfaceTintColor: AppColor.dialogColor.getColor(isDarkMode)),
    datePickerTheme: DatePickerThemeData(backgroundColor: AppColor.dialogColor.getColor(isDarkMode), surfaceTintColor: AppColor.dialogColor.getColor(isDarkMode)),

    cardTheme: CardThemeData(
      color: AppColor.cardColor.getColor(isDarkMode),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(kFormRadiusSmall))),
      shadowColor: AppColor.shadowColor.getColor(isDarkMode),
      surfaceTintColor: AppColor.cardColor.getColor(isDarkMode),
      elevation: 4,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      side: BorderSide(color: AppColor.primaryColor.getColor(isDarkMode), width: 2),
      checkColor: WidgetStateProperty.all<Color>(AppColor.cardColor.getColor(isDarkMode)),

      fillColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.cardColor.getColor(isDarkMode):null),
      // overlayColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColorDark.getColor(isDarkMode):null),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) return AppColor.primaryColor.getColor(isDarkMode).withOpacity(0.12);
        if (states.contains(WidgetState.hovered)) return AppColor.primaryColor.getColor(isDarkMode).withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return AppColor.primaryColor.getColor(isDarkMode).withOpacity(0.10);
        return null;
      }),
      // fillColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.cardColor.getColor(isDarkMode):AppColor.cardColor.getColor(isDarkMode)),
      // overlayColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColorDark.getColor(isDarkMode):AppColor.primaryColorDark.getColor(isDarkMode)),
    ),
    radioTheme:RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColor.getColor(isDarkMode):null),

      // overlayColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColorDark.getColor(isDarkMode):null),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) return AppColor.primaryColor.getColor(isDarkMode).withOpacity(0.12);
        if (states.contains(WidgetState.hovered)) return AppColor.primaryColor.getColor(isDarkMode).withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return AppColor.primaryColor.getColor(isDarkMode).withOpacity(0.10);
        return null;
      }),
    ),
    colorScheme: schemeTheme,
  );
}

