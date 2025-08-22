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
import 'package:azkark/features/QuranPages/views/screens/quran_pages/widgets/get_spans.dart';
import 'package:azkark/features/QuranPages/views/sheets/actions_sheet.dart';
import 'package:azkark/generated/assets.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
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
  // Removed ScrollController as we won't need scrolling
  // final ScrollController _scrollController = ScrollController();

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

    // Removed scroll listener as we won't have scrolling
    // _scrollController.addListener(_scrollListener);

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
                            // MAIN FIX: Replace SingleChildScrollView with Column and Expanded
                            child: Column(
                              children: [
                                // Header section - fixed height
                                SizedBox(
                                  width: screenSize.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // LAYOUT FIX: Use Flexible instead of fixed width SizedBox
                                      Flexible(
                                        flex: 27,
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  size: 24.sp,
                                                  color: secondaryColors[getValue("quranPageolorsIndex")],
                                                )),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        flex: 46,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              convertToArabicNumber(index.toString()),
                                              style: TextStyle(
                                                  color: primaryColors[getValue("quranPageolorsIndex")],
                                                  fontSize: 16.sp,
                                                  fontFamily: "KFGQPC Uthmanic Script HAFS Regular"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        flex: 27,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  Scaffold.of(context).openEndDrawer();
                                                },
                                                icon: Icon(
                                                  Icons.menu,
                                                  size: 24.sp,
                                                  color: secondaryColors[getValue("quranPageolorsIndex")],
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // MAIN FIX: Content section - flexible height that adapts to screen
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Calculate available height for content
                                      double availableHeight = constraints.maxHeight;

                                      return Container(
                                        height: availableHeight,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.topCenter,
                                          child: SizedBox(
                                            width: screenSize.width - 24.w,
                                            child: buildPageContent(index, screenSize, availableHeight),
                                          ),
                                        ),
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

  // MAIN FIX: Separate method to build page content with dynamic sizing
  Widget buildPageContent(int pageIndex, Size screenSize, double availableHeight) {
    return Directionality(
      textDirection: m.TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Build the rich text content
          RichText(
            textAlign: (index == 1 || index == 2 || index > 570) ? TextAlign.center : TextAlign.center,
            key: richTextKeys[pageIndex],
            // textAlign: TextAlign.justify,
            textDirection: ui.TextDirection.rtl,
            text: TextSpan(

              children: buildTextSpans(pageIndex, availableHeight),
            ),
          ),

          // Add some spacing at the bottom
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  // MAIN FIX: Build text spans with proper data handling
  List<InlineSpan> buildTextSpans(int pageIndex, double availableHeight) {
    List<InlineSpan> spans = [];

    // CRITICAL FIX: Proper data validation and handling
    if (widget.jsonData == null || pageIndex <= 0 || pageIndex > widget.jsonData.length) {
      return spans;
    }

    // CRITICAL FIX: Now safely iterate through the List
    try {
      for (var surahData in quran.getPageData(index)) {
        if (surahData is Map<String, dynamic>) {
          spans.addAll(kGetSpans(
            value: surahData,
            jsonData: widget.jsonData,
            index: pageIndex,

            initLongPressGesture: ({required e, required i, required pageIndex}) => initLongPressGestureRecognizer(e: e, i: i, index: pageIndex),
            selectedSpan: selectedSpan,
            highlightVerse: highlightVerse,
            shouldHighlightText: shouldHighlightText,
            bookmarks: bookmarks,
          ));
        }
      }
    } catch (e) {
      print("Error building text spans: $e");
      // Return a fallback span in case of error
      spans.add(TextSpan(
        text: "Error loading page content",
        style: TextStyle(
          color: primaryColors[getValue("quranPageolorsIndex")],
          fontSize: 16.sp,
        ),
      ));
    }

    return spans;
  }

  // MAIN FIX: Build text spans with proper data handling
  List<InlineSpan> buildTextSpansTest(int pageIndex, double availableHeight) {
    List<InlineSpan> spans = [];

    // CRITICAL FIX: Proper data validation and handling
    if (widget.jsonData == null || pageIndex <= 0 || pageIndex > widget.jsonData.length) {
      return spans;
    }

    // Get page data - this should be a List, not a Map
    var pageData = widget.jsonData[pageIndex - 1];

    // CRITICAL FIX: Check if pageData is iterable (List) instead of Map
    if (pageData is! List) {
      // If it's a Map, try to convert it to a List or handle appropriately
      if (pageData is Map) {
        // If it's a single surah data wrapped in a Map, extract it
        if (pageData.containsKey('surahs') && pageData['surahs'] is List) {
          pageData = pageData['surahs'];
        } else {
          // Convert single Map to List
          pageData = [pageData];
        }
      } else {
        return spans; // Return empty if data format is unexpected
      }
    }

    // Calculate dynamic font size based on available height
    double baseFontSize = calculateDynamicFontSize(pageIndex, availableHeight);

    // CRITICAL FIX: Now safely iterate through the List
    try {
      for (var surahData in pageData) {
        if (surahData is Map<String, dynamic>) {
          spans.addAll(kGetSpans(
            value: surahData,
            jsonData: widget.jsonData,
            index: pageIndex,
            initLongPressGesture: ({required e, required i, required pageIndex}) => initLongPressGestureRecognizer(e: e, i: i, index: pageIndex),
            selectedSpan: selectedSpan,
            highlightVerse: highlightVerse,
            shouldHighlightText: shouldHighlightText,
            bookmarks: bookmarks,
          ));
        }
      }
    } catch (e) {
      print("Error building text spans: $e");
      // Return a fallback span in case of error
      spans.add(TextSpan(
        text: "Error loading page content",
        style: TextStyle(
          color: primaryColors[getValue("quranPageolorsIndex")],
          fontSize: 16.sp,
        ),
      ));
    }

    return spans;
  }

  // Calculate dynamic font size based on content and available space
  double calculateDynamicFontSize(int pageIndex, double availableHeight) {
    // Base font size
    double baseFontSize = pageIndex == 1 || pageIndex == 2 ? 28.sp : 22.9.sp;

    // Estimate content height and adjust font size accordingly
    double contentEstimate = availableHeight * 0.8;
    double scaleFactor = contentEstimate / (availableHeight * 1.2);

    // Ensure font size doesn't go below a minimum or above a maximum
    double dynamicFontSize = (baseFontSize * scaleFactor).clamp(16.sp, 32.sp);

    return dynamicFontSize;
  }
}

// Custom PageView physics to handle smooth scrolling
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

// Result class for quarter checking
class Result {
  final bool found;
  final int index;
  final int hizbIndex;
  final int quarterIndex;

  Result(this.found, this.index, this.hizbIndex, this.quarterIndex);
}

