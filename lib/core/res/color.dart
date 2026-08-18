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
/* ------------------------Theme Colors ----------------------------------
 باليت التطبيق: أخضر غامق + ذهبي + أسطح كريمية.
 القاعدة الحاكمة: الذهبي الفاتح (rateColor/gold) للنص على الأخضر فقط،
 والذهبي الغامق (goldDeepColor) للنص على الأسطح الفاتحة فقط.

 Brand:    greenDeep #0D4429 | green #166534 | gold #E9C46A | goldDeep #A8801E
 Surfaces: background #F3F2ED | card #FFFDF7 | cardMuted #F0EFE7 | border #E7E4D8
 Text:     ink #1D2E22 | inkSoft #6E7A6F | hint #8A9689 | muteRed #C0654A
 Dark:     bg #0B1710 | card #12241A | cardMuted #17301F | border #1E3527
           ink #E8EDE8 | inkSoft #9CAB9F
------------------------------------------------------------------------- */
typedef Clr = ColorModel;


///appColors
class AppColor {
  // primary color — greenDeep للهيدر والعناصر النشطة، وفي الليلي green أفتح درجة
  static Clr primaryColor = const ColorModel(lightColor: Color(0xFF0D4429),darkColor: Color(0xFF166534));
  static Clr primaryColorDark = const ColorModel(lightColor: Color(0xFF082A19),darkColor: Color(0xFF0D4429));
  // greenTint: خلفيات الأيقونات داخل الكروت الفاتحة
  static Clr primaryColorLight = const ColorModel(lightColor: Color(0xFFEDF1E9),darkColor: Color(0xFF17301F));

  static Clr primaryBackgroundColor = const ColorModel(lightColor: Color(0xFFF3F2ED),darkColor: Color(0xFF12241A));
  static Clr primaryBackgroundDarkColor = const ColorModel(lightColor: Color(0xFFF0EFE7),darkColor: Color(0xFF17301F));

  // الذهبي الفاتح — على الأخضر فقط (حلقة العدّاد، أيقونة الصلاة النشطة...)
  static Clr rateColor = const ColorModel(lightColor: Color(0xFFE9C46A),darkColor: Color(0xFFE9C46A));
  // الذهبي الغامق — للنص/الأيقونات فوق الأسطح الفاتحة
  static Clr goldDeepColor = const ColorModel(lightColor: Color(0xFFA8801E),darkColor: Color(0xFFE9C46A));
  static Clr successColor = const ColorModel(lightColor: Color(0xFF2E7D4F),darkColor: Color(0xFF2E7D4F));

  //Text
  static Clr textColor = const ColorModel(lightColor: Color(0xFF1D2E22),darkColor: Color(0xFFE8EDE8));
  static Clr textColorLite = const ColorModel(lightColor: Colors.white,darkColor: Color(0xFF0B1710));
  static Clr hintColor = const ColorModel(lightColor: Color(0xFF8A9689),darkColor: Color(0xFF9CAB9F));
  static Clr borderColor = const ColorModel(lightColor: Color(0xFFE7E4D8),darkColor: Color(0xFF1E3527));
  static Clr textSecondaryDark = const ColorModel(lightColor: Color(0xFF6E7A6F),darkColor: Color(0xFF9CAB9F));

  //Error — muteRed (كتم الأذان/الأخطاء)
  static Clr errorColor = const ColorModel(lightColor: Color(0xFFC0654A),darkColor: Color(0xFFC0654A));

  //FloatingAction
  static Clr floatingActionButtonColor =  ColorModel(lightColor:primaryColor.lightColor,darkColor: primaryColor.darkColor);

  //App bar icons
  static Clr appBarIconsColor =  const ColorModel(lightColor:Colors.white,darkColor: Color(0xFFE8EDE8));
  static Clr appBarTextColor =  const ColorModel(lightColor:Colors.white,darkColor: Color(0xFFE8EDE8));

