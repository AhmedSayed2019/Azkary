import 'package:azkark/app.dart';
import 'package:azkark/core/res/theme/theme.dart';
import 'package:azkark/core/res/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Color converter: https://www.w3schools.com/colors/colors_converter.asp
// Transparency list
// 100% FF
// 95%  F2
// 90%  E6
// 87%  DE
// 85%  D9
// 80%  CC
// 75%  BF
// 70%  B3
// 65%  A6
// 60%  99
// 55%  8C
// 54%  8A
// 50%  80
// 45%  73
// 40%  66
// 35%  59
// 32%  52
// 30%  4D
// 26%  42
// 25%  40
// 20%  33
// 16%  29
// 15%  26
// 12%  1F
// 10%  1A
// 5%   0D
// 0%   00
/* ------------------------Theme Colors ----------------------------------*/
typedef Clr = ColorModel;


///appColors
class AppColor {
  // primary color
  static Clr primaryColor = const ColorModel(lightColor: Color(0xFF0C650F),darkColor:  Color(0xFF0C650F));
  static Clr primaryColorDark = const ColorModel(lightColor: Color(0xFF0C650F),darkColor: Color(0xff000000));
  static Clr primaryColorLight = const ColorModel(lightColor: Color(0xFFC8E6C9),darkColor: Color(0xFF0C650F));//100: Color(0xFFC8E6C9),
  // static Clr primaryColorLight = const ColorModel(lightColor: Color(0xff2968CD),darkColor: Color(0xff2968CD));

  static Clr primaryBackgroundColor = const ColorModel(lightColor: Color(0xffF2F8FD),darkColor: Color(0xff363738));
  static Clr primaryBackgroundDarkColor = const ColorModel(lightColor: Color(0xffFFEDD4),darkColor: Color(0xffFFEDD4));

  //Text
  static Clr textColor = const ColorModel(lightColor: Color(0xFF0C650F),darkColor: Colors.white);
  // static Clr textColor = const ColorModel(lightColor: Color(0xff0D0D12),darkColor: Colors.white);
  static Clr textColorLite = const ColorModel(lightColor: Colors.white,darkColor: Colors.black87);
  static Clr hintColor = const ColorModel(lightColor: Color(0xff96A19A),darkColor:  Color(0xffffffff));
  // static Clr hintColor = const ColorModel(lightColor: Color(0xff666D80),darkColor:  Color(0xffffffff));
  // static Clr borderColor = const ColorModel(lightColor: Color(0xffDFE1E7),darkColor:  Color(0xffDFE1E7));
  static Clr borderColor = const ColorModel(lightColor: Color(0xffDFE1E7),darkColor:  Color(0xff666D80));
  static Clr textSecondaryDark = const ColorModel(lightColor: Color(0xffB0B0B0),darkColor:  Color(0xffB0B0B0));

  //Error
  static Clr errorColor = const ColorModel(lightColor: Colors.red,darkColor: Colors.redAccent);

  //FloatingAction
  static Clr floatingActionButtonColor =  ColorModel(lightColor:primaryColor.lightColor,darkColor: primaryColor.darkColor);

  //App bar icons
  static Clr appBarIconsColor =  const ColorModel(lightColor:Colors.black87,darkColor: Colors.white);
  static Clr appBarTextColor =  const ColorModel(lightColor:Colors.white,darkColor: Colors.black87);

  //Gray
  static Clr shadowColor =  const ColorModel(lightColor: Color(0xffa8a7a7),darkColor:  Color(0xffc5c4c4));
  static Clr highlightColor =  const ColorModel(lightColor: Color(0xFF66BB6A),darkColor:  Color(0xff4b4b48));//400: Color(0xFF66BB6A),
  static Clr grayScaleLiteColor = const ColorModel(lightColor: Color(0xFFE2E2E2),darkColor:  Color(0xff000000));

  //divider
  static Clr dividerColor =  const ColorModel(lightColor: Color(0xffECEFF3),darkColor:  Color(0xff464646));


