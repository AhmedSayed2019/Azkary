import 'package:flutter/material.dart';

/// كانت ترسم صورة 1500×1500 (background.png) تحت Scaffold لونه معتم في كل
/// الشاشات التي تستدعيها، فلا تظهر أبدًا — ومع ذلك تُفكّ وتُرسم مع كل
/// فتح لشاشة وتحجز ~9MB في الذاكرة. تبقى الفئة لأن الشاشات تستدعيها.
class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
