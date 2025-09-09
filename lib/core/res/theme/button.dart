// import 'package:flutter/material.dart';
//
// import '../color.dart';
//
import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';

final floatingActionButtonTheme = ThemeData.light().floatingActionButtonTheme.copyWith(backgroundColor: AppColor.floatingActionButtonColor.lightColor,shape: const CircleBorder());
final floatingActionButtonThemeDark = ThemeData.dark().floatingActionButtonTheme.copyWith(backgroundColor: AppColor.floatingActionButtonColor.darkColor,shape: const CircleBorder());
//
// // button theme
// const buttonTheme = ButtonThemeData(
//   buttonColor: colorButton,
//
//   textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
//   // colorScheme: ButtonTextTheme.primary,
// );
// const buttonThemeDark = ButtonThemeData(
//   buttonColor: colorButtonDark,
//   textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
// );
