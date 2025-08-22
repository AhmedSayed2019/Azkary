
import 'package:flutter/material.dart';

import '../color.dart';
import '../decoration.dart';
import 'app_bar.dart';
import 'bottom_bar.dart';
import 'button.dart';
import 'text.dart';

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: false,
    fontFamily: '0',

    scaffoldBackgroundColor: scaffoldBackgroundColor,

    // backgroundColor: scaffoldBackgroundColor,
    cardColor: cardColor,
    brightness: Brightness.light,
    splashColor: primaryColor,
    highlightColor: highlightColor,
    appBarTheme: appBarTheme,

    visualDensity: VisualDensity.adaptivePlatformDensity,
    // accentColor: accentColor,
    hoverColor: hoverColor,
    floatingActionButtonTheme: floatingActionButtonTheme,
    dividerColor: dividerColor,
    // errorColor: errorColor,
    hintColor: textSecondary,
    primaryColor: primaryColor,
    primaryColorDark: primaryColorDark,
    bottomNavigationBarTheme: bottomNavigationBarTheme,
    buttonTheme: buttonTheme,
    switchTheme: switchThemeData,

    unselectedWidgetColor: unselectedWidgetColor,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
    }),

    primaryColorLight: primaryColorLight,
    disabledColor: unselectedWidgetColor,
    // toggleableActiveColor: primaryColor,

    /// Text fields
    inputDecorationTheme: kInputDecorationTheme,

    colorScheme: ColorScheme(
      brightness: Brightness.light,

      primary: primaryColor,
      onPrimary: scaffoldBackgroundColor,
      primaryContainer: primaryColor,
      onPrimaryContainer: scaffoldBackgroundColor,
      inversePrimary: primaryColor,

      surface: scaffoldBackgroundColor,
      onSurface: primaryColor,
      inverseSurface: scaffoldBackgroundColor,
      onInverseSurface: primaryColor,
      surfaceVariant: scaffoldBackgroundColor,
      onSurfaceVariant: primaryColor,

      secondary: primaryColorDark,
      onSecondary: scaffoldBackgroundColor,
      secondaryContainer: primaryColorDark,
      onSecondaryContainer: scaffoldBackgroundColor,

      background: backgroundColor,
      onBackground: primaryColor,

      error: errorColor,
      onError: scaffoldBackgroundColor,
      errorContainer: errorColor,
      onErrorContainer: scaffoldBackgroundColor,


      tertiary: primaryColor,
      onTertiary: scaffoldBackgroundColor,
      tertiaryContainer: primaryColor,
      onTertiaryContainer: scaffoldBackgroundColor,


      shadow: grayScaleLiteColor,
      outline: primaryColor,

    ),
  );
}

ThemeData get darkTheme {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: scaffoldBackgroundColorDark,
    textTheme: textThemeDark,
    highlightColor: highlightColorDark,
    appBarTheme: appBarThemeDark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // accentColor: accentColorDark,
    floatingActionButtonTheme: floatingActionButtonThemeDark,
    dividerColor: dividerColorDark,
    // errorColor: errorColorDark,
    hintColor: textSecondaryDark,
    primaryColor: primaryColorDark,
    bottomNavigationBarTheme: bottomNavigationBarThemeDark,
    buttonTheme: buttonThemeDark,
    // cursorColor: cursorDark,
    // textSelectionHandleColor: textSelectionHandleDark,
    // textSelectionColor: textSelectionDark,
  );
}
