import 'package:azkark/core/res/color.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData appTheme(BuildContext context) {
    return ThemeData(
      fontFamily: '0',
      primarySwatch: teal,
      primaryColor: teal,
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
        toolbarTextStyle: const TextStyle(color: appBarIconsColorDark),

            color: teal,
            iconTheme: const IconThemeData(
              color: appBarIconsColorDark,
            ), // brightness: Brightness.dark,
          ),
    );
  }
}


//import 'package:azkark/core/res/color.dart';
// import 'package:flutter/material.dart';
// import 'colors.dart';
//
// class AppTheme {
//   static ThemeData appTheme(BuildContext context) {
//     return ThemeData(
//       fontFamily: '0',
//       sliderTheme: SliderThemeData(
//           thumbColor: Colors.red,
//           activeTrackColor: Colors.white,
//           activeTickMarkColor: primaryColor,
//           disabledSecondaryActiveTrackColor:primaryColor ,
//           valueIndicatorColor: primaryColor,
//           valueIndicatorStrokeColor: primaryColor,
//           inactiveTrackColor: Colors.grey,
//           trackShape: RectangularSliderTrackShape(),
//           trackHeight: 4.0,
//           thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
//           overlayColor: Colors.grey,
//           overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
//       ),
//       primarySwatch: teal,
//       primaryColor: teal,
//       useMaterial3: false,
//       scaffoldBackgroundColor: Colors.transparent,
//       appBarTheme: Theme.of(context).appBarTheme.copyWith(
//         toolbarTextStyle: const TextStyle(color: appBarIconsColorDark),
//
//             color: teal,
//             iconTheme: const IconThemeData(
//               color: appBarIconsColorDark,
//             ), // brightness: Brightness.dark,
//           ),
//     );
//   }
// }