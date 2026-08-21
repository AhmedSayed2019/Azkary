import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';

/// خط فاصل رفيع أسفل رأس الشيت.
class CustomSheetDivider extends StatelessWidget {
  const CustomSheetDivider({super.key, this.height = 1, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: color ?? AppColor.borderColor.themeColor,
    );
  }
}
