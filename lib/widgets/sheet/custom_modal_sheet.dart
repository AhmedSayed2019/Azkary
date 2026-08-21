import 'package:flutter/material.dart';

/// فاتح الشيتات الموحّد.
///
/// `isScrollControlled: true` ضروري: بدونه يحدّ فلاتر الشيت بنصف ارتفاع
/// الشاشة ويطفح المحتوى الأطول («BOTTOM OVERFLOWED BY … PIXELS»).
/// الارتفاع الفعلي يحكمه [BaseSheetShell.maxHeightFactor].
class CustomModalSheet {
  const CustomModalSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (sheetContext) => Padding(
        // يرفع الشيت فوق لوحة المفاتيح إن فُتحت
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: child,
      ),
    );
  }
}
