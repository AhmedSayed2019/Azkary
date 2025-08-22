

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';

import 'color.dart';
import 'text_styles.dart';
import 'values_manager.dart';





extension CustomDecoration on BoxDecoration {
  BoxDecoration radius({double radius=kFormRadiusSmall}) => (this).copyWith(borderRadius: BorderRadius.all(Radius.circular(radius)));
  BoxDecoration customRadius({required BorderRadius borderRadius}) => (this).copyWith(borderRadius: borderRadius);
  BoxDecoration shadow({double radius=kFormRadiusSmall}) => (this).copyWith(boxShadow: [const BoxShadow(color: grayScaleLiteColor, spreadRadius: 1, blurRadius: 5)]);
  BoxDecoration listStyle({double radius=kFormRadiusSmall}) => (this).copyWith(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(radius)));
  BoxDecoration borderStyle({double width=1,Color color = grayScaleColor ,}) => (this).copyWith(border: Border.all(width: width,color: color));
  BoxDecoration customColor(Color? color) => (this).copyWith(color: color);
  BoxDecoration gradientStyle( { Gradient? gradient}) => (this).copyWith(gradient: gradient??getMainColorGradient());
}




TextStyle appBarTextStyle = const TextStyle(
    fontSize: kAppbarTextSize,
    height: 1
);

final InputDecorationTheme kInputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: cardColor,

  hintStyle: const TextStyle().regularStyle().hintColor(),
  labelStyle: const TextStyle().regularStyle().blackStyle(),
  suffixStyle: const TextStyle().regularStyle().customColor(grayScaleColor),
  errorStyle: const TextStyle().descriptionStyle().errorStyle(),

  prefixIconColor:primaryColorDark ,
  iconColor:primaryColorDark ,


  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kFormRadiusSmall.r), borderSide: const BorderSide(color: primaryColor, width: 1),),
  contentPadding: EdgeInsets.all(12.w),
  errorMaxLines: 2,
  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(kFormRadiusSmall.r),),
  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: hintColor), borderRadius: BorderRadius.circular(kFormRadiusSmall.r),),
  errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: errorColor), borderRadius: BorderRadius.circular(kFormRadiusSmall.r),),
  focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(kFormRadiusSmall.r),),
);