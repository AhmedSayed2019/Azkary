import 'package:azkark/widgets/dialog/base/awesome/awesome_dialog.dart';
import 'package:flutter/material.dart';

///Header of the [AwesomeDialog]
///
/// كانت رسوم rive تُحمَّل من packages/awesome_dialog/assets/rive/*.riv
/// وهي غير موجودة في التطبيق (ولا الحزمة نفسها)، فكانت الرأس معطوبة
/// وتجرّ مكتبة rive الأصلية (~10MB) بلا فائدة. أيقونة ثابتة بدلها.
class AwesomeDialogHeader extends StatelessWidget {
  ///Constructor of the [AwesomeDialogHeader]
  const AwesomeDialogHeader({
    Key? key,
    required this.dialogType,
    required this.loop,
  }) : super(key: key);

  ///Defines the type of [AwesomeDialogHeader]
  final DialogType dialogType;

  ///Defines if the animation loops or not (لم يعد مستخدمًا)
  final bool loop;

  @override
  Widget build(BuildContext context) {
    final (IconData, Color)? spec = switch (dialogType) {
      DialogType.INFO || DialogType.info => (Icons.info_rounded, Colors.blue),
      DialogType.INFO_REVERSED ||
      DialogType.infoReverse =>
        (Icons.info_rounded, Colors.blueGrey),
      DialogType.question => (Icons.help_rounded, Colors.teal),
      DialogType.WARNING ||
      DialogType.warning =>
        (Icons.warning_rounded, Colors.orange),
      DialogType.ERROR || DialogType.error => (Icons.error_rounded, Colors.red),
      DialogType.SUCCES ||
      DialogType.success =>
        (Icons.check_circle_rounded, Colors.green),
      DialogType.NO_HEADER || DialogType.noHeader => null,
    };
    if (spec == null) return const SizedBox.shrink();
    return FittedBox(child: Icon(spec.$1, color: spec.$2, size: 96));
  }
}
