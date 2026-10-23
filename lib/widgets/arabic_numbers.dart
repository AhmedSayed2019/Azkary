library arabic_numbers;

import 'package:azkark/core/localization/app_locales.dart';

/// هل نعرض الأرقام بالصيغة العربية الهندية (٠١٢…)؟
///
/// في الواجهة العربية فقط. الإنجليزية والفرنسية والألمانية تعرض الأرقام
/// اللاتينية، وإلا ظهرت المواقيت والعدّاد بحروف لا يقرؤها المستخدم.
bool get _useArabicDigits => AppLang.isArabic;

class _ArabicNumbers {
  static String convert(Object value) {
    assert(
    value is int || value is String,
    "The value object must be of type 'int' or 'String'.",
    );

    if (value is int) {
      return _toArabicNumbers(value.toString());
    } else {
      return _toArabicNumbers(value as String);
    }
  }

  static String _toArabicNumbers(String value) {
    if (!_useArabicDigits) return value;
    return value
        .replaceAll('0', '٠')
        .replaceAll('1', '١')
        .replaceAll('2', '٢')
        .replaceAll('3', '٣')
        .replaceAll('4', '٤')
        .replaceAll('5', '٥')
        .replaceAll('6', '٦')
        .replaceAll('7', '٧')
        .replaceAll('8', '٨')
        .replaceAll('9', '٩');
  }
}

extension IntExtensions on int {
  /// Converts English numbers to the Arabic numbers format
  ///
  ///
  /// Example:
  /// ```dart
  /// final arabicNumbers = 0123456789.toArabicNumbers;
  /// // result: ٠١٢٣٤٥٦٧٨٩
  /// ```
  String get toArabicNumbers {
    return _ArabicNumbers.convert(this);
  }
}

extension StringExtensions on String {
  /// Converts English numbers to the Arabic numbers format
  ///
  ///
  /// Example:
  /// ```dart
  /// final arabicNumbers = '0123456789'.toArabicNumbers;
  /// // result: ٠١٢٣٤٥٦٧٨٩
  /// ```
  String get toArabicNumbers {
    return _ArabicNumbers.convert(this);
  }
}