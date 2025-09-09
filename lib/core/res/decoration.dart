

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'values_manager.dart';
import 'color.dart';
import 'text_styles.dart';


class CustomBorderRadius {

 static BorderRadiusGeometry customRadiusDirectional({ double topStart=0, double bottomStart=0, double bottomEnd=0, double topEnd=0}) =>
      BorderRadiusDirectional.only(topStart: Radius.circular(topStart),bottomStart: Radius.circular(bottomStart),bottomEnd: Radius.circular(bottomEnd),topEnd: Radius.circular(topEnd));




}



extension CustomDecoration on BoxDecoration {
  BoxDecoration radius({double radius=kFormRadiusSmall}) => (this).copyWith(borderRadius: BorderRadius.all(Radius.circular(radius)));
  BoxDecoration imageBackground(String assets) => (this).copyWith(image:DecorationImage(fit: BoxFit.fill,image: AssetImage(assets),));
  BoxDecoration circle({double radius=kFormRadius}) => (this).copyWith(shape: BoxShape.circle);
  BoxDecoration customRadius({required BorderRadiusGeometry borderRadius}) => (this).copyWith(borderRadius: borderRadius);
  BoxDecoration customRadiusDirectional({ double topStart=0, double bottomStart=0, double bottomEnd=0, double topEnd=0}) => (this)
      .copyWith(borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(topStart),bottomStart: Radius.circular(bottomStart),bottomEnd: Radius.circular(bottomEnd),topEnd: Radius.circular(topEnd)));



  BoxDecoration shadow({double radius=6,Color? color,Offset? offset }) => (this).copyWith(boxShadow: [ BoxShadow(color: color??AppColor.grayScaleLiteColor.themeColor, spreadRadius: 0, blurRadius: radius,offset: offset??Offset.zero)]);
  BoxDecoration listStyle({double radius=kFormRadius}) => (this).copyWith(borderRadius: BorderRadius.all(Radius.circular(radius)));
  BoxDecoration borderStyle({double width=1,Color? color  ,}) => (this).copyWith(border: Border.all(width: width,color: color??AppColor.borderColor.themeColor));
  // BoxDecoration borderStyle({double width=1,Color? color  ,}) => (this).copyWith(border: Border.all(width: width,color: color?? const Color(0xFFE2E2E2)));
  BoxDecoration borderAll({BoxBorder? border}) => (this).copyWith(border: border);
  BoxDecoration customColor(Color? color) => (this).copyWith(color: color);
  BoxDecoration activeColor() => (this).copyWith(color: AppColor.primaryColor.themeColor);
  BoxDecoration whiteColor() => (this).copyWith(color: Colors.white);
  BoxDecoration activeLiteColor() => (this).copyWith(color: AppColor.primaryColorLight.lightColor);
  BoxDecoration gradientStyle( { Gradient? gradient,bool isEnable = true}) => (this).copyWith(gradient: isEnable?gradient??getMainColorGradient():null);

  BoxDecoration cardStyle({Color? borderColor,double  borderWidth=1,double radius = kFormRadius,Color? color}) => (this).customColor( color??AppColor.cardColor.themeColor).radius(radius: radius).borderStyle(width: borderWidth,color: borderColor);

}




TextStyle appBarTextStyle = const TextStyle(
    fontSize: kAppbarTextSize,
    height: 1
);

final InputDecorationTheme kInputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: AppColor.cardColor.lightColor,

  hintStyle: const TextStyle().regularStyle(fontSize: 13).customColor(AppColor.hintColor.lightColor),
  labelStyle: const TextStyle().semiBoldStyle(fontSize: 13).customColor(AppColor.textColor.lightColor),
  suffixStyle: const TextStyle().regularStyle().customColor(AppColor.grayScaleColor.lightColor),
  errorStyle: const TextStyle().semiBoldStyle(fontSize: 13).errorStyle(),

  prefixIconColor: AppColor.primaryColorDark.lightColor  ,
  iconColor:  AppColor.primaryColorDark.lightColor  ,



  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kFormRadius), borderSide:  BorderSide(color: AppColor.cardColor.lightColor , width: 1),),
  contentPadding: EdgeInsets.all(12.w),
  errorMaxLines: 2,
  focusedBorder: OutlineInputBorder(borderSide:  BorderSide(color:AppColor.primaryColor.lightColor), borderRadius: BorderRadius.circular(kFormRadius),),
  enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color:AppColor.borderColor.lightColor, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),
  border: OutlineInputBorder(borderSide:  BorderSide(color:  AppColor.borderColor.lightColor, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),
  errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.transparent, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),
  focusedErrorBorder: OutlineInputBorder(borderSide:  BorderSide(color: AppColor.errorColor.lightColor, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),


);
final InputDecorationTheme kInputDecorationThemeDark = InputDecorationTheme(
  filled: true,
  fillColor: AppColor.cardColor.darkColor,

  hintStyle: const TextStyle().regularStyle(fontSize: 12).customColor(AppColor.borderColor.darkColor),
  labelStyle: const TextStyle().semiBoldStyle(fontSize: 12).customColor(AppColor.textColor.darkColor),
  suffixStyle: const TextStyle().regularStyle().customColor(AppColor.grayScaleColor.darkColor),
  errorStyle: const TextStyle().semiBoldStyle(fontSize: 8).errorStyle(),

  prefixIconColor: AppColor.primaryColorDark.darkColor  ,
  iconColor:  AppColor.primaryColorDark.darkColor  ,



  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kFormRadius), borderSide:  BorderSide(color: AppColor.cardColor.darkColor , width: 1),),
  contentPadding: EdgeInsets.all(12.w),
  errorMaxLines: 2,
  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(kFormRadius),),
  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color:Colors.transparent, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),
  border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.transparent, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),
  errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.transparent, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),
  focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.transparent, width: 1.2), borderRadius: BorderRadius.circular(kFormRadius),),


);


final SystemUiOverlayStyle kSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor:  Colors.transparent,
  systemNavigationBarColor:  Colors.transparent,
  systemNavigationBarIconBrightness:Brightness.dark ,
  systemNavigationBarDividerColor:  Colors.transparent,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarContrastEnforced: true,
  statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
  statusBarBrightness: Brightness.dark , // For iOS (dark icons)
);