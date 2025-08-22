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

List<InlineSpan> kGetSpans({required dynamic  value ,required var jsonData, required int index ,required LongPressFactory initLongPressGesture ,required var  selectedSpan , required var  highlightVerse ,required var  shouldHighlightText ,required var  bookmarks}){

  List<InlineSpan> spans = [];
  for (var i = value["start"]; i <= value["end"]; i++) {
    // Header
    if (i == 1) {
      spans.add(WidgetSpan(child: HeaderWidget(e: value, jsonData: jsonData)));
      if (index != 187 && index != 1) spans.add(WidgetSpan(child: Basmallah(index: getValue("quranPageolorsIndex"))));
      if (index == 187) spans.add(WidgetSpan(child: Container(height: 10.h),));
    }

    // Verses
    spans.add(TextSpan(


      recognizer: initLongPressGesture(e: value, i: i, pageIndex: index),
      // recognizer:initLongPressGesture(e: e, i: i, index: index),
      text: i == value["start"] ? "${quran.getVerseQCF(value["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerseQCF(value["surah"], i).replaceAll(" ", "").substring(1)}" : quran.getVerseQCF(value["surah"], i).replaceAll(' ', ''),

      style: TextStyle(
        color: bookmarks.where((element) => element["suraNumber"] == value["surah"] && element["verseNumber"] == i).isNotEmpty
            ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == value["surah"] && element["verseNumber"] == i).first["color"]}"))
            : primaryColors[getValue("quranPageolorsIndex")],
        height: (index == 1 || index == 2) ? 2.h : 1.95.h,
        letterSpacing: 0.w,
        wordSpacing: 0,
        fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
        fontSize: index == 1 || index == 2 ? 28.sp : index == 145 || index == 201 ? index == 532 || index == 533 ? 22.5.sp : 22.4.sp : 22.9.sp,
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
      children: const <TextSpan>[
      ],
    ));
  }
  return spans;
}


List<InlineSpan> kGetSpans1({required dynamic  e ,required int suraNumber, required var currentVersePlaying, required var jsonData, required int index ,required LongPressFactory initLongPressGesture ,required var  selectedSpan , required var  highlightVerse ,required var  shouldHighlightText ,required var  bookmarks}){

  List<InlineSpan>spans = [];
  for (var i = e["start"]; i <= e["end"]; i++) {
    // Header
    if (i == 1) {
      spans.add(WidgetSpan(child: HeaderWidget(e: e, jsonData: jsonData)));
      if (index != 187 && index != 1) {
        spans.add(WidgetSpan(child: Basmallah(index: getValue("quranPageolorsIndex"),)));
      }
      if (index == 187) {
        spans.add(WidgetSpan(child: Container(height: 10.h,)));
      }
    }

    // Verses
    spans.add(
        TextSpan(
          locale:
          const Locale("ar"),
          recognizer: initLongPressGesture(e: e, i: i, pageIndex: index),
          text: quran.getVerseQCF(e["surah"], i).replaceAll(' ', ''),
          style:
          TextStyle(color: primaryColors[
            getValue("quranPageolorsIndex")],
            height: (index == 1 || index == 2) ? 2.h : 1.95.h,
            letterSpacing:
            0.w,
            fontFamily:
            "QCF_P${index.toString().padLeft(3, "0")}",
            fontSize:
            22.9.sp,
            backgroundColor: bookmarks
                .where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i)
                .isNotEmpty
                ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
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
          children: const [
            // TextSpan(
            //     locale: const Locale(
            //         "ar"),
            //     text:
            //         " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
            //     ,
            //     style: TextStyle(
            //         color: isVerseStarred(
            //                 e[
            //                     "surah"],
            //                 i)
            //             ? Colors.amber
            //             : secondaryColors[
            //                 getValue(
            //                     "quranPageolorsIndex")],
            //         fontFamily:
            //             "KFGQPC Uthmanic Script HAFS Regular")),

            //               ],
            //             ),
            //           ),
            //         ),
            //     ),
            //     ),
          ],
        ));
    if (bookmarks
        .where((element) =>
    element["suraNumber"] ==
        e[
        "surah"] &&
        element["verseNumber"] ==
            i)
        .isNotEmpty) {
      spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(
            Icons
                .bookmark,
            color:
            Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
          )));
    }
  }
  return spans;
}


