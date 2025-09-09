import 'package:flutter/material.dart';

import '../font_manager.dart';
import '../color.dart';

BottomNavigationBarThemeData bottomNavigationBarTheme = BottomNavigationBarThemeData(
  backgroundColor: AppColor.primaryColor.lightColor,
  elevation: 0,
  selectedItemColor: AppColor.primaryColor.lightColor,
  unselectedItemColor: AppColor.hintColor.lightColor,
  // selectedLabelStyle: const TextStyle(fontFamily: FontConstants.fontFamily),
  // unselectedLabelStyle: const TextStyle(fontFamily: FontConstants.fontFamily),
);

BottomNavigationBarThemeData bottomNavigationBarThemeDark =
     BottomNavigationBarThemeData(
      backgroundColor: AppColor.primaryColor.darkColor,
      elevation: 0,
      selectedItemColor: AppColor.primaryColor.darkColor,
      unselectedItemColor: AppColor.hintColor.darkColor,
      // selectedLabelStyle: const TextStyle(fontFamily: FontConstants.fontFamily),
      // unselectedLabelStyle: const TextStyle(fontFamily: FontConstants.fontFamily),
);
