import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';


AppBarTheme appBarTheme = const AppBarTheme(
  color: appBarColor,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: primaryColor,
    statusBarIconBrightness: Brightness.dark ,
    statusBarBrightness: Brightness.light,
  ),
  toolbarTextStyle: TextStyle(color: appBarIconsColor),
  iconTheme: IconThemeData(
    color: appBarIconsColor,
  ),
);


AppBarTheme appBarThemeDark = const AppBarTheme(
  color: appBarColor,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: appBarIconsColor,
    statusBarIconBrightness: Brightness.light ,
    statusBarBrightness: Brightness.dark,
  ),
  toolbarTextStyle: TextStyle(color: appBarIconsColorDark),
  iconTheme: IconThemeData(
    color: appBarIconsColorDark,
  ),
);

