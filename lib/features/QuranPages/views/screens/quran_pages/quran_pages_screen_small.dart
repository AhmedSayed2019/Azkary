import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui'as ui;

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/QuranPages/helpers/convertNumberToAr.dart';
import 'package:azkark/features/QuranPages/helpers/translation/translationdata.dart';
import 'package:azkark/features/QuranPages/models/reciter.dart';
import 'package:azkark/features/QuranPages/views/sheets/actions_sheet.dart';
import 'package:azkark/features/QuranPages/widgets/bismallah.dart';
import 'package:azkark/features/QuranPages/widgets/header_widget.dart';
import 'package:azkark/generated/assets.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:screenshot/screenshot.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:tiktoklikescroller/tiktoklikescroller.dart' as verticalScroll;
import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';

class QuranDetailsPage extends StatefulWidget {
  int pageNumber;
  var jsonData;
  var quarterJsonData;
  final bool shouldHighlightText;
  final String highlightVerse;
  bool shouldHighlightSura;
  // var highlighSurah;
  QuranDetailsPage(
      {super.key,
        required this.pageNumber,
        required this.jsonData,
        required this.shouldHighlightText,
        required this.highlightVerse,
        required this.quarterJsonData,
        required this.shouldHighlightSura});

  @override
  State<QuranDetailsPage> createState() => QuranDetailsPageState();
}

