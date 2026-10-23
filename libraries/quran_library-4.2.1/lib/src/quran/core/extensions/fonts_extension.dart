part of '/quran.dart';

/// Extension to handle font-related operations for the QuranCtrl class.
///
/// الخطوط تُحمّل ديناميكيًا عبر [QuranFontsService] من ملفات `.ttf.gz`
/// مضغوطة في الـ assets.
extension FontsExtension on QuranCtrl {
  /// يُرجع اسم عائلة الخط للصفحة المحددة (page1 .. page604).
  /// في الوضع الداكن مع التجويد يُرجع النسخة الداكنة (page1d .. page604d).
  ///
  /// يُسجَّل لكل صفحة المتغير المطلوب فقط؛ إن لم يكن هذا المتغير مسجّلًا بعد
  /// (تغيّر الوضع الداكن/التجويد) يُجدول تسجيله ثم تُعاد بناء الصفحة.
  String getFontPath(int pageIndex, {bool isDark = false}) {
    final withTajweed = state.isTajweedEnabled.value;
    final suffix =
        QuranFontsService.variantSuffix(isDark: isDark, tajweed: withTajweed);
    QuranFontsService.noteVariantUsed(pageIndex + 1, suffix, isDark: isDark);
    return 'page${pageIndex + 1}$suffix';
  }

  /// يُرجع اسم عائلة الخط الأحمر لكلمات الخلاف (القراءات العشر).
  String getRedFontPath(int pageIndex) {
    QuranFontsService.noteVariantUsed(pageIndex + 1, 'nr');
    return QuranFontsService.getRedFontFamily(pageIndex);
  }
}
