import 'dart:math' show pi;

import 'package:azkark/features/refactor/compass/domain/entity/qibla_direction_entity.dart';
import 'package:azkark/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The rotating compass dial + fixed Kaaba icon. Extracted from the legacy
/// `QiblahCompassWidget` build method into its own stateless widget.
class QiblaDial extends StatelessWidget {
  const QiblaDial({super.key, required this.direction});

  final QiblaDirectionEntity direction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? Colors.yellow : Theme.of(context).primaryColor;
    final angle = direction.qiblah * (pi / 180) * -1;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.rotate(
          angle: angle,
          child: SvgPicture.asset(Assets.campass5, colorFilter: ColorFilter.mode(tint, BlendMode.srcIn)),
        ),
        SvgPicture.asset(Assets.campass4),
        SvgPicture.asset(Assets.campass3, colorFilter: ColorFilter.mode(tint, BlendMode.srcIn)),
      ],
    );
  }
}
