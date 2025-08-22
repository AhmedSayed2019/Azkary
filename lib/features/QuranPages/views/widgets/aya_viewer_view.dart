import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/QuranPages/widgets/bismallah.dart';
import 'package:azkark/features/QuranPages/widgets/header_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class AyaViewer extends StatefulWidget {
  final  List<GlobalKey> _richTextKeys;
  final  dynamic _jsonData;
  final  dynamic _shouldHighlightText;
  final  dynamic _highlightVerse;
  final Function _onShowAyahOptionsSheet;
  final Function(String) _onUpdateSelectedSpan;
  final int _index;
  final String _selectedSpan;
  final List _bookmarks;

  @override
  State<AyaViewer> createState() => _AyaViewerState();

  const AyaViewer({super.key,
    required List<GlobalKey> richTextKeys,
    required dynamic jsonData,
    required dynamic shouldHighlightText,
    required dynamic highlightVerse,
    required Function onShowAyahOptionsSheet,
    required Function(String) onUpdateSelectedSpan,
    required int index,
    required String selectedSpan,
    required List bookmarks,
  })  : _richTextKeys = richTextKeys,
        _jsonData = jsonData,
        _shouldHighlightText = shouldHighlightText,
        _highlightVerse = highlightVerse,
        _onShowAyahOptionsSheet = onShowAyahOptionsSheet,
        _onUpdateSelectedSpan = onUpdateSelectedSpan,
        _index = index,
        _selectedSpan = selectedSpan,
        _bookmarks = bookmarks;
}

class _AyaViewerState extends State<AyaViewer> {



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: SizedBox(
        width: double.infinity,
        child: RichText(
          key: widget._richTextKeys[widget._index - 1],
          textDirection: m.TextDirection.rtl,
          textAlign: (widget._index == 1 || widget._index == 2 || widget._index > 570) ? TextAlign.center : TextAlign.center,
          softWrap: true,
          locale: const Locale("ar"),
          text: TextSpan(
            style: TextStyle(color: primaryColors[getValue("quranPageolorsIndex")], fontSize: getValue("pageViewFontSize").toDouble(), fontFamily: getValue("selectedFontFamily")),
            children: quran.getPageData(widget._index).expand((e) {
              List<InlineSpan> spans = [];
              for (var i = e["start"]; i <= e["end"]; i++) {
                // Header
                if (i == 1) {
                  spans.add(WidgetSpan(child: HeaderWidget(e: e, jsonData: widget._jsonData)));
                  if (widget._index != 187 && widget._index != 1) spans.add(WidgetSpan(child: Basmallah(index: getValue("quranPageolorsIndex"))));
                  if (widget._index == 187) spans.add(WidgetSpan(child: Container(height: 10.h)));
                }

                // Verses
                spans.add(TextSpan(
                  recognizer: LongPressGestureRecognizer()
                    ..onLongPress = () {widget._onShowAyahOptionsSheet();}
                    ..onLongPressDown = (details) {widget._onUpdateSelectedSpan(" ${e["surah"]}$i");}
                    ..onLongPressUp = () {widget._onUpdateSelectedSpan("");}
                    ..onLongPressCancel = () {widget._onUpdateSelectedSpan("");},


                  text: i == e["start"]
                      ? "${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
                      : quran.getVerseQCF(e["surah"], i).replaceAll(' ', ''),

                  style: TextStyle(
                    color: widget._bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).isNotEmpty
                        ? Color(int.parse("0x${widget._bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                        : primaryColors[getValue("quranPageolorsIndex")],
                    height: (widget._index == 1 || widget._index == 2) ? 2.h : 1.95.h,
                    letterSpacing: 0.w,
                    wordSpacing: 0,
                    fontFamily: "QCF_P${widget._index.toString().padLeft(3, "0")}",
                    fontSize: widget._index == 1 || widget._index == 2 ? 28.sp : widget._index == 145 || widget._index == 201 ? widget._index == 532 || widget._index == 533 ? 22.5.sp : 22.4.sp : 22.9.sp,
                    backgroundColor: widget._shouldHighlightText
                        ? quran.getVerse(e["surah"], i) == widget._highlightVerse
                        ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                        : widget._selectedSpan == " ${e["surah"]}$i"
                        ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25) : Colors.transparent
                        : widget._selectedSpan == " ${e["surah"]}$i"
                        ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                        : Colors.transparent,
                  ),
                  children: const <TextSpan>[

                  ],
                ));
              }
              return spans;
            }).toList(),
          ),
        ),
      ),
    );
  }
}
