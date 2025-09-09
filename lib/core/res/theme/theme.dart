
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/res/theme/bottom_bar.dart';
import 'package:azkark/core/res/theme/button.dart';
import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'text.dart';

ThemeData  lightTheme =ThemeData(
  scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor.lightColor,
  textTheme: textTheme,
  iconTheme: const IconThemeData(color: Colors.white),
  cardColor: AppColor.cardColor.lightColor,
  brightness: Brightness.light,
  splashColor: AppColor.hintColor.lightColor,
  highlightColor: AppColor.highlightColor.lightColor,
  splashFactory: InkSplash.splashFactory,
  appBarTheme: appBarTheme,
  fontFamily: FontConstants.fontFamily,


  visualDensity: VisualDensity.adaptivePlatformDensity,
  hoverColor: AppColor.hoverColor.lightColor,


  floatingActionButtonTheme: floatingActionButtonTheme,
  dividerColor: AppColor.dividerColor.lightColor,
  hintColor: AppColor.hintColor.lightColor,
  shadowColor: AppColor.shadowColor.lightColor,
  primaryColor: AppColor.primaryColor.lightColor,
  primaryColorDark: AppColor.primaryColorDark.lightColor,
  bottomNavigationBarTheme: bottomNavigationBarTheme,
  // buttonTheme: buttonTheme,
  unselectedWidgetColor: AppColor.unselectedWidgetColor.lightColor,

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),

  dialogTheme: DialogThemeData(backgroundColor: AppColor.dialogColor.lightColor, surfaceTintColor: AppColor.dialogColor.lightColor),
  datePickerTheme: DatePickerThemeData(backgroundColor: AppColor.dialogColor.lightColor, surfaceTintColor: AppColor.dialogColor.lightColor),
  primaryColorLight: AppColor.primaryColorLight.lightColor,
  disabledColor: AppColor.disabledColor.lightColor,
  // toggleableActiveColor: AppColor.primaryColor.lightColor,

  /// Text fields
  inputDecorationTheme: kInputDecorationTheme,

  cardTheme: CardThemeData(
    color: AppColor.cardColor.lightColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(kFormRadiusSmall))),
    shadowColor: AppColor.shadowColor.lightColor,
    surfaceTintColor: AppColor.cardColor.lightColor,
    elevation: 4,
  ),
  checkboxTheme: CheckboxThemeData(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
    fillColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.scaffoldBackgroundColor.lightColor:null),
    overlayColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColor.lightColor:null),
    side: BorderSide(color: AppColor.borderColor.lightColor, width: 2.0),

  ),

  radioTheme:RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.borderColor.lightColor:null),
    overlayColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColor.lightColor:null),

  ),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColor.primaryColor.lightColor,
    onPrimary: AppColor.scaffoldBackgroundColor.lightColor,
    primaryContainer: AppColor.primaryColor.lightColor,
    onPrimaryContainer: AppColor.scaffoldBackgroundColor.lightColor,
    inversePrimary: AppColor.primaryColor.lightColor,
    surface: AppColor.scaffoldBackgroundColor.lightColor,
    onSurface: AppColor.primaryColor.lightColor,
    inverseSurface: AppColor.scaffoldBackgroundColor.lightColor,
    onInverseSurface: AppColor.primaryColor.lightColor,
    surfaceContainerHighest: AppColor.scaffoldBackgroundColor.lightColor,
    onSurfaceVariant: AppColor.primaryColorDark.lightColor,
    secondary: AppColor.primaryColorDark.lightColor,
    onSecondary: AppColor.scaffoldBackgroundColor.lightColor,
    secondaryContainer: AppColor.primaryColorDark.lightColor,
    onSecondaryContainer: AppColor.scaffoldBackgroundColor.lightColor,
    // background: AppColor.backgroundColor.lightColor,
    // onBackground: AppColor.primaryColor.lightColor,
    error: AppColor.errorColor.lightColor,
    onError: AppColor.scaffoldBackgroundColor.lightColor,
    errorContainer: AppColor.errorColor.lightColor,
    onErrorContainer: AppColor.scaffoldBackgroundColor.lightColor,
    tertiary: AppColor.primaryColor.lightColor,
    onTertiary: AppColor.scaffoldBackgroundColor.lightColor,
    tertiaryContainer: AppColor.primaryColor.lightColor,
    onTertiaryContainer: AppColor.scaffoldBackgroundColor.lightColor,
    shadow: AppColor.grayScaleLiteColor.lightColor,
    outline: AppColor.primaryColor.lightColor,
  ),
);




