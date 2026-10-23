// ترجمة محتوى قاعدة بيانات الأذكار.
//
// لماذا ملفات أصول لا أعمدة في القاعدة؟ لأن `database.db` تُنسخ إلى
// تخزين التطبيق عند أول تشغيل ثم يكتب فيها المستخدم مفضّلاته. إضافة
// أعمدة تعني ترحيلًا (migration) لكل تثبيت قائم، بينما ملف أصول
// يُحدَّث مع التطبيق ولا يمسّ بيانات المستخدم إطلاقًا.
//
// العربية هي المصدر: أي مفتاح غير مترجم يرجع بنصه العربي كما هو، فلا
// يظهر فراغ ولا اسم مفتاح.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class DbTranslations {
  DbTranslations._();

  /// اللغات التي لدينا ملف ترجمة لها. العربية ليست منها — هي الأصل.
  static const Set<String> _translated = {'en', 'fr', 'de'};

  static String _lang = 'ar';
  static Map<String, Map<String, String>> _tables = const {};

  /// تُستدعى عند الإقلاع وعند كل تغيير للغة.
  static Future<void> load(String languageCode) async {
    if (_lang == languageCode) return;
    _lang = languageCode;

    if (!_translated.contains(languageCode)) {
      _tables = const {};
      return;
    }
    try {
      final raw = await rootBundle
          .loadString('assets/db_translations/$languageCode.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _tables = decoded.map(
        (table, rows) => MapEntry(
          table,
          (rows as Map<String, dynamic>)
              .map((id, value) => MapEntry(id, value as String)),
        ),
      );
    } catch (e) {
      // الترجمة تحسينية — الفشل يعني بقاء العربية لا تعطّل الشاشة
      debugPrint('DbTranslations.load($languageCode) failed: $e');
      _tables = const {};
    }
  }

  static String _get(String table, int id, String fallback) {
    final value = _tables[table]?['$id'];
    return (value == null || value.isEmpty) ? fallback : value;
  }

  static String section(int id, String fallback) =>
      _get('sections', id, fallback);

  static String category(int id, String fallback) =>
      _get('categories', id, fallback);

  static String tasbih(int id, String fallback) =>
      _get('tasbih', id, fallback);

  static String asmaName(int id, String fallback) =>
      _get('asmaallah_name', id, fallback);

  static String asmaDescription(int id, String fallback) =>
      _get('asmaallah_desc', id, fallback);

  static String zekr(int id, String fallback) => _get('azkar', id, fallback);

  /// معنى الذكر بلغة الواجهة، أو null إن لم يُترجم بعد.
  ///
  /// الذكر لا يُستبدل بالترجمة أبدًا: النص العربي هو ما يُتلى، والترجمة
  /// تُعرض تحته لبيان المعنى. لذلك نحتاج التمييز بين "غير مترجم" و"مترجم".
  static String? zekrMeaning(int id) {
    final value = _tables['azkar']?['$id'];
    return (value == null || value.isEmpty) ? null : value;
  }

  /// نص عدد التكرار ("ثلاث مرات"…) — مفتاحه النص العربي نفسه لا المعرّف،
  /// لأنه عمود حرّ في جدول الأذكار تتكرر قيمه.
  static String counterText(String arabic) {
    final value = _tables['counter_text']?[arabic];
    return (value == null || value.isEmpty) ? arabic : value;
  }

  /// هل الواجهة بلغة غير العربية أصلًا؟
  static bool get isTranslating => _translated.contains(_lang);
}
