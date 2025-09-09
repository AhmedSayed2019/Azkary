import 'package:azkark/core/res/resources.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/colors.dart';
import '../slider_font_size/slider_font_size.dart';

class SettingFontSize extends StatefulWidget {
  final BorderRadius _borderRadius;

  @override
  _SettingFontSizeState createState() => _SettingFontSizeState();

  const SettingFontSize({
    required BorderRadius borderRadius,
  }) : _borderRadius = borderRadius;
}

class _SettingFontSizeState extends State<SettingFontSize> {
 late double fontSize;
 late bool showSlider;

  @override
  void initState() {
    super.initState();

    fontSize = Provider.of<SettingsProvider>(context, listen: false).getsettingField('font_size');
    showSlider = false;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: teal[200],
      onTap: () {
        setState(() {
          showSlider = !showSlider;
        });
      },
      borderRadius: widget._borderRadius,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    'حجم الخط',
                      style: const TextStyle().semiBoldStyle().primaryTextColor()
                    // style: new TextStyle(
                    //   color: teal,
                    //   fontSize: 14,
                    // ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 10.0, right: 8.0),
                  child: Text(
                    '$fontSize',
                    style:    const TextStyle().semiBoldStyle().primaryTextColor()
                    // style: new TextStyle(
                    //   color: teal[600],
                    //   fontSize: 14,
                    // ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: SliderFontSize(
                fontSize: fontSize,
                min: 14,
                max: 30,
                overlayColor: Colors.transparent,

                onChanged: (value) {
                  setState(() {
                    fontSize = value;
                  });
                },
                onChangedEnd: (value) {
                  settingsProvider.updateSettings('font_size', value);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
