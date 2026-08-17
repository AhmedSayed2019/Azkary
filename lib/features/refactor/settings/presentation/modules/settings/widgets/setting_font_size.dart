import 'package:azkark/core/res/resources.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/widgets/slider_font_size/slider_font_size.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `SettingFontSize` widget. `fontSize`/`onChangedEnd`
/// are now supplied by the parent (backed by `SettingsViewModel`) instead of
/// each widget reading `SettingsProvider` directly.
class SettingFontSize extends StatefulWidget {
  const SettingFontSize({
    super.key,
    required this.borderRadius,
    required this.fontSize,
    required this.onChangedEnd,
  });

  final BorderRadius borderRadius;
  final double fontSize;
  final ValueChanged<double> onChangedEnd;

  @override
  State<SettingFontSize> createState() => _SettingFontSizeState();
}

class _SettingFontSizeState extends State<SettingFontSize> {
  late double _fontSize;
  bool _showSlider = false;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.fontSize;
  }

  @override
  void didUpdateWidget(covariant SettingFontSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fontSize != widget.fontSize) {
      _fontSize = widget.fontSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: teal[200],
      onTap: () {
        setState(() {
          _showSlider = !_showSlider;
        });
      },
      borderRadius: widget.borderRadius,
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
                    style: const TextStyle().semiBoldStyle().primaryTextColor(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 10.0, right: 8.0),
                  child: Text(
                    '$_fontSize',
                    style: const TextStyle().semiBoldStyle().primaryTextColor(),
                  ),
                ),
              ],
            ),
            if (_showSlider)
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: SliderFontSize(
                  fontSize: _fontSize,
                  min: 14,
                  max: 30,
                  overlayColor: Colors.transparent,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                  onChangedEnd: widget.onChangedEnd,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