class QuranDetailsPageState extends State<QuranDetailsPage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  bool isDownloading = false;

  List bookmarks = [];
  fetchBookmarks() {
    bookmarks = json.decode(getValue("bookmarks"));
    setState(() {});
  }

  var dataOfCurrentTranslation;
  getTranslationData() async {
    if (getValue("indexOfTranslationInVerseByVerse") > 1) {
      File file = File(
          "${appDir!.path}/${translationDataList[getValue("indexOfTranslationInVerseByVerse")].typeText}.json");

      String jsonData = await file.readAsString();
      dataOfCurrentTranslation = json.decode(jsonData);
    }
    setState(() {});
  }

  var currentVersePlaying;
  int index = 0;
  setIndex() {
    setState(() {
      index = widget.pageNumber;
    });
  }

  double valueOfSlider = 0;

  late Timer timer;
  Directory? appDir;
  initialize() async {
    appDir = await getTemporaryDirectory();
    getTranslationData();
    if (mounted) {
      setState(() {});
    }
  }

  checkIfSelectHighlight() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (selectedSpan != "") {
        setState(() {
          selectedSpan = "";
        });
      }
    });
  }

  int playIndexPage = 0;

  @override
  void initState() {
    fetchBookmarks();
    initialize();
    getTranslationData();
    checkIfSelectHighlight();
    setIndex();
    changeHighlightSurah();
    highlightVerseFunction();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pageController = PageController(initialPage: index);
    _pageController.addListener(_pagecontrollerScrollListner);
    WakelockPlus.enable();
    updateValue("lastRead", widget.pageNumber);
    addReciters();

    super.initState();
  }

  List<QuranPageReciter> reciters = [];
  addReciters() {
    quran.getReciters().forEach((element) {
      reciters.add(QuranPageReciter(
        identifier: element["identifier"],
        language: element["language"],
        name: element["name"],
        englishName: element["englishName"],
        format: element["format"],
        type: element["type"],
        direction: element["direction"],
      ));
    });
  }

  void _pagecontrollerScrollListner() {
    if (_pageController.position.isScrollingNotifier.value &&
        selectedSpan != "") {
      setState(() {
        selectedSpan = "";
      });
    } else {}
  }

  var highlightVerse;
  var shouldHighlightText;
  changeHighlightSurah() async {
    await Future.delayed(const Duration(seconds: 2));
    widget.shouldHighlightSura = false;
  }

  highlightVerseFunction() {
    setState(() {
      shouldHighlightText = widget.shouldHighlightText;
    });
    if (widget.shouldHighlightText) {
      setState(() {
        highlightVerse = widget.highlightVerse;
      });

      Timer.periodic(const Duration(milliseconds: 400), (timer) {
        if (mounted) {
          setState(() {
            shouldHighlightText = false;
          });
        }
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              shouldHighlightText = true;
            });
          }
          if (timer.tick == 4) {
            if (mounted) {
              setState(() {
                highlightVerse = "";
                shouldHighlightText = false;
              });
            }
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    getTotalCharacters(quran.getVersesTextByPage(widget.pageNumber));
    super.dispose();
  }

  int total = 0;
  int total1 = 0;
  int total3 = 0;
  int getTotalCharacters(List<String> stringList) {
    total = 0;
    for (String str in stringList) {
      total += str.length;
    }
    return total;
  }

  checkIfAyahIsAStartOfSura() {}
  String? swipeDirection;
  late PageController _pageController;

  var english = RegExp(r'[a-zA-Z]');

  String selectedSpan = "";

  Result checkIfPageIncludesQuarterAndQuarterIndex(array, pageData, indexes) {
    for (int i = 0; i < array.length; i++) {
      int surah = array[i]['surah'];
      int ayah = array[i]['ayah'];
      for (int j = 0; j < pageData.length; j++) {
        int pageSurah = pageData[j]['surah'];
        int start = pageData[j]['start'];
        int end = pageData[j]['end'];
        if ((surah == pageSurah) && (ayah >= start) && (ayah <= end)) {
          int targetIndex = i + 1;
          for (int hizbIndex = 0; hizbIndex < indexes.length; hizbIndex++) {
            List<int> hizb = indexes[hizbIndex];
            for (int quarterIndex = 0;
            quarterIndex < hizb.length;
            quarterIndex++) {
              if (hizb[quarterIndex] == targetIndex) {
                return Result(true, i, hizbIndex, quarterIndex);
              }
            }
          }
        }
      }
    }
    return Result(false, -1, -1, -1);
  }

  ScreenshotController screenshotController = ScreenshotController();

  double currentHeight = 2.0;
  double currentLetterSpacing = 0.0;
  final bool _isVisible = true;

  List<GlobalKey> richTextKeys = List.generate(
    604,
        (_) => GlobalKey(),
  );
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  LongPressGestureRecognizer initLongPressGestureRecognizer({required e , required i ,required index , }){
    LongPressGestureRecognizer recognizer= LongPressGestureRecognizer();
    recognizer
      ..onLongPress = () {onShowAyahOptionsSheet(e: e, i: i, index: index);}
      ..onLongPressDown = (details) {setState(() {selectedSpan = " ${e["surah"]}$i";});}
      ..onLongPressUp = () {setState(() {selectedSpan = "";});print("finished long press");}
      ..onLongPressCancel = () => setState(() {selectedSpan = "";});
    return recognizer;
  }

  onShowAyahOptionsSheet({required e , required i ,required index , })=> showAyahOptionsSheet(
      dataOfCurrentTranslation: dataOfCurrentTranslation,
      onUpdateDataOfCurrentTranslation: (v)=>setState((){dataOfCurrentTranslation = v;}),
      context: context,
      index: index,
      reciters: reciters,
      surahNumber: e["surah"],
      verseNumber: i,
      jsonData: widget.jsonData,
      richTextKeys: richTextKeys,
      itemScrollController: itemScrollController,
      bookmarks: bookmarks,
      appDir: appDir,
      isDownloading: isDownloading
  );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: scaffoldKey,
      endDrawer: SizedBox(height: screenSize.height, width: screenSize.width * .5),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Builder(
            builder: (context2) {
              if (getValue("alignmentType") == "pageview") {
                return PageView.builder(
                  physics: const CustomPageViewScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (a) {
                    setState(() {selectedSpan = "";});
                    index = a;
                    updateValue("lastRead", a);
                  },
                  controller: _pageController,
                  reverse: context.locale.languageCode == "ar" ? false : true,
                  itemCount: quran.totalPagesCount + 1,
                  itemBuilder: (context, index) {
                    bool isEvenPage = index.isEven;
                    if (index == 0) {
                      return Container(color: const Color(0xffFFFCE7), child: Image.asset(Assets.quranQuran, fit: BoxFit.fill),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                          color: backgroundColors[getValue("quranPageolorsIndex")],
                          boxShadow: [
                            if (isEvenPage)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(-5, 0),
                              ),
                          ],
                          border: Border.fromBorderSide(BorderSide(
                              color: primaryColors[getValue("quranPageolorsIndex")]
                                  .withOpacity(.05)))),
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor: Colors.transparent,
                        body: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(right: 12.0.w, left: 12.w),
                            // MAIN OPTIMIZATION: Use Column with Expanded to fill entire screen
                            child: Column(
                              children: [
                                // MINIMIZED HEADER: Reduce header height to maximize content space
                                SizedBox(
                                  height: 50.h, // Fixed minimal header height
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 27,
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(
                                            Icons.arrow_back_ios,
                                            size: 20.sp, // Reduced icon size
                                            color: secondaryColors[getValue("quranPageolorsIndex")],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 46,
                                        child: Text(
                                          convertToArabicNumber(index.toString()),
                                          style: TextStyle(
                                              color: primaryColors[getValue("quranPageolorsIndex")],
                                              fontSize: 14.sp, // Reduced font size
                                              fontFamily: "KFGQPC Uthmanic Script HAFS Regular"),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 27,
                                        child: IconButton(
                                          onPressed: () {
                                            Scaffold.of(context).openEndDrawer();
                                          },
                                          icon: Icon(
                                            Icons.menu,
                                            size: 20.sp, // Reduced icon size
                                            color: secondaryColors[getValue("quranPageolorsIndex")],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // MAIN OPTIMIZATION: Content fills remaining screen space
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double availableHeight = constraints.maxHeight;
                                      double availableWidth = constraints.maxWidth;

                                      return SizedBox(
                                        width: availableWidth,
                                        height: availableHeight,
                                        child: buildOptimizedPageContent(index, availableHeight, availableWidth),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  // MAIN OPTIMIZATION: Build content that perfectly fills available space
  Widget buildOptimizedPageContent(int pageIndex, double availableHeight, double availableWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal font size to fill the screen
        double optimalFontSize = calculateOptimalFontSize(pageIndex, availableHeight, availableWidth);
        double optimalLineHeight = calculateOptimalLineHeight(pageIndex, optimalFontSize);

        return SizedBox(
          width: availableWidth,
          height: availableHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute content evenly
            children: [
              // Content that fills the available space
              Expanded(
                child: SizedBox(
                  width: availableWidth,
                  child: RichText(
                    key: richTextKeys[pageIndex],
                    textAlign: TextAlign.justify,
                    textDirection: ui.TextDirection.rtl,
                    text: TextSpan(
                      children: buildOptimizedTextSpans(pageIndex, optimalFontSize, optimalLineHeight),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // OPTIMIZATION: Calculate font size to perfectly fill screen
  double calculateOptimalFontSize(int pageIndex, double availableHeight, double availableWidth) {
    // Get estimated character count for this page
    int estimatedChars = getEstimatedCharacterCount(pageIndex);

    // Base font size
    double baseFontSize = pageIndex == 1 || pageIndex == 2 ? 28.sp : 22.9.sp;

    // Calculate how much text we need to fit
    double estimatedTextHeight = estimatedChars * baseFontSize * 0.08; // Rough estimation

    // Calculate scale factor to fill available height
    double heightScaleFactor = availableHeight / estimatedTextHeight;

    // Apply scale factor with reasonable bounds
    double optimalFontSize = (baseFontSize * heightScaleFactor).clamp(
      baseFontSize * 0.7, // Minimum 70% of original
      baseFontSize * 1.5,  // Maximum 150% of original
    );

    return optimalFontSize;
  }

  // OPTIMIZATION: Calculate line height to maximize screen usage
  double calculateOptimalLineHeight(int pageIndex, double fontSize) {
    // Tighter line spacing to fit more content
    double baseRatio = (pageIndex == 1 || pageIndex == 2) ? 1.8 : 1.7; // Reduced from 2.0 and 1.95
    return baseRatio.h;
  }

  // OPTIMIZATION: Get character count for better font size calculation
  int getEstimatedCharacterCount(int pageIndex) {
    if (widget.jsonData == null || pageIndex <= 0 || pageIndex > widget.jsonData.length) {
      return 1000; // Default estimate
    }

    try {
      var pageData = widget.jsonData[pageIndex - 1];
      if (pageData is! List) {
        if (pageData is Map) {
          if (pageData.containsKey('surahs') && pageData['surahs'] is List) {
            pageData = pageData['surahs'];
          } else {
            pageData = [pageData];
          }
        } else {
          return 1000;
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
      return 1000; // Fallback
    }
  }

  // OPTIMIZATION: Build text spans with optimal sizing
  List<InlineSpan> buildOptimizedTextSpans(int pageIndex, double fontSize, double lineHeight) {
    List<InlineSpan> spans = [];

    if (widget.jsonData == null || pageIndex <= 0 || pageIndex > widget.jsonData.length) {
      return spans;
    }

    var pageData = widget.jsonData[pageIndex - 1];

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

    try {
      for (var surahData in quran.getPageData(pageIndex)) {
        if (surahData is Map<String, dynamic>) {

          // if (surahData is Map<String, dynamic>) {
          spans.addAll(kGetSpansOptimized(
            value: surahData,
            jsonData: widget.jsonData,
            index: pageIndex,
            initLongPressGesture: ({required e, required i, required pageIndex}) => initLongPressGestureRecognizer(e: e, i: i, index: index),
            selectedSpan: selectedSpan,
            highlightVerse: highlightVerse,
            shouldHighlightText: shouldHighlightText,
            bookmarks: bookmarks,
            fontSize: fontSize,
            lineHeight: lineHeight,
          ));
        }
      }
    } catch (e) {
      print("Error building optimized text spans: $e");
      spans.add(TextSpan(
        text: "Error loading page content",
        style: TextStyle(
          color: primaryColors[getValue("quranPageolorsIndex")],
          fontSize: fontSize,
        ),
      ));
    }

    return spans;
  }
}

// OPTIMIZATION: Enhanced kGetSpans function with custom sizing
List<InlineSpan> kGetSpansOptimized({
  required dynamic value,
  required var jsonData,
  required int index,
  required LongPressGestureRecognizer Function({required dynamic e, required int i, required int pageIndex}) initLongPressGesture,
  required var selectedSpan,
  required var highlightVerse,
  required var shouldHighlightText,
  required var bookmarks,
  required double fontSize,
  required double lineHeight,
}) {
  List<InlineSpan> spans = [];

  for (var i = value["start"]; i <= value["end"]; i++) {
    // Header with optimized sizing
    if (i == 1) {
      spans.add(WidgetSpan(
        child: Transform.scale(
          scale: 0.8, // Scale down header to save space
          child: HeaderWidget(e: value, jsonData: jsonData),
        ),
      ));
      if (index != 187 && index != 1) {
        spans.add(WidgetSpan(
          child: Transform.scale(
            scale: 0.8, // Scale down Basmallah
            child: Basmallah(index: getValue("quranPageolorsIndex")),
          ),
        ));
      }
      if (index == 187) {
        spans.add(WidgetSpan(child: Container(height: 5.h))); // Reduced spacing
      }
    }

    // Verses with optimized styling
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
        height: lineHeight,
        letterSpacing: 0.w,
        wordSpacing: 0,
        fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
        fontSize: fontSize, // Use calculated optimal font size
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

// Custom PageView physics
class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 80,
    stiffness: 100,
    damping: 1,
  );
}

// Result class
class Result {
  final bool found;
  final int index;
  final int hizbIndex;
  final int quarterIndex;

  Result(this.found, this.index, this.hizbIndex, this.quarterIndex);
}

