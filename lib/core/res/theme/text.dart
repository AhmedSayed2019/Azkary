import 'package:flutter/material.dart';

import '../color.dart';
import '../decoration.dart';

/// The `displayColor` is applied to [headline4], [headline3], [headline2],
/// [headline1], and [caption]. The `bodyColor` is applied to the remaining
/// text styles.

// light
TextTheme textTheme = ThemeData.light().textTheme.copyWith().apply(
  bodyColor:  AppColor.hintColor.lightColor, // bodyText1 (secondary text color)
  displayColor: AppColor.textColor.lightColor, // caption ( primary text color)
);

// dark
TextTheme textThemeDark = ThemeData.dark().textTheme.copyWith().apply(
  bodyColor: AppColor.textColor.darkColor,
  displayColor:  AppColor.textColor.lightColor,
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
