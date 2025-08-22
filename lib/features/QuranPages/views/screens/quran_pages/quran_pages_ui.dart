import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// Example model you already have
class ZekrModel {
  final int id;
  final String text;  // Arabic text of verse/zekr
  ZekrModel({required this.id, required this.text});

  factory ZekrModel.fromMap(Map<String, dynamic> m) =>
      ZekrModel(id: m['id'] as int, text: (m['text'] as String?) ?? '');
}

/// Renders *all* content on one screen by shrinking font as needed.
class QuranPageNoScroll extends StatelessWidget {
  final List<ZekrModel> verses;
  final double initialFontSize;   // starting point (will shrink if needed)
  final double minFontSize;       // stop shrinking below this

  const QuranPageNoScroll({
    super.key,
    required this.verses,
    this.initialFontSize = 22,
    this.minFontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    // Build a rich text of all verses. You can add numbers / separators here.
    final spans = <InlineSpan>[];
    for (int i = 0; i < verses.length; i++) {
      final v = verses[i];
      // Example: add verse number in small circle-like brackets
      spans.add(TextSpan(
        text: v.text.trim(),
        style: const TextStyle(height: 1.6), // line height for Arabic
      ));
      if (i != verses.length - 1) {
        spans.add(const TextSpan(text: '  ')); // small spacing between ayat
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl, // Arabic RTL
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight, // fixed to full screen parent
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AutoSizeText.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: initialFontSize,
                  fontWeight: FontWeight.w500,
                  // If you use a Quran/Arabic font, set it here:
                  // fontFamily: 'KFGQPC Uthmanic Script',
                ),
                children: spans,
              ),
              // Make sure the whole thing fits vertically without scroll:
              maxLines: 1000,          // effectively "no limit"
              minFontSize: minFontSize, // will shrink down to this if needed
              stepGranularity: 0.5,     // smoother shrinking
              overflowReplacement: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  // Fallback if something goes wrong
                  verses.map((e) => e.text).join(' '),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
