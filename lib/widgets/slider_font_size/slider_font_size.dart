import 'package:azkark/core/res/color.dart';
import 'package:flutter/material.dart';

import '../../util/colors.dart';

class SliderFontSize extends StatelessWidget {
  final double _fontSize, _min, _max;
  final double?  _divisions;
  final ValueChanged<double>? _onChanged, _onChangedEnd;
  final Color? _overlayColor;
  const SliderFontSize({super.key,
    required double fontSize,
    required double min,
    required double max,
     double? divisions,
     ValueChanged<double>? onChanged,
     ValueChanged<double>? onChangedEnd,
     Color? overlayColor,
  })  : _fontSize = fontSize,
        _min = min,
        _max = max,
        _divisions = divisions,
        _onChanged = onChanged,
        _onChangedEnd = onChangedEnd,
        _overlayColor = overlayColor;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.only(right: 5.0, left: 8.0),
      width: size.width * 0.8,
      height: size.height * 0.1,
      decoration: BoxDecoration(
        color: _overlayColor ?? Theme.of(context).primaryColor.withAlpha(175),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: size.width * 0.7,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Theme.of(context).primaryColorLight.withAlpha(50),
                trackShape: const RoundedRectSliderTrackShape(),
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                thumbColor: Theme.of(context).primaryColor,
                overlayColor: Theme.of(context).primaryColor!.withAlpha(15),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                tickMarkShape: const RoundSliderTickMarkShape(),
                activeTickMarkColor: Theme.of(context).primaryColor,
                inactiveTickMarkColor: Theme.of(context).primaryColorLight.withAlpha(50),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: Theme.of(context).primaryColor,
                valueIndicatorTextStyle: TextStyle(color: AppColor.textColorLite.themeColor, fontSize: _fontSize),
              ),
              child: Slider(
                min: 14,
                max: 30,
                divisions: 8,
                label: '$_fontSize',
                value: _fontSize,
                onChanged: _onChanged,
                onChangeEnd: _onChangedEnd,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
