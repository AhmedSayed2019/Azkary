import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Color getColoredContainerColor(BuildContext context){
  return Theme.of(context).brightness == Brightness.light ? onLightCardColor : onDarkCardColor;
}
final onDarkCardColor = Colors.white.withOpacity(0.15);
final onLightCardColor = Colors.blueGrey.withOpacity(0.15);


String getAdhanName(int i, {bool isJummah = false}) {
  return [
    "adhan_fajr",
    "adhan_sunrise",
    if (isJummah) '${tr("adhan_jummah")} - ${tr("adhan_dhuhr")}' else tr('adhan_dhuhr'),
    "adhan_asr",
    "adhan_magrib",
    "adhan_isha",
    "adhan_midnight",
    "adhan_third_night"
  ][i];
}