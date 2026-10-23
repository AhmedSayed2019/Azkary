// شيت اختيار لغة التطبيق — يُفتح من الضبط ومن قائمة الرئيسية.

import 'package:azkark/core/localization/app_locales.dart';
import 'package:azkark/widgets/sheet/sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  /// يفتح الشيت ويعيد اللغة المختارة، أو null إن أُغلق دون اختيار.
  static Future<Locale?> show(BuildContext context) =>
      CustomModalSheet.show<Locale>(
        context: context,
        child: const LanguageSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final current = context.locale;

    return BaseSheetShell(
      title: 'language'.tr(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final locale in kSupportedLocales)
            CustomSheetRadioItem<String>(
              // اسم اللغة بلغتها هي — انظر [kLocaleNames]
              title: locale.displayName,
              value: locale.languageCode,
              groupValue: current.languageCode,
              onChanged: (_) async {
                Navigator.of(context).pop(locale);
                // setLocale تحفظ الاختيار وتعيد بناء الشجرة كلها
                await context.setLocale(locale);
              },
            ),
        ],
      ),
    );
  }
}
