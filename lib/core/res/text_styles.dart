import 'package:flutter/material.dart';

import 'color.dart';
import 'font_manager.dart';


extension TextCustom on TextStyle {

  TextStyle activeColor() => (this).copyWith(color: primaryColor);
  TextStyle customColor(Color? color) => (this).copyWith(color: color);
  TextStyle colorWhite() => (this).copyWith(color: Colors.white);
  TextStyle colorLiteText() => (this).copyWith(color: const Color(0xffC1F3EF));
  TextStyle liteColor() => (this).copyWith(color: cardColor);
  TextStyle activeLiteColor() => (this).copyWith(color: primaryColorLight);
  TextStyle errorStyle() => (this).copyWith(color: errorColor);
  TextStyle hintColor() => (this).copyWith(color: textSecondary);
  TextStyle hintLiteColor() => (this).copyWith(color: hoverColor);
  TextStyle textFamily({String? fontFamily} ) => (this).copyWith(fontFamily: fontFamily);
  TextStyle darkTextStyle() => (this).copyWith(color: textPrimaryDark);
  TextStyle boldActiveStyle() => (this).copyWith(fontWeight: FontWeight.bold,color: primaryColor);
  TextStyle boldStyle() => (this).copyWith(fontWeight: FontWeight.bold);
  TextStyle boldBlackStyle() => (this).copyWith(fontWeight: FontWeight.bold,color: Colors.black);
  TextStyle boldLiteStyle() => (this).copyWith(fontWeight: FontWeight.w500);
  TextStyle blackStyle() => (this).copyWith(color: Colors.black);
  TextStyle underLineStyle() => (this).copyWith(decoration: TextDecoration.underline);
  TextStyle ellipsisStyle({int line = 1}) => (this).copyWith( overflow: TextOverflow.ellipsis);
  TextStyle heightStyle({double height = 1}) => (this).copyWith( height: height);
  

  TextStyle titleStyle({double fontSize = 20}) => (this).copyWith(fontSize: fontSize, color: primaryColorDark, fontWeight: FontWeight.w600, fontFamily: FontConstants.fontFamily );
  TextStyle semiBoldStyle({double fontSize = 20}) => (this).copyWith(fontSize: fontSize, color: primaryColorDark, fontWeight: FontWeight.w700, fontFamily: FontConstants.fontFamily );
  TextStyle regularStyle({double fontSize = 16}) => (this).copyWith(fontSize: fontSize, color: primaryColorDark, fontWeight: FontWeight.w400, fontFamily: FontConstants.fontFamily );
  TextStyle descriptionStyle({double fontSize = 12}) => (this).copyWith(fontSize: fontSize, color: textSecondary, fontWeight: FontWeight.w300, fontFamily: FontConstants.fontFamily );


}
