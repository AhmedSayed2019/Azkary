import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/QuranPages/widgets/bismallah.dart';
import 'package:azkark/features/QuranPages/widgets/header_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

/// Build a LongPressGestureRecognizer for a given item (e = verse/word),
/// i = item index inside the page, pageIndex = page number/index.
typedef LongPressFactory = LongPressGestureRecognizer Function({
required dynamic e,
required int i,
required int pageIndex,
});

// MAIN CHANGE: Added dynamicFontSize parameter to support responsive text sizing
List<InlineSpan> kGetSpans({
  required dynamic value,
  required var jsonData,
  required int index,
  required LongPressFactory initLongPressGesture,
  required var selectedSpan,
  required var highlightVerse,
  required var shouldHighlightText,
  required var bookmarks,
  double? dynamicFontSize, // NEW: Optional dynamic font size parameter
}) {
  List<InlineSpan> spans = [];
  
  for (var i = value["start"]; i <= value["end"]; i++) {
    // Header
    if (i == 1) {
      spans.add(WidgetSpan(child: HeaderWidget(e: value, jsonData: jsonData)));
      if (index != 187 && index != 1) {
        spans.add(WidgetSpan(child: Basmallah(index: getValue("quranPageolorsIndex"))));
      }
      if (index == 187) {
        spans.add(WidgetSpan(child: Container(height: 10.h)));
      }
    }

    // MAIN CHANGE: Calculate responsive font size
    double fontSize = dynamicFontSize ?? _getDefaultFontSize(index);
    
    // MAIN CHANGE: Calculate responsive line height based on font size
    double lineHeight = _calculateLineHeight(index, fontSize);

    // Verses
    spans.add(TextSpan(
      recognizer: initLongPressGesture(e: value, i: i, pageIndex: index),
      text: i == value["start"] 
          ? "${quran.getVerseQCF(value["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerseQCF(value["surah"], i).replaceAll(" ", "").substring(1)}" 
          : quran.getVerseQCF(value["surah"], i).replaceAll(' ', ''),
      style: TextStyle(
        color: bookmarks.where((element) => 
            element["suraNumber"] == value["surah"] && 
            element["verseNumber"] == i).isNotEmpty
            ? Color(int.parse("0x${bookmarks.where((element) => 
                element["suraNumber"] == value["surah"] && 
                element["verseNumber"] == i).first["color"]}"))
            : primaryColors[getValue("quranPageolorsIndex")],
        height: lineHeight, // CHANGED: Use calculated line height
        letterSpacing: 0.w,
        wordSpacing: 0,
        fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
        fontSize: fontSize, // CHANGED: Use calculated font size
        backgroundColor: shouldHighlightText
            ? quran.getVerse(value["surah"], i) == highlightVerse
                ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                : selectedSpan == " ${value["surah"]}$i"
                    ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                    : Colors.transparent
            : selectedSpan == " ${value["surah"]}$i"
                ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                : Colors.transparent,
      ),
      children: const <TextSpan>[],
    ));
  }
  return spans;
}

// MAIN CHANGE: Enhanced version with better responsive design
List<InlineSpan> kGetSpans1({
  required dynamic e,
  required int suraNumber,
  required var currentVersePlaying,
  required var jsonData,
  required int index,
  required LongPressFactory initLongPressGesture,
  required var selectedSpan,
  required var highlightVerse,
  required var shouldHighlightText,
  required var bookmarks,
  double? dynamicFontSize, // NEW: Optional dynamic font size parameter
}) {
  List<InlineSpan> spans = [];
  
  for (var i = e["start"]; i <= e["end"]; i++) {
    // Header
    if (i == 1) {
      spans.add(WidgetSpan(child: HeaderWidget(e: e, jsonData: jsonData)));
      if (index != 187 && index != 1) {
        spans.add(WidgetSpan(child: Basmallah(index: getValue("quranPageolorsIndex"))));
      }
      if (index == 187) {
        spans.add(WidgetSpan(child: Container(height: 10.h)));
      }
    }

    // MAIN CHANGE: Calculate responsive font size and line height
    double fontSize = dynamicFontSize ?? _getDefaultFontSize(index);
    double lineHeight = _calculateLineHeight(index, fontSize);

    // Verses
    spans.add(TextSpan(
      locale: const Locale("ar"),
      recognizer: initLongPressGesture(e: e, i: i, pageIndex: index),
      text: quran.getVerseQCF(e["surah"], i).replaceAll(' ', ''),
      style: TextStyle(
        color: primaryColors[getValue("quranPageolorsIndex")],
        height: lineHeight, // CHANGED: Use calculated line height
        letterSpacing: 0.w,
        fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
        fontSize: fontSize, // CHANGED: Use calculated font size
        backgroundColor: bookmarks
                .where((element) => 
                    element["suraNumber"] == e["surah"] && 
                    element["verseNumber"] == i)
                .isNotEmpty
            ? Color(int.parse("0x${bookmarks.where((element) => 
                element["suraNumber"] == e["surah"] && 
                element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
            : (i == currentVersePlaying["verseNumber"] && e["surah"] == suraNumber)
                ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.28)
                : shouldHighlightText
                    ? quran.getVerse(e["surah"], i) == highlightVerse
                        ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                        : selectedSpan == " ${e["surah"]}$i"
                            ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                            : Colors.transparent
                    : selectedSpan == " ${e["surah"]}$i"
                        ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                        : Colors.transparent,
      ),
      children: const [],
    ));
    
    // Bookmark icon handling
    if (bookmarks
        .where((element) =>
            element["suraNumber"] == e["surah"] &&
            element["verseNumber"] == i)
        .isNotEmpty) {
      spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(
            Icons.bookmark,
            color: Color(int.parse("0x${bookmarks.where((element) => 
                element["suraNumber"] == e["surah"] && 
                element["verseNumber"] == i).first["color"]}")),
            size: fontSize * 0.8, // CHANGED: Scale icon size with font size
          )));
    }
  }
  return spans;
}

