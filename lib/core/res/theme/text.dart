import 'package:azkark/core/res/font_manager.dart';
import 'package:flutter/material.dart';

import '../color.dart';
import '../decoration.dart';

/// The `displayColor` is applied to [headline4], [headline3], [headline2],
/// [headline1], and [caption]. The `bodyColor` is applied to the remaining
/// text styles.

// // light
// TextTheme textTheme = ThemeData.light().textTheme.copyWith().apply(
//   bodyColor:  AppColor.hintColor.lightColor, // bodyText1 (secondary text color)
//   displayColor: AppColor.textColor.lightColor, // caption ( primary text color)
//
//   fontFamily: FontConstants.fontFamily,
//   fontFamilyFallback: [FontConstants.fontFamily,FontConstants.fontHobeauxFamily,FontConstants.fontMerriweatherFamily],
// );


// light
TextTheme textTheme = ThemeData.light().textTheme.copyWith().apply(
  bodyColor:  AppColor.hintColor.lightColor, // bodyText1 (secondary text color)
  displayColor: AppColor.textColor.lightColor, // caption ( primary text color)

  fontFamily: FontConstants.fontFamily,
  fontFamilyFallback: [FontConstants.fontFamily,FontConstants.fontHobeauxFamily,FontConstants.fontMerriweatherFamily],
);


// TextTheme theme = ThemeData(
//   useMaterial3: true,
//   colorScheme: scheme,
//   textTheme: buildTextTheme(scheme),
//   fontFamily: FontConstants.fontFamily,
// );



// dark
TextTheme textThemeDark = ThemeData.dark().textTheme.copyWith().apply(
  bodyColor: AppColor.textColor.darkColor,
  displayColor:  AppColor.textColor.lightColor,
  fontFamily: FontConstants.fontFamily,
  fontFamilyFallback: [FontConstants.fontFamily,FontConstants.fontHobeauxFamily,FontConstants.fontMerriweatherFamily],


);

// appBar Text Style
TextTheme appBarTextTheme = textTheme.copyWith(
// center text style
  labelLarge: appBarTextStyle.copyWith(color:  AppColor.appBarTextColor.lightColor),
// Side text style
  bodyMedium: appBarTextStyle.copyWith(color:  AppColor.appBarTextColor.lightColor),
);

TextTheme appBarTextThemeDark = textTheme.copyWith(
  labelLarge: appBarTextStyle.copyWith(color: AppColor.appBarTextColor.darkColor),
  bodyMedium: appBarTextStyle.copyWith(color: AppColor.appBarTextColor.darkColor),
);













TextTheme buildTextTheme(ColorScheme scheme) {
  const family = FontConstants.fontFamily;
  const fallbacks = [FontConstants.fontHobeauxFamily, FontConstants.fontMerriweatherFamily];

  TextStyle _ts(
      double size,
      FontWeight weight,
      Color color, {double? lh,  /*line-height (multiplier)*/double? ls/*letter-spacing*/}) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallbacks,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: lh,
        letterSpacing: ls,
      );

  return TextTheme(

    // DISPLAY
    displayLarge:  _ts(57, FontWeight.w400, scheme.onSurface,        lh: 1.12, ls: -0.25),
    displayMedium: _ts(45, FontWeight.w400, scheme.onSurface,        lh: 1.16),
    displaySmall:  _ts(36, FontWeight.w400, scheme.onSurface,        lh: 1.22),

    // HEADLINE
    headlineLarge:  _ts(32, FontWeight.w400, scheme.onSurface,       lh: 1.25),
    headlineMedium: _ts(28, FontWeight.w400, scheme.onSurface,       lh: 1.29),
    headlineSmall:  _ts(24, FontWeight.w400, scheme.onSurface,       lh: 1.33),

    // TITLE
    titleLarge:  _ts(22, FontWeight.w400, scheme.onSurface,          lh: 1.27),
    titleMedium: _ts(16, FontWeight.w500, scheme.onSurface,          lh: 1.50, ls: 0.15),
    titleSmall:  _ts(14, FontWeight.w500, scheme.onSurface,          lh: 1.43, ls: 0.10),

    // BODY
    bodyLarge:  _ts(16, FontWeight.w400, scheme.onSurface,           lh: 1.50, ls: 0.50),
    bodyMedium: _ts(14, FontWeight.w400, scheme.onSurfaceVariant,    lh: 1.43, ls: 0.25),
    bodySmall:  _ts(12, FontWeight.w400, scheme.onSurfaceVariant,    lh: 1.33, ls: 0.40),

    // LABEL
    labelLarge:  _ts(14, FontWeight.w500, scheme.onSurface,          lh: 1.43, ls: 0.10),
    labelMedium: _ts(12, FontWeight.w500, scheme.onSurfaceVariant,   lh: 1.33, ls: 0.50),
    labelSmall:  _ts(11, FontWeight.w500, scheme.onSurfaceVariant,   lh: 1.45, ls: 0.50),
  );
}
