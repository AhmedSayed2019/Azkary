// اللغات المدعومة ومُبدّلها.
//
// العربية أولًا: هي لغة المحتوى الأصلية واحتياط easy_localization حين
// ينقص مفتاح من ملف لغة أخرى — فلا يظهر اسم المفتاح خامًا للمستخدم.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// ترتيبها هو ترتيب ظهورها في شاشة اختيار اللغة.
const List<Locale> kSupportedLocales = <Locale>[
  Locale('ar'),
  Locale('en'),
  Locale('fr'),
  Locale('de'),
];

/// اسم كل لغة بلغتها هي — لا بلغة الواجهة الحالية: المستخدم الذي فتح
/// التطبيق بلغة لا يقرؤها يحتاج أن يتعرّف على لغته في القائمة.
const Map<String, String> kLocaleNames = <String, String>{
  'ar': 'العربية',
  'en': 'English',
  'fr': 'Français',
  'de': 'Deutsch',
};

extension LocaleX on Locale {
  String get displayName => kLocaleNames[languageCode] ?? languageCode;

  /// العربية وحدها من اليمين لليسار بين لغاتنا الأربع.
  bool get isRtl => languageCode == 'ar';
}

/// يبدّل لغة التطبيق ويحفظها. easy_localization تتكفّل بالحفظ في
/// التخزين المحلي وإعادة بناء الشجرة.
Future<void> setAppLocale(BuildContext context, Locale locale) =>
    context.setLocale(locale);

/// لغة الواجهة الحالية في متغيّر ثابت.
///
/// easy_localization لا تكشف اللغة إلا عبر BuildContext، وبعض الشيفرة
/// (تحويل الأرقام مثلًا) تعمل بلا سياق. تُحدَّث من `MyApp.build` التي
/// تُعاد بناؤها عند كل تبديل لغة.
class AppLang {
  AppLang._();

  static String code = 'ar';

  static bool get isArabic => code == 'ar';
}
