import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import 'colors.dart';

String translate(BuildContext context, String key) {
  return AppLocalizations.of(context)!.translate(key);
}

bool isTextDirectionRTL(String text) {
  if (text.isEmpty) return true;
  return Bidi.detectRtlDirectionality(text);
}

void copyText(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      tr( 'done_copy'),
      style: TextStyle(
        color: teal[100],
        fontFamily: '0',
        fontSize: 14,
      ),
    ),
    backgroundColor: teal,
    duration: const Duration(milliseconds: 500),
  ));
}
