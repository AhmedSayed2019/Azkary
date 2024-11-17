import 'package:flutter/material.dart';

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
// scaffold background
// const scaffoldBackgroundColor = Colors.blue;
///appColors

const bornColor = Color(0xff0F62A5);
const bornColorHighLite = Color(0x22679ECB);

const marriageColor = primaryColor;
const marriageColorHighLite = Color(0x222F604A);



const scaffoldBackgroundColor = Color(0xffd8e3d8);
const cardColor = Color(0xFF05480C);
const scaffoldBackgroundColorDark = Color(0xFF262424);

// Highlight
// const highlightColor =  Color(0xFFE4E6E8);
const highlightColor = Color(0xFFF5F5F5);
const highlightColorDark = Colors.black;

// statusBar
// const statusBarColor = Color(0xffffffff);
const statusBarColor = primaryColor;
const statusBarColorDark = primaryColorDark;

// appBar
const appBarColor = statusBarColor;
const appBarColorDark = statusBarColorDark;

// fab
const floatingActionButtonColor = primaryColorLight;
const floatingActionButtonColorDark = statusBarColorDark;

// accent
const accentColor = primaryColor;
const accentColorDark = Color(0xff17c063);

// app
const appRateActive = Colors.amber;
const appRateInActive = Colors.grey;
const appColorDark = Colors.amber;
const appColor = Color(0xFFFA8072);

// error

const errorColor =  Color(0xffc52828);
const errorColorDark = Colors.redAccent;

// primary color
const primaryColor =  Color(0xFF05480C);
const primaryColorDark =Color(0xff947c4a );
const primaryColorLight =Color(0xffc1c9c1);
const unselectedWidgetColor = Color(0xDD000000);


// app bar icons
const appBarIconsColor = Colors.black87;
const appBarIconsColorDark = Colors.white;

// app bar text color
const appBarTextColor = appBarIconsColorDark;
const appBarTextColorDark = appBarIconsColor;

//divider
const dividerColor = Colors.grey;
const dividerColorDark = Color(0xff464646);

const shimmerColor = Color(0xFFE0E0E0);


// primary text
const textPrimary =  Colors.black;
const textPrimaryDark = Colors.white;
const textSecondary = hintColor;
const textSecondaryDark = Color(0xffB0B0B0);


const unSelectColor = Color(0x97e3e2e2);

// bottom navigation icons
const navIconSelected = Colors.white;
const navIconSelectedDark = Color(0x97ffffff);

const navIconUnselected = Colors.grey;
const navIconUnselectedDark = Colors.grey;

// button
const colorButton = Color(0xff0F62A5);
const colorButtonDark = Colors.redAccent;

// text field
const active = Colors.black;
const activeDark = Colors.white;

const borderColor = Colors.grey;

// cursor
const cursor = Colors.grey;
const cursorDark = Colors.grey;

// textSelectionHandleColor
const textSelectionHandle = Colors.grey;
const textSelectionHandleDark = Colors.grey;

const textSelection = Colors.grey;
const textSelectionDark = Colors.grey;

/*-----------------------------Other Colors----------------------------------*/
Color get backgroundColor => const Color(0xFFFFFFFF);
Color? get backgroundLiteColor =>  Colors.grey[200];
// gray scale
const grayScaleColor = Color(0xFFE2E2E2);

const grayScaleLiteColor = Color(0xFFE2E2E2);
const rateBackground = Color(0xFF333333);


const highLiteColor = Color(0xFFADADAD);
const hoverColor = Color(0xFFE7EBEB);
// const hoverColor = Color(0xFFE7EBEB);
const hintColor = Color(0xFF717784);
// const hintColor = Color(0xFFADADAD);
// const hintColor = Color(0xFF777777);



const secondHighLiteColor = Color(0xFFF6EEC9);
final colorBgPositiveMessage = LinearGradient(
  colors: [Colors.green.shade800, Colors.greenAccent.shade700],
  stops:const [0.6, 1],
);
final colorBgNeutralMessage = LinearGradient(
  colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade500],
  stops:const [0.6, 1],
);
final colorBgNegativeMessage = LinearGradient(
  colors: [Colors.red.shade800, Colors.redAccent.shade700],
  stops:const [0.6, 1],
);
// final colorBlue = Color(0xff009ACE);
const colorGreen = Colors.green;
final colorBlueBackground = const Color(0xff0F62A5).withOpacity(.2);


LinearGradient getMainColorGradient() {
  return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      tileMode: TileMode.clamp,
      stops: [0.3, 0.9],
      colors: [
        Color(0xff199A8E),
        Color(0xff292871),
      ]);
}