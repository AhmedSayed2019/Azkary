import 'dart:math';

import 'package:azkark/core/res/resources.dart';
import 'package:azkark/util/colors.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `SettingFontType` widget. `fontType`/`onChanged` are
/// now supplied by the parent (backed by `SettingsViewModel`) instead of
/// reading/writing `SettingsProvider` directly.
class SettingFontType extends StatefulWidget {
  const SettingFontType({
    super.key,
    required this.borderRadius,
    required this.fontType,
    required this.onChanged,
  });

  final BorderRadius borderRadius;
  final int fontType;
  final ValueChanged<int> onChanged;

  @override
  State<SettingFontType> createState() => _SettingFontTypeState();
}

class _SettingFontTypeState extends State<SettingFontType>
    with SingleTickerProviderStateMixin {
  bool _showBoxFonts = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation, _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _heightAnimation =
        Tween<double>(begin: 0, end: 300).animate(_animationController);

    _arrowAnimation = Tween(begin: 0.0, end: pi).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildTitle(),
        _buildBodyButton(size),
      ],
    );
  }

  Widget _buildTitle() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: teal[200],
      borderRadius: widget.borderRadius,
      onTap: () {
        setState(() {
          _showBoxFonts = !_showBoxFonts;
          _showBoxFonts
              ? _animationController.forward()
              : _animationController.reverse();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'نوع الخط',
              style: const TextStyle().semiBoldStyle().primaryTextColor(),
            ),
            AnimatedBuilder(
                animation: _animationController,
                builder: (context, widget) {
                  return Transform.rotate(
                    angle: _arrowAnimation.value,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: teal[700],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyButton(Size size) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, widget) {
          return Container(
            height: _heightAnimation.value,
            margin: const EdgeInsets.all(10),
            foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: teal[600]!)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildPreviewBox(size),
                  _buildFontsBox(size),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildPreviewBox(Size size) {
    return Container(
      width: size.width,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Center(
        child: Text(
          'بسم الله الرَّحْمَنِ الرَّحِيمِ',
          style: const TextStyle()
              .semiBoldStyle()
              .primaryTextColor()
              .customFontFamily(widget.fontType.toString()),
        ),
      ),
    );
  }

  Widget _buildFontsBox(Size size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildFontContainer('الخط الإفتراضي', '0', size),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildFontContainer('الخط ١', '1', size),
                _buildFontContainer('الخط ٢', '2', size),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildFontContainer('الخط ٣', '3', size),
                _buildFontContainer('الخط ٤', '4', size),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildFontContainer('الخط ٥', '5', size),
                _buildFontContainer('الخط ٦', '6', size),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildFontContainer('الخط ٧', '7', size),
                _buildFontContainer('الخط ٨', '8', size),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontContainer(String name, String font, Size size) {
    final isSelected = font == widget.fontType.toString();
    return InkWell(
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      onTap: () => widget.onChanged(int.parse(font)),
      child: Container(
        height: 35,
        width: font == '0' ? null : size.width * 0.3,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? teal[500] : gray20,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                name,
                style: const TextStyle().semiBoldStyle().customColor(
                    isSelected
                        ? AppColor.textColor.themeColor
                        : AppColor.primaryColor.themeColor).customFontFamily(font),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.check_circle_outline,
              color: isSelected ? Colors.white : gray20,
            ),
          ],
        ),
      ),
    );
  }
}
