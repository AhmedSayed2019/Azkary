import 'package:azkark/data/models/dua/dua_details.dart';
import 'package:flutter/services.dart';

void copyDuaToClipBoard(DuaDetails details) {
  final translation = details.translation;
  final transliteration = details.transliteration;
  final notes = details.notes;
  final reference = details.reference;

  Clipboard.setData(
    ClipboardData(
      text:
          "${details.arabic} ${translation != null ? '\n\n$translation' : ''} ${transliteration != null ? '\n\n$transliteration' : ''} ${notes != '' ? "\n\n'$notes'" : ''}\n\n'$reference'",
    ),
  );
}
