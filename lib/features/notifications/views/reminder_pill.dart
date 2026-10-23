// هيئة الحبّة العائمة — مرسومةً وحدها بلا حركة ولا مؤقّت.
//
// فُصلت عن [ReminderOverlay] ليرسمها الطرفان: عزلةُ النافذة حين يحين
// التذكير، وشاشةُ التنبيهات في قائمة اختيار اللون. المعاينة التي تُرسم
// بشيفرة أخرى تكذب على المستخدم أول ما يتغيّر أحد الطرفين.
//
// بأبعاد مطلقة لا `.w`/`.r`: عزلة النافذة محرّك فلاتر مستقل بلا تهيئة
// الاستجابة التي يعتمدها التطبيق، وقياسٌ يقرأ حالةً غير مهيّأة يسقط هناك
// لا هنا — حيث لا أحد يرى الاستثناء.

import 'package:azkark/features/notifications/logic/overlay_palette.dart';
import 'package:flutter/material.dart';

class ReminderPill extends StatelessWidget {
  const ReminderPill({
    super.key,
    required this.text,
    required this.color,
    this.title = '',
    this.onTap,
  });

  final String text;
  final String title;
  final OverlayPillColor color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = color.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: kOverlayPillSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent, width: 1.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: kOverlayPillSurface,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Flexible لا Expanded: الحبّة تتقولب على النص القصير، ولا
            // تتمدد إلا حين يطول فيبلغ حدّ العرض.
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                // النافذة بارتفاع ثابت بالبكسل (لا تتمدد)، ومتون الأحاديث
                // تتجاوز ما تسعه حبّة من سطرين. القصّ بثلاث نقاط أوضح من
                // تجاوزٍ يقصّه النظام في منتصف السطر.
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