ThemeData  darkTheme =ThemeData(
  fontFamily: FontConstants.fontFamily,

  scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor.darkColor,
  textTheme: textThemeDark,
  cardColor: AppColor.cardColor.darkColor,
  brightness: Brightness.dark,
  splashColor: AppColor.hintColor.darkColor,
  highlightColor: AppColor.highlightColor.darkColor,
  appBarTheme: appBarThemeDark,

  visualDensity: VisualDensity.adaptivePlatformDensity,
  hoverColor: AppColor.hoverColor.darkColor,
  shadowColor: AppColor.shadowColor.darkColor,
  floatingActionButtonTheme: floatingActionButtonThemeDark,
  dividerColor: AppColor.dividerColor.darkColor,
  hintColor: AppColor.hintColor.darkColor,
  primaryColor: AppColor.primaryColor.darkColor,
  primaryColorDark: AppColor.primaryColorDark.darkColor,
  bottomNavigationBarTheme: bottomNavigationBarThemeDark,
  // buttonTheme: buttonThemeDark,
  unselectedWidgetColor: AppColor.unselectedWidgetColor.darkColor,

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),

  dialogTheme: DialogThemeData(backgroundColor: AppColor.dialogColor.darkColor, surfaceTintColor: AppColor.dialogColor.darkColor),
  datePickerTheme: DatePickerThemeData(backgroundColor: AppColor.dialogColor.darkColor, surfaceTintColor: AppColor.dialogColor.darkColor),
  primaryColorLight: AppColor.primaryColorLight.darkColor,
  disabledColor: AppColor.disabledColor.darkColor,
  // toggleableActiveColor: AppColor.primaryColor.darkColor,

  /// Text fields
  inputDecorationTheme: kInputDecorationThemeDark,
  cardTheme: CardThemeData(
    color: AppColor.cardColor.darkColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(kFormRadiusSmall))),
    shadowColor: AppColor.shadowColor.darkColor,
    surfaceTintColor: AppColor.cardColor.darkColor,
    elevation: 4,
  ),

  checkboxTheme: CheckboxThemeData(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
    fillColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColor.darkColor:null),
    overlayColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColorDark.darkColor:null),
  ),
  radioTheme:RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColor.darkColor:null),
    overlayColor: WidgetStateProperty.resolveWith((states) =>(!states.contains(WidgetState.selected))?AppColor.primaryColorDark.darkColor:null),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: AppColor.primaryColor.darkColor,
    onPrimary: AppColor.scaffoldBackgroundColor.darkColor,
    primaryContainer: AppColor.primaryColor.darkColor,
    onPrimaryContainer: AppColor.scaffoldBackgroundColor.darkColor,
    inversePrimary: AppColor.primaryColor.darkColor,
    surface: AppColor.scaffoldBackgroundColor.darkColor,
    onSurface: AppColor.primaryColor.darkColor,
    inverseSurface: AppColor.scaffoldBackgroundColor.darkColor,
    onInverseSurface: AppColor.primaryColor.darkColor,
    surfaceContainerHighest: AppColor.scaffoldBackgroundColor.darkColor,
    onSurfaceVariant: AppColor.primaryColorDark.darkColor,
    secondary: AppColor.primaryColorDark.darkColor,
    onSecondary: AppColor.scaffoldBackgroundColor.darkColor,
    secondaryContainer: AppColor.primaryColorDark.darkColor,
    onSecondaryContainer: AppColor.scaffoldBackgroundColor.darkColor,
    // background: AppColor.backgroundColor.darkColor,
    // onBackground: AppColor.primaryColor.darkColor,
    error: AppColor.errorColor.darkColor,
    onError: AppColor.scaffoldBackgroundColor.darkColor,
    errorContainer: AppColor.errorColor.darkColor,
    onErrorContainer: AppColor.scaffoldBackgroundColor.darkColor,
    tertiary: AppColor.primaryColor.darkColor,
    onTertiary: AppColor.scaffoldBackgroundColor.darkColor,
    tertiaryContainer: AppColor.primaryColor.darkColor,
    onTertiaryContainer: AppColor.scaffoldBackgroundColor.darkColor,
    shadow: AppColor.grayScaleLiteColor.darkColor,
    outline: AppColor.primaryColor.darkColor,
  ),
);


