import 'package:flutter/material.dart';

class BasmalaWidget extends StatelessWidget {
  final int _suraIndex;
  const BasmalaWidget({
    required int suraIndex,
  }) : _suraIndex = suraIndex;

  @override
  Widget build(BuildContext context) {
    if ( (_suraIndex == 0) || (_suraIndex == 8)) {
      return const Text('');
    } else {
      return Stack(children: [
        const Center(
          child: Text(
            'بسم الله الرحمن الرحيم',
            style: TextStyle(fontFamily: 'me_quran', fontSize: 30),
            textDirection: TextDirection.rtl,
          ),
        ),
      ]);
    }
  }


}
