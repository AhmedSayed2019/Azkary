import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';


import 'resources.dart';


extension TextCustom on TextStyle {

  TextStyle activeColor() => (this).copyWith(color: AppColor.primaryColor.themeColor);
  TextStyle customColor(Color? color) => (this).copyWith(color: color);
  TextStyle colorBlack() => (this).copyWith(color:  Colors.black);
  TextStyle liteColor() => (this).copyWith(color: AppColor.cardColor.themeColor);
  TextStyle activeLiteColor() => (this).copyWith(color: AppColor.primaryColorLight.themeColor);
  TextStyle activeDarkColor() => (this).copyWith(color: AppColor.primaryColorDark.themeColor);
  TextStyle errorStyle() => (this).copyWith(color: AppColor.errorColor.lightColor);
  TextStyle colorLiteHint() => (this).copyWith(color: AppColor.hintColor.lightColor);
  TextStyle colorHint() => (this).copyWith(color: AppColor.hintColor.themeColor);
  TextStyle colorHintDark() => (this).copyWith(color: const Color(0xff231F20));
  TextStyle colorHintLiteColor() => (this).copyWith(color: AppColor.highlightColor.themeColor);
  TextStyle colorHover() => (this).copyWith(color: AppColor.hoverColor.themeColor);
  TextStyle textFamily({String? fontFamily} ) => (this).copyWith(fontFamily: fontFamily);
  TextStyle darkTextStyle() => (this).copyWith(color:  AppColor.textColor.darkColor);
  TextStyle boldActiveStyle() => (this).copyWith(fontWeight: FontWeight.bold,color: AppColor.primaryColor.themeColor);
  TextStyle boldStyle() => (this).copyWith(fontWeight: FontWeight.bold);
  TextStyle boldBlackStyle() => (this).copyWith( fontWeight: FontWeight.w900,color: Colors.black);
  TextStyle heavyBlackStyle() => (this).copyWith(fontWeight: FontWeight.w800,color: Colors.black);
  TextStyle boldWhiteStyle() => (this).copyWith(fontWeight: FontWeight.bold,color: Colors.white);
  TextStyle colorWhite() => (this).copyWith(color: Colors.white);
  TextStyle heavyWhiteStyle() => (this).copyWith(fontWeight: FontWeight.w800,color: Colors.white);
  TextStyle italic() => (this).copyWith(fontStyle: FontStyle.italic);
  TextStyle boldLiteStyle() => (this).copyWith(fontWeight: FontWeight.w500);
  TextStyle greenStyle() => (this).copyWith(color: Colors.green);
  TextStyle underLineStyle() => (this).copyWith(decoration: TextDecoration.underline);
  TextStyle ellipsisStyle({int line = 1}) => (this).copyWith( overflow: TextOverflow.ellipsis,);
  TextStyle heightStyle({double height = 1}) => (this).copyWith( height: height);
  TextStyle lineThroughStyle({bool enable=true}) => (this).copyWith(decoration: enable?TextDecoration.lineThrough:null);

  TextStyle primaryTextColor() => (this).copyWith(color:  AppColor.textColor.themeColor);
  TextStyle primaryLiteTextColor() => (this).copyWith(color:  AppColor.textColorLite.themeColor);
  TextStyle customFontFamily(String fontFamily) => (this).copyWith(fontFamily: fontFamily);



  TextStyle titleStyle({double fontSize = 17.5}) => (this).copyWith(fontSize: fontSize.sp, color: Colors.black, fontWeight: FontWeight.w900, fontFamily: FontConstants.fontFamily );
  TextStyle regularStyle({double fontSize = 14, FontWeight? fontWeight }) => (this).copyWith(fontSize: fontSize.sp, color: Colors.black, fontWeight: fontWeight??FontWeight.w400, fontFamily: FontConstants.fontFamily );
  TextStyle semiBoldStyle({double fontSize = 14}) => (this).copyWith( fontSize: fontSize.sp,color: Colors.black,fontWeight: FontWeight.w600, fontFamily: FontConstants.fontFamily );
  TextStyle mediumStyle({double fontSize = 14}) => (this).copyWith( fontSize: fontSize.sp,fontWeight: FontWeight.w500, fontFamily: FontConstants.fontFamily );


  TextStyle descriptionStyle({double fontSize = 10}) => (this).copyWith(fontSize: fontSize.sp, color: AppColor.hintColor.lightColor, fontWeight: FontWeight.w300, fontFamily: FontConstants.fontFamily );
  TextStyle customFontWeight({double fontSize = 14,FontWeight? fontWeight}) => (this).copyWith(fontSize: fontSize.sp, color: AppColor.hintColor.lightColor, fontWeight: fontWeight, fontFamily: FontConstants.fontFamily );





}
