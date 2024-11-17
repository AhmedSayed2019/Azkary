import 'package:azkark/util/colors.dart';
import 'package:azkark/widgets/arabic_numbers.dart';
import 'package:flutter/material.dart';

class ArabicSuraNumber extends StatelessWidget {
  final int _number;

  const ArabicSuraNumber({
    required int number,
  }) : _number = number;

  @override
  Widget build(BuildContext context) {
    return Text(
      "\uFD3F${(_number + 1).toString().toArabicNumbers}\uFD3E",
      style: TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
        fontFamily: '2',
        fontSize: 20,
        shadows: [
          Shadow(offset: Offset(0.5, 0.5), blurRadius: 1, color: teal)
        ]
      ),
    );
  }


}
