import 'package:azkark/app.dart';
import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';

EdgeInsets kScreenPadding = EdgeInsets.all(kScreenPaddingNormal.r)/*.copyWith(top: 0)*/;
EdgeInsets kCardPadding = EdgeInsets.all(kScreenPaddingNormal.r);

// final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
final size = MediaQuery.of(appContext!).size;
final deviceHeight = size.height;
final deviceWidth = size.width;


const double kFormPaddingVertical = 12.0;
const double kFormPaddingHorizontal = 12.0;
const double kScreenPaddingNormal = 16.0;
const double kScreenPaddingLarge = 32.0;
const double kFormPaddingAllSmall = 4.0;
const double kFormPaddingAllNormal = 8.0;
const double kFormPaddingAllLarge = 12.0;
const double kLoadingIndicatorSize = 32.0;
const double kTextFieldIconSize = 24.0;
const double kTextFieldIconSizeLarge = 32.0;
const double kAppbarTextSize = 18.0;


///Radius
const double kCartRadius = 20.0;
const double kButtonRadius = 20.0;
const double kFormRadius = 10.0;

const double kFormRadiusSmall = 6.0;
// const double kFormRadius = 10.0;
const double kCardRadius = 14.0;
// const double kFormRadius = 32.0;
const double kFormRadiusNormal = 8.0;
const double kFormRadiusLarge = 16.0;
