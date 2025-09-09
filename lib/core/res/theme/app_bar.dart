import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';


AppBarTheme appBarTheme =  AppBarTheme(
  color:AppColor.primaryColor.lightColor ,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor:AppColor.appBarIconsColor.lightColor ,
    statusBarIconBrightness: Brightness.light ,
    statusBarBrightness: Brightness.dark ,
  ),
  toolbarTextStyle: TextStyle(color:AppColor.appBarIconsColor.lightColor ),
  iconTheme: IconThemeData(
    color:AppColor.appBarIconsColor.lightColor ,
  ),
);

// AppBarTheme appBarTheme =  AppBarTheme(
//   color:AppColor.statusBarColor.themeColor ,
//   systemOverlayStyle: SystemUiOverlayStyle(
//     statusBarColor:AppColor.statusBarColor.themeColor appBarIconsColorDark,
//     statusBarIconBrightness: Brightness.light ,
//     statusBarBrightness: Brightness.dark ,
//   ),
//   toolbarTextStyle: TextStyle(color: AppColor.statusBarColor.themeColorappBarIconsColor),
//   iconTheme: IconThemeData(color:AppColor.statusBarColor.themeColor appBarIconsColor),
// );
//

AppBarTheme appBarThemeDark =  AppBarTheme(
  color:AppColor.primaryColor.darkColor ,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor:AppColor.appBarIconsColor.darkColor ,
    statusBarIconBrightness: Brightness.light ,
    statusBarBrightness: Brightness.dark,
  ),
  toolbarTextStyle: TextStyle(color:AppColor.appBarIconsColor.darkColor ),
  iconTheme: IconThemeData(
    color:AppColor.appBarIconsColor.darkColor ,
  ),
);

