import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../util/colors.dart';

class ButtonFontSize extends StatelessWidget {
  final bool _showSider;
  final VoidCallback _onTap;

  const ButtonFontSize({
    required bool showSider,
    required VoidCallback onTap,
  })  : _showSider = showSider,
        _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'change_font_size'.tr(),
      padding: EdgeInsets.all(0.0),
      highlightColor: Colors.transparent,
      splashColor: teal[700],
      icon: Container(
        padding: EdgeInsets.only(top: 2.5, bottom: 2.5, left: 5.0, right: 5.0),
        decoration: BoxDecoration(
            color: _showSider ? teal[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: FaIcon(
          FontAwesomeIcons.font,
          color: _showSider ? teal[800] : teal[50],
          size: 20,
        ),
      ),
      onPressed: _onTap,
    );
  }


}
