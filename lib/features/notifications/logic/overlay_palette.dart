// ألوان الحبّة العائمة — ما يختاره المستخدم من شاشة التنبيهات.
//
// ملفٌ مستقل لأن طرفيه في عزلتين: شاشة الإعدادات تكتب الاختيار،
// و[ReminderOverlay] في عزلة النافذة تقرؤه من الحمولة. لا حالة هنا ولا
// إضافات — أرقام فقط، فيصحّ استيرادها من الطرفين.
//
// اللون يخصّ الحدّ والنصّ لا الخلفية: الحبّة تعلو تطبيقًا مجهول اللون،
// فخلفية فاتحة ثابتة هي وحدها ما يضمن قراءة النص، ويبقى اللون علامةً
// يميّزها المستخدم من طرف عينه.

import 'package:flutter/material.dart';

/// خلفية الحبّة — واحدة لكل الألوان. أبيض دافئ لا ناصع: الناصع يقسو تحت
/// ضوء منخفض، وهذه الحبّة تظهر في الليل كما تظهر في النهار.
const Color kOverlayPillSurface = Color(0xFFFFFCF4);

/// اللون المعتمد حين لا اختيار محفوظًا — أخضر التطبيق نفسه.
const OverlayPillColor kDefaultOverlayPillColor = OverlayPillColor.green;

enum OverlayPillColor {
  green(0xFF0D4429),
  blue(0xFF1B4F8F),
  teal(0xFF0B6B63),
  purple(0xFF5B2E90),
  crimson(0xFFA61B3C),
  amber(0xFF8A5A00);

  const OverlayPillColor(this._argb);

  final int _argb;

  Color get color => Color(_argb);

  /// القيمة المحفوظة والمُرسلة في الحمولة. العدد لا الاسم: الحمولة تعبر
  /// إلى عزلة قد تكون من نسخة سابقة لا تعرف الاسم الجديد، والعدد يُرسم
  /// كما هو عندها.
  int get value => _argb;

  /// اللون المطابق للقيمة، والافتراضي لكل ما سواها — قيمةٌ من نسخة
  /// أحدث حذفنا لونها لا يجوز أن تُسقط النافذة.
  static OverlayPillColor fromValue(Object? raw) {
    final v = raw is int ? raw : int.tryParse('${raw ?? ''}');
    if (v == null) return kDefaultOverlayPillColor;
    for (final c in OverlayPillColor.values) {
      if (c._argb == v) return c;
    }
    return kDefaultOverlayPillColor;
  }
}