  //App
  static Clr scaffoldBackgroundColor =  const ColorModel(lightColor: Color(0xffFCFCFC),darkColor: Color(0xff0D0D0D));
  // static Clr scaffoldBackgroundColor =  const ColorModel(lightColor: Color(0xffFCFCFC),darkColor: Color(0xff2E2E34));
  static Clr statusBarColor =   ColorModel(lightColor: scaffoldBackgroundColor.lightColor,darkColor:  scaffoldBackgroundColor.darkColor);
  static Clr cardColor =  const ColorModel(lightColor: Color(0xFFEAE9D9),darkColor:  Color(0xff222222));//300: Color(0xFFEAE9D9),
  // static Clr cardColor =  const ColorModel(lightColor: Color(0xffffffff),darkColor:  Color(0xff1A1B25));
  static Clr dialogColor =  const ColorModel(lightColor: Color(0xffffffff),darkColor:  Color(0xff000000));
  static Clr backgroundColor =  const ColorModel(lightColor: Color(0xFFFFFFFF),darkColor:  Color(0xff000000));

  static Clr disabledColor =  const ColorModel(lightColor: Color(0xffEEEEEE),darkColor:  Color(0xffEEEEEE));
  static Clr unselectedWidgetColor =  const ColorModel(lightColor: Color(0xffB0B0B0),darkColor:  Color(0xffB0B0B0));
  static Clr hoverColor =  const ColorModel(lightColor: Color(0xffecedec),darkColor:  Color(0xffecedec));
  static Clr grayScaleColor =  const ColorModel(lightColor: Color(0xFFE2E2E2),darkColor:  Color(0xFFE2E2E2));

  static Clr rateColor = const ColorModel(lightColor: Color(0xffFFBE4C),darkColor: Color(0xffFFBE4C));

  static Clr shimmer1 = const ColorModel(lightColor: Color(0xFFE0E0E0),darkColor: Color(0xff222222));
  static Clr shimmer2 = const ColorModel(lightColor: Color(0xFFF5F5F5),darkColor: Color(0xff515151));



  //app
  static Clr badgeColor = const ColorModel(lightColor: Color(0xffFFAC13),darkColor: Color(0xffFFAC13));

}


extension ColorTheme on ColorModel {
  Color get themeColor {
    if (appContext!=null&&Provider.of<ThemeHelper>(appContext!,listen: false).themeData == darkTheme) {
    // if (appContext!=null&&appContext!.watch<ThemeHelper>().themeData == darkTheme) {
      return darkColor;
    } else {
      return lightColor;
    }
  }
}

class ColorModel {
  final Color _lightColor;
  final Color _darkColor;
  const ColorModel({
    required Color lightColor,
    required Color darkColor,
  })  : _lightColor = lightColor,
        _darkColor = darkColor;
  Color get darkColor => _darkColor;
  Color get lightColor => _lightColor;
}

LinearGradient getMainColorGradient() =>   LinearGradient(begin: Alignment.topRight, end: Alignment.topLeft , colors: [AppColor.primaryColor.lightColor, AppColor.primaryColor.lightColor,]);
LinearGradient getButtonGradient() =>   LinearGradient(begin: Alignment.topRight, end: Alignment.topLeft , colors: [AppColor.primaryColor.lightColor, AppColor.primaryColor.lightColor,]);
LinearGradient getBackgroundGradient(bool isDarkMode) => LinearGradient(stops: const [0.0,0.3], colors: isDarkMode?[const Color(0xfff11b1b), AppColor.scaffoldBackgroundColor.darkColor]:[const Color(0xffeef9fc), AppColor.scaffoldBackgroundColor.lightColor], begin: Alignment.topCenter, end: Alignment.bottomCenter,);
LinearGradient getImageGradient() =>LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromRGBO(0, 0, 0, 0.0), Color.fromRGBO(0, 0, 0, 1.0),],);