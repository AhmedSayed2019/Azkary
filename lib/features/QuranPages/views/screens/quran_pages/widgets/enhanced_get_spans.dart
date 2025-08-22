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

// OPTIMIZED VERSION: Designed to fill entire screen with dynamic sizing
List<InlineSpan> kGetSpans({
  required dynamic value,
  required var jsonData,
  required int index,
  required LongPressFactory initLongPressGesture,
  required var selectedSpan,
  required var highlightVerse,
  required var shouldHighlightText,
  required var bookmarks,
  double? dynamicFontSize,
  double? dynamicLineHeight,
}) {
  List<InlineSpan> spans = [];

  // Calculate optimal sizing for screen filling
  double fontSize = dynamicFontSize ?? _getOptimalFontSize(index);
  double lineHeight = dynamicLineHeight ?? _getOptimalLineHeight(index, fontSize);

  for (var i = value["start"]; i <= value["end"]; i++) {
    // OPTIMIZATION: Minimize header space to maximize content
    if (i == 1) {
      spans.add(WidgetSpan(
        child: Transform.scale(
          scale: 0.75, // Scale down header to save vertical space
          child: HeaderWidget(e: value, jsonData: jsonData),
        ),
      ));
      if (index != 187 && index != 1) {
        spans.add(WidgetSpan(
          child: Transform.scale(
            scale: 0.75, // Scale down Basmallah
            child: Basmallah(index: getValue("quranPageolorsIndex")),
          ),
        ));
      }
      if (index == 187) {
        spans.add(WidgetSpan(child: Container(height: 3.h))); // Minimal spacing
      }
    }

    // OPTIMIZATION: Verses with screen-filling font size
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
        height: lineHeight, // Optimized line height for screen filling
        letterSpacing: 0.w,
        wordSpacing: 0,
        fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
        fontSize: fontSize, // Dynamic font size for optimal screen usage
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

// OPTIMIZED VERSION: Enhanced for screen filling
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
  double? dynamicFontSize,
  double? dynamicLineHeight,
}) {
  List<InlineSpan> spans = [];

  // Calculate optimal sizing
  double fontSize = dynamicFontSize ?? _getOptimalFontSize(index);
  double lineHeight = dynamicLineHeight ?? _getOptimalLineHeight(index, fontSize);

  for (var i = e["start"]; i <= e["end"]; i++) {
    // OPTIMIZATION: Minimized header
    if (i == 1) {
      spans.add(WidgetSpan(
        child: Transform.scale(
          scale: 0.75,
          child: HeaderWidget(e: e, jsonData: jsonData),
        ),
      ));
      if (index != 187 && index != 1) {
        spans.add(WidgetSpan(
          child: Transform.scale(
            scale: 0.75,
            child: Basmallah(index: getValue("quranPageolorsIndex")),
          ),
        ));
      }
      if (index == 187) {
        spans.add(WidgetSpan(child: Container(height: 3.h)));
      }
    }

    // OPTIMIZATION: Screen-filling verses
    spans.add(TextSpan(
      locale: const Locale("ar"),
      recognizer: initLongPressGesture(e: e, i: i, pageIndex: index),
      text: quran.getVerseQCF(e["surah"], i).replaceAll(' ', ''),
      style: TextStyle(
        color: primaryColors[getValue("quranPageolorsIndex")],
        height: lineHeight, // Optimized line height
        letterSpacing: 0.w,
        fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
        fontSize: fontSize, // Dynamic font size
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

    // OPTIMIZATION: Scaled bookmark icons
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
            size: fontSize * 0.7, // Scale icon with font size
          )));
    }
  }
  return spans;
}

// OPTIMIZATION HELPERS

/// Get optimal font size for screen filling
double _getOptimalFontSize(int index) {
  // Increased base font sizes for better screen filling
  if (index == 1 || index == 2) {
    return 32.sp; // Increased from 28.sp
  } else if (index == 145 || index == 201) {
    return index == 532 || index == 533 ? 26.sp : 25.sp; // Increased
  } else {
    return 26.sp; // Increased from 22.9.sp
  }
}

/// Get optimal line height for screen filling
double _getOptimalLineHeight(int index, double fontSize) {
  // Tighter line spacing to fit more content on screen
  double baseRatio = (index == 1 || index == 2) ? 1.6 : 1.5; // Reduced from 2.0 and 1.95
  return baseRatio.h;
}

/// Calculate screen-filling font size based on available space and content
double calculateScreenFillingFontSize({
  required double availableHeight,
  required double availableWidth,
  required int pageIndex,
  required int estimatedCharacterCount,
}) {
  // Base font size for the page
  double baseFontSize = _getOptimalFontSize(pageIndex);

  // Estimate text density per line
  double charsPerLine = availableWidth / (baseFontSize * 0.6); // Rough estimation
  double estimatedLines = estimatedCharacterCount / charsPerLine;

  // Calculate required line height to fill screen
  double requiredLineHeight = availableHeight / estimatedLines;

  // Calculate font size from line height
  double calculatedFontSize = requiredLineHeight / 1.5; // Assuming 1.5 line height ratio

  // Apply reasonable bounds
  double screenFillingFontSize = calculatedFontSize.clamp(
    baseFontSize * 0.8, // Minimum 80% of base
    baseFontSize * 1.4,  // Maximum 140% of base
  );

  return screenFillingFontSize;
}