// HELPER FUNCTIONS for responsive design

/// Get default font size based on page index
double _getDefaultFontSize(int index) {
  if (index == 1 || index == 2) {
    return 28.sp;
  } else if (index == 145 || index == 201) {
    return index == 532 || index == 533 ? 22.5.sp : 22.4.sp;
  } else {
    return 22.9.sp;
  }
}

/// Calculate line height based on page index and font size
double _calculateLineHeight(int index, double fontSize) {
  // Base line height ratio
  double baseRatio = (index == 1 || index == 2) ? 2.0 : 1.95;
  
  // Adjust line height based on font size to maintain good readability
  // Smaller fonts need relatively larger line heights
  double fontSizeRatio = fontSize / _getDefaultFontSize(index);
  double adjustedRatio = baseRatio * (1.0 + (1.0 - fontSizeRatio) * 0.1);
  
  return adjustedRatio.h;
}

/// Calculate optimal font size based on available space and content
double calculateOptimalFontSize({
  required double availableHeight,
  required double availableWidth,
  required int pageIndex,
  required int estimatedCharacterCount,
}) {
  // Base font size for the page
  double baseFontSize = _getDefaultFontSize(pageIndex);
  
  // Estimate how much space the text will take
  double estimatedTextHeight = estimatedCharacterCount * baseFontSize * 0.1; // Rough estimation
  
  // Calculate scale factor to fit content in available space
  double scaleFactor = availableHeight / estimatedTextHeight;
  
  // Apply scale factor but keep within reasonable bounds
  double optimalFontSize = (baseFontSize * scaleFactor).clamp(
    baseFontSize * 0.6, // Minimum 60% of original size
    baseFontSize * 1.2,  // Maximum 120% of original size
  );
  
  return optimalFontSize;
}

/// Get estimated character count for a page (you might want to implement this based on your data)
int getEstimatedCharacterCount(int pageIndex, var jsonData) {
  if (pageIndex <= 0 || pageIndex > jsonData.length) return 1000; // Default estimate
  
  int totalChars = 0;
  var pageData = jsonData[pageIndex - 1];
  
  for (var surahData in pageData) {
    for (var i = surahData["start"]; i <= surahData["end"]; i++) {
      totalChars += quran.getVerseQCF(surahData["surah"], i).length;
    }
  }
  
  return totalChars;
}

/// Create adaptive text spans that automatically adjust to screen size
List<InlineSpan> createAdaptiveTextSpans({
  required var pageData,
  required int pageIndex,
  required var jsonData,
  required LongPressFactory initLongPressGesture,
  required var selectedSpan,
  required var highlightVerse,
  required var shouldHighlightText,
  required var bookmarks,
  required double availableHeight,
  required double availableWidth,
}) {
  // Calculate optimal font size based on content and available space
  int estimatedChars = getEstimatedCharacterCount(pageIndex, jsonData);
  double optimalFontSize = calculateOptimalFontSize(
    availableHeight: availableHeight,
    availableWidth: availableWidth,
    pageIndex: pageIndex,
    estimatedCharacterCount: estimatedChars,
  );
  
  List<InlineSpan> spans = [];
  
  for (var surahData in pageData) {
    spans.addAll(kGetSpans(
      value: surahData,
      jsonData: jsonData,
      index: pageIndex,
      initLongPressGesture: initLongPressGesture,
      selectedSpan: selectedSpan,
      highlightVerse: highlightVerse,
      shouldHighlightText: shouldHighlightText,
      bookmarks: bookmarks,
      dynamicFontSize: optimalFontSize,
    ));
  }
  
  return spans;
}

