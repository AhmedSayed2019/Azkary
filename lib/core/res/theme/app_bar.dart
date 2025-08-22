import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';


AppBarTheme appBarTheme =  const AppBarTheme(
  // color: appBarColor,

  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: primaryColor,


    statusBarIconBrightness: Brightness.dark ,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: primaryColor,
    systemNavigationBarDividerColor: primaryColor,

  ),
  backgroundColor: appBarColor,


  toolbarTextStyle: TextStyle(color: appBarIconsColorDark),
  iconTheme: IconThemeData(
    color: appBarIconsColorDark,


  ),
);


AppBarTheme appBarThemeDark = const AppBarTheme(

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