/// Get estimated character count for a page
int getEstimatedCharacterCount(int pageIndex, var jsonData) {
  if (pageIndex <= 0 || jsonData == null || pageIndex > jsonData.length) return 1200;

  try {
    var pageData = jsonData[pageIndex - 1];

    // Handle different data formats
    if (pageData is! List) {
      if (pageData is Map) {
        if (pageData.containsKey('surahs') && pageData['surahs'] is List) {
          pageData = pageData['surahs'];
        } else {
          pageData = [pageData];
        }
      } else {
        return 1200;
      }
    }

    int totalChars = 0;
    for (var surahData in pageData) {
      if (surahData is Map<String, dynamic>) {
        for (var i = surahData["start"]; i <= surahData["end"]; i++) {
          totalChars += quran.getVerseQCF(surahData["surah"], i).length;
        }
      }
    }

    return totalChars;
  } catch (e) {
    return 1200; // Fallback
  }
}

/// Create screen-filling text spans that maximize screen usage
List<InlineSpan> createScreenFillingTextSpans({
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
  // Calculate optimal font size for screen filling
  int estimatedChars = getEstimatedCharacterCount(pageIndex, jsonData);
  double screenFillingFontSize = calculateScreenFillingFontSize(
    availableHeight: availableHeight,
    availableWidth: availableWidth,
    pageIndex: pageIndex,
    estimatedCharacterCount: estimatedChars,
  );

  double screenFillingLineHeight = _getOptimalLineHeight(pageIndex, screenFillingFontSize);

  List<InlineSpan> spans = [];

  // Handle data format
  if (pageData is! List) {
    if (pageData is Map) {
      if (pageData.containsKey('surahs') && pageData['surahs'] is List) {
        pageData = pageData['surahs'];
      } else {
        pageData = [pageData];
      }
    } else {
      return spans;
    }
  }

  for (var surahData in pageData) {
    if (surahData is Map<String, dynamic>) {
      spans.addAll(kGetSpans(
        value: surahData,
        jsonData: jsonData,
        index: pageIndex,
        initLongPressGesture: initLongPressGesture,
        selectedSpan: selectedSpan,
        highlightVerse: highlightVerse,
        shouldHighlightText: shouldHighlightText,
        bookmarks: bookmarks,
        dynamicFontSize: screenFillingFontSize,
        dynamicLineHeight: screenFillingLineHeight,
      ));
    }
  }

  return spans;
}

/// Advanced screen filling algorithm that adjusts content to perfectly fit screen
List<InlineSpan> createPerfectFitTextSpans({
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
  int maxIterations = 3, // Number of iterations to perfect the fit
}) {
  double currentFontSize = _getOptimalFontSize(pageIndex);
  double currentLineHeight = _getOptimalLineHeight(pageIndex, currentFontSize);

  // Iteratively adjust font size to achieve perfect screen filling
  for (int iteration = 0; iteration < maxIterations; iteration++) {
    // Create spans with current sizing
    List<InlineSpan> testSpans = createScreenFillingTextSpans(
      pageData: pageData,
      pageIndex: pageIndex,
      jsonData: jsonData,
      initLongPressGesture: initLongPressGesture,
      selectedSpan: selectedSpan,
      highlightVerse: highlightVerse,
      shouldHighlightText: shouldHighlightText,
      bookmarks: bookmarks,
      availableHeight: availableHeight,
      availableWidth: availableWidth,
    );

    // Estimate if content fits perfectly (this is a simplified estimation)
    // In a real implementation, you might want to measure actual text height
    int estimatedChars = getEstimatedCharacterCount(pageIndex, jsonData);
    double estimatedHeight = estimatedChars * currentFontSize * currentLineHeight * 0.05;

    if (estimatedHeight < availableHeight * 0.95) {
      // Content is too small, increase font size
      currentFontSize *= 1.05;
      currentLineHeight = _getOptimalLineHeight(pageIndex, currentFontSize);
    } else if (estimatedHeight > availableHeight * 1.05) {
      // Content is too large, decrease font size
      currentFontSize *= 0.95;
      currentLineHeight = _getOptimalLineHeight(pageIndex, currentFontSize);
    } else {
      // Perfect fit achieved
      break;
    }
  }

  // Return final optimized spans
  return createScreenFillingTextSpans(
    pageData: pageData,
    pageIndex: pageIndex,
    jsonData: jsonData,
    initLongPressGesture: initLongPressGesture,
    selectedSpan: selectedSpan,
    highlightVerse: highlightVerse,
    shouldHighlightText: shouldHighlightText,
    bookmarks: bookmarks,
    availableHeight: availableHeight,
    availableWidth: availableWidth,
  );
}