  //Gray
  static Clr shadowColor =  const ColorModel(lightColor: Color(0xFFB9B7AB),darkColor: Color(0xFF000000));
  static Clr highlightColor =  const ColorModel(lightColor: Color(0xFFEDF1E9),darkColor: Color(0xFF1E3527));
  static Clr grayScaleLiteColor = const ColorModel(lightColor: Color(0xFFE7E4D8),darkColor: Color(0xFF1E3527));

  //divider
  static Clr dividerColor =  const ColorModel(lightColor: Color(0xFFE7E4D8),darkColor: Color(0xFF1E3527));


  //App
  static Clr scaffoldBackgroundColor =  const ColorModel(lightColor: Color(0xFFF3F2ED),darkColor: Color(0xFF0B1710));
  static Clr statusBarColor =   ColorModel(lightColor: scaffoldBackgroundColor.lightColor,darkColor:  scaffoldBackgroundColor.darkColor);
  // كروت الرئيسية وصف الصلوات — الكريمي القديم في الفاتح
  static Clr cardColor =  const ColorModel(lightColor: Color(0xFFEAE9D9),darkColor: Color(0xFF17301F));
  static Clr dialogColor =  const ColorModel(lightColor: Color(0xFFFFFDF7),darkColor: Color(0xFF12241A));
  // card: السطح المرتفع الفاتح (صفوف شاشة المواقيت...)
  static Clr backgroundColor =  const ColorModel(lightColor: Color(0xFFFFFDF7),darkColor: Color(0xFF12241A));

  static Clr disabledColor =  const ColorModel(lightColor: Color(0xFFB3B8AC),darkColor: Color(0xFF3A4A3F));
  static Clr unselectedWidgetColor =  const ColorModel(lightColor: Color(0xFF8A9689),darkColor: Color(0xFF6E7A6F));
  static Clr hoverColor =  const ColorModel(lightColor: Color(0xFFEDF1E9),darkColor: Color(0xFF17301F));
  static Clr grayScaleColor =  const ColorModel(lightColor: Color(0xFFE7E4D8),darkColor: Color(0xFF24382B));

  static Clr shimmer1 = const ColorModel(lightColor: Color(0xFFE7E4D8),darkColor: Color(0xFF17301F));
  static Clr shimmer2 = const ColorModel(lightColor: Color(0xFFF3F2ED),darkColor: Color(0xFF1E3527));



  //app
  static Clr badgeColor = const ColorModel(lightColor: Color(0xFFA8801E),darkColor: Color(0xFFE9C46A));

}


extension ColorTheme on ColorModel {
  Color get themeColor {
    if (appContext != null &&
        Provider.of<ThemeHelper>(appContext!, listen: false).themeData == darkTheme) {
      return darkColor;
    }
    return lightColor;
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

  Color getColor(bool isDark) =>isDark?_darkColor: _lightColor;

}

LinearGradient getMainColorGradient() =>   LinearGradient(begin: Alignment.topRight, end: Alignment.topLeft , colors: [AppColor.primaryColor.themeColor, AppColor.primaryColor.themeColor,]);
LinearGradient getButtonGradient() =>   LinearGradient(begin: Alignment.topRight, end: Alignment.topLeft , colors: [AppColor.primaryColor.themeColor, AppColor.primaryColor.themeColor,]);
LinearGradient getBackgroundGradient(bool isDarkMode) => LinearGradient(stops: const [0.0,0.3], colors: isDarkMode?[AppColor.primaryColorDark.darkColor, AppColor.scaffoldBackgroundColor.darkColor]:[AppColor.primaryColorLight.lightColor, AppColor.scaffoldBackgroundColor.lightColor], begin: Alignment.topCenter, end: Alignment.bottomCenter,);
LinearGradient getImageGradient() =>const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromRGBO(0, 0, 0, 0.0), Color.fromRGBO(0, 0, 0, 1.0),],);
