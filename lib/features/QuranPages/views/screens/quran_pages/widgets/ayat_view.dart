// import 'package:azkark/core/extensions/num_extensions.dart';
// import 'package:azkark/features/QuranPages/bloc/player_bar_bloc.dart';
// import 'package:azkark/features/QuranPages/bloc/player_bloc_bloc.dart';
// import 'package:azkark/features/QuranPages/bloc/quran_page_player_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:visibility_detector/visibility_detector.dart';
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:azkark/core/extensions/num_extensions.dart';
// import 'package:azkark/core/utils/constants.dart';
// import 'package:azkark/core/utils/hive_helper.dart';
// // import 'package:azkark/features/QuranPages/bloc/player_bar_bloc.dart';
// import 'package:azkark/features/QuranPages/bloc/player_bloc_bloc.dart';
// import 'package:azkark/features/QuranPages/bloc/quran_page_player_bloc.dart';
// import 'package:azkark/features/QuranPages/helpers/convertNumberToAr.dart';
// import 'package:azkark/features/QuranPages/helpers/remove_html_tags.dart';
// import 'package:azkark/features/QuranPages/helpers/translation/translationdata.dart';
// import 'package:azkark/features/QuranPages/models/reciter.dart';
// import 'package:azkark/features/QuranPages/views/download_helper.dart';
// import 'package:azkark/features/QuranPages/views/screenshot_preview.dart';
// import 'package:azkark/features/QuranPages/views/sheets/actions_sheet.dart';
// import 'package:azkark/features/QuranPages/widgets/bismallah.dart';
// import 'package:azkark/features/QuranPages/widgets/easy_container.dart';
// import 'package:azkark/features/QuranPages/widgets/header_dart';
// import 'package:azkark/features/home/home_page.dart';
// import 'package:azkark/generated/assets.dart';
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// // import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
// // import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//
// // import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart' as m;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// // import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter/scheduler.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:fluttericon/elusive_icons.dart';
// // import 'package:fluttericon/font_awesome5_icons.dart';
// import 'package:fluttericon/font_awesome_icons.dart';
// import 'package:fluttericon/linearicons_free_icons.dart';
// import 'package:fluttericon/mfg_labs_icons.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:path_provider/path_provider.dart';
// // import 'package:azkark/features/QuranPages/widgets/tafseer_and_translation_sheet.dart';
// // import 'package:azkark/features/QuranPages/helpers/convertNumberToAr.dart';
// // import 'package:azkark/features/QuranPages/widgets/bismallah.dart';
// // import 'package:azkark/features/QuranPages/widgets/header_dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:quran/quran.dart' as quran;
// import 'package:quran/quran.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// // import 'package:tiktoklikescroller/tiktoklikescroller.dart' as verticalScroll;
// import 'package:wakelock_plus/wakelock_plus.dart';
//
// // import 'package:azkark/features/QuranPages/widgets/bookmark_dialog.dart';
//
// import '../../../../../../widgets/dialog/base/simple_dialogs.dart';
// import '../../../../helpers/translation/get_translation_data.dart'
// as get_translation_data;
// // import 'package:intl/intl.dart';
// // import 'package:arabic_roman_conv/arabic_roman_conv.dart';
// import '../../../../helpers/translation/get_translation_data.dart' as translate;
// import '../../../../widgets/header_widget.dart';
//
// final qurapPagePlayerBloc = QuranPagePlayerBloc();
// final playerPageBloc = PlayerBlocBloc();
// final playerbarBloc = PlayerBarBloc();
//
// class AyatView extends StatefulWidget {
//
//   const AyatView({Key? key}) : super(key: key);
//
//   @override
//   State<AyatView> createState() => _AyatViewState();
// }
//
// class _AyatViewState extends State<AyatView> {
//   final int _index;
//   final List<GlobalKey> _richTextKeys;
//   final LongPressGestureRecognizer _initLongPressGestureRecognizer;
//   final List _bookmarks;
//   final  Set<String> _starredVerses;
//   String selectedSpan;
//   int pageNumber;
//
//   var dataOfCurrentTranslation;
//   List<QuranPageReciter> _reciters ;
//   List<GlobalKey> richTextKeys;
//   var jsonData;
//   var quarterJsonData;
//   final bool shouldHighlightText;
//   final String highlightVerse;
//   bool shouldHighlightSura;
//   final double initialFontSize;
//    // starting point (will shrink if needed)
//   final double minFontSize;
//   var currentVersePlaying;
//   bool isVerseStarred(int surahNumber, int verseNumber) {
//     final verseKey = "$surahNumber-$verseNumber";
//     return _starredVerses.contains(verseKey);
//   }
//
//   LongPressGestureRecognizer initLongPressGestureRecognizer({required e , required i ,required index , }){
//     LongPressGestureRecognizer recognizer= LongPressGestureRecognizer();
//     recognizer
//       ..onLongPress = () {onShowAyahOptionsSheet(e: e, i: i, index: index);}
//       ..onLongPressDown = (details) {setState(() {selectedSpan = " ${e["surah"]}$i";});}
//       ..onLongPressUp = () {setState(() {selectedSpan = "";});print("finished long press");}
//       ..onLongPressCancel = () => setState(() {selectedSpan = "";});
//     return recognizer;
//   }
//   onShowAyahOptionsSheet({required e , required i ,required index , })=> showAyahOptionsSheet(
//       dataOfCurrentTranslation: dataOfCurrentTranslation,
//       onUpdateDataOfCurrentTranslation: (v)=>setState((){dataOfCurrentTranslation = v;}),
//       context: context,
//       index: index,
//       reciters: _reciters,
//       surahNumber: e["surah"],
//       verseNumber: i,
//       jsonData: widget.jsonData,
//       richTextKeys: richTextKeys,
//       itemScrollController: itemScrollController,
//       bookmarks: bookmarks,
//       appDir: appDir,
//       isDownloading: isDownloading
//   );
//
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<QuranPagePlayerBloc, QuranPagePlayerState>(
//       bloc: qurapPagePlayerBloc,
//       builder: (context, state) {
//         if (state is QuranPagePlayerInitial || state is QuranPagePlayerIdle) {
//           print("idle");
//           return VisibilityDetector(
//             key: Key(_index.toString()),
//             onVisibilityChanged: (VisibilityInfo info) {
//               if (info.visibleFraction == 1) {
//                 print(_index);
//                 updateValue("lastRead", _index);
//               }
//             },
//             child: Column(
//               children: [
//                 Directionality(
//                   textDirection: m.TextDirection.rtl,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 20.0.w, vertical: 26.h),
//                     child: SizedBox(
//                         width: double.infinity,
//                         child: RichText(
//                           key: richTextKeys[_index - 1],
//                           textDirection: m.TextDirection.rtl,
//                           textAlign: TextAlign.center,
//                           softWrap: true,
//                           //locale: const Locale("ar"),
//                           text: TextSpan(
//                             locale: const Locale("ar"),
//                             children: quran.getPageData(_index).expand((e) {
//                               // print(e);
//                               List<InlineSpan> spans = [];
//                               for (var i = e["start"]; i <= e["end"]; i++) {
//                                 print(_index);
//                                 // Header
//                                 if (i == 1) {
//                                   spans.add(WidgetSpan(
//                                     child: HeaderWidget(
//                                         e: e, jsonData: jsonData),
//                                   ));
//
//                                   if (_index != 187 && _index != 1) {
//                                     spans.add(WidgetSpan(
//                                         child: Basmallah(
//                                       index: getValue("quranPageolorsIndex"),
//                                     )));
//                                   }
//                                   if (_index == 187 || _index == 1) {
//                                     spans.add(WidgetSpan(child: Container(height: 10.h)));
//                                   }
//                                 }
//
//                                 // Verses
//                                 spans.add(TextSpan(
//                                   locale: const Locale("ar"),
//                                   recognizer: initLongPressGestureRecognizer(
//                                       e: e, i: i, index: _index),
//                                   text: quran.getVerse(e["surah"], i),
//                                   style: TextStyle(
//                                     //wordSpacing: -7,
//                                     color: primaryColors[
//                                         getValue("quranPageolorsIndex")],
//                                     fontSize: getValue("verticalViewFontSize")
//                                         .toDouble(),
//                                     // wordSpacing: -1.4,
//                                     fontFamily: getValue("selectedFontFamily"),
//                                     // letterSpacing: 1,
//                                     //fontWeight: FontWeight.bold,
//                                     backgroundColor: _bookmarks
//                                             .where((element) =>
//                                                 element["suraNumber"] == e["surah"] &&
//                                                 element["verseNumber"] == i)
//                                             .isNotEmpty
//                                         ? Color(int.parse("0x${_bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
//                                             .withOpacity(.19)
//                                         : shouldHighlightText
//                                             ? quran.getVerse(e["surah"], i) ==
//                                                     highlightVerse
//                                                 ? highlightColors[getValue(
//                                                         "quranPageolorsIndex")]
//                                                     .withOpacity(.25)
//                                                 : selectedSpan ==
//                                                         " ${e["surah"]}$i"
//                                                     ? highlightColors[getValue(
//                                                             "quranPageolorsIndex")]
//                                                         .withOpacity(.25)
//                                                     : Colors.transparent
//                                             : selectedSpan == " ${e["surah"]}$i"
//                                                 ? highlightColors[
//                                                         getValue("quranPageolorsIndex")]
//                                                     .withOpacity(.25)
//                                                 : Colors.transparent,
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                         text:
//                                             " ${convertToArabicNumber((i).toString())} "
//                                         //               quran.getVerseEndSymbol()
//                                         ,
//                                         style: TextStyle(
//                                             //wordSpacing: -10,letterSpacing: -5,
//                                             color: isVerseStarred(e["surah"], i)
//                                                 ? Colors.amber
//                                                 : secondaryColors[getValue(
//                                                     "quranPageolorsIndex")],
//                                             fontFamily:
//                                                 "KFGQPC Uthmanic Script HAFS Regular")),
//
//                                     //               ],
//                                     //             ),
//                                     //           ),
//                                     //         ),
//                                     //     ),
//                                     //     ),
//                                   ],
//                                 ));
//                                 // if (_bookmarks.contains(
//                                 //     "${e["surah"]}-$i")) {
//                                 //   spans.add(WidgetSpan(
//                                 //       alignment:
//                                 //           PlaceholderAlignment
//                                 //               .middle,
//                                 //       child: Icon(
//                                 //         Icons.bookmark,
//                                 //         color: colorsOfBookmarks2[
//                                 //             _bookmarks
//                                 //                 ._indexOf(
//                                 //                     "${e["surah"]}-$i")],
//                                 //       )));
//                                 // }
//                                 if (_bookmarks
//                                     .where((element) =>
//                                         element["suraNumber"] == e["surah"] &&
//                                         element["verseNumber"] == i)
//                                     .isNotEmpty) {
//                                   spans.add(WidgetSpan(
//                                       alignment: PlaceholderAlignment.middle,
//                                       child: Icon(
//                                         Icons.bookmark,
//                                         color: Color(int.parse(
//                                             "0x${_bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
//                                       )));
//                                 }
//                               }
//                               return spans;
//                             }).toList(),
//                           ),
//                         )),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else if (state is QuranPagePlayerPlaying) {
//           // print("last read ${getValue("lastRead")}");
//           // printYellow("playing");
//           return Column(
//             children: [
//               StreamBuilder(
//                   stream: state.audioPlayerStream,
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       final currentDuration = snapshot.data!.inMilliseconds;
//                       if (currentDuration !=
//                           state.durations[state.durations.length - 1]
//                               ["endDuration"]) {
//                         currentVersePlaying = state.durations.where((element) {
//                           return (element["startDuration"] <= currentDuration &&
//                               currentDuration <= element["endDuration"]);
//                         }).first;
//                       }
//
//                       // if( currentDuration ==
//                       //           state.durations[  state.durations.length-1]["endDuration"]){
//                       //             state.player.dispose();
//
//                       //           }
//                       // print(currentVersePlaying);
//                       return Directionality(
//                         textDirection: m.TextDirection.rtl,
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 20.0.w, vertical: 26.h),
//                           child: VisibilityDetector(
//                             key: Key(_index.toString()),
//                             onVisibilityChanged: (VisibilityInfo info) {
//                               if (info.visibleFraction == 1) {
//                                 updateValue("lastRead", _index);
//                               }
//                             },
//                             child: SizedBox(
//                                 width: double.infinity,
//                                 child: RichText(
//                                   key: richTextKeys[_index - 1],
//                                   textDirection: m.TextDirection.rtl,
//                                   textAlign: TextAlign.center,
//                                   softWrap: true,
//                                   //locale: const Locale("ar"),
//                                   text: TextSpan(
//                                     locale: const Locale("ar"),
//                                     children:
//                                         quran.getPageData(_index).expand((e) {
//                                       // print(e);
//                                       List<InlineSpan> spans = [];
//                                       for (var i = e["start"];
//                                           i <= e["end"];
//                                           i++) {
//                                         // Header
//                                         if (i == 1) {
//                                           spans.add(WidgetSpan(
//                                             child: HeaderWidget(
//                                                 e: e,
//                                                 jsonData: jsonData),
//                                           ));
//
//                                           if (_index != 187 && _index != 1) {
//                                             spans.add(WidgetSpan(
//                                                 child: Basmallah(
//                                               index: getValue(
//                                                   "quranPageolorsIndex"),
//                                             )));
//                                           }
//                                           if (_index == 187 || _index == 1) {
//                                             spans.add(WidgetSpan(
//                                                 child: Container(
//                                               height: 10.h,
//                                             )));
//                                           }
//                                         }
//
//                                         // Verses
//                                         spans.add(TextSpan(
//                                           locale: const Locale("ar"),
//                                           recognizer:
//                                               initLongPressGestureRecognizer(
//                                                   e: e, i: i, index: _index),
//                                           text: quran.getVerse(e["surah"], i),
//                                           style: TextStyle(
//                                             color: primaryColors[getValue(
//                                                 "quranPageolorsIndex")],
//                                             fontSize:
//                                                 getValue("verticalViewFontSize")
//                                                     .toDouble(),
//                                             // wordSpacing: -1.4,
//                                             fontFamily:
//                                                 getValue("selectedFontFamily"),
//                                             backgroundColor: _bookmarks
//                                                     .where((element) =>
//                                                         element["suraNumber"] == e["surah"] &&
//                                                         element["verseNumber"] ==
//                                                             i)
//                                                     .isNotEmpty
//                                                 ? Color(int.parse("0x${_bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
//                                                     .withOpacity(.19)
//                                                 : (i == currentVersePlaying["verseNumber"] &&
//                                                         e["surah"] ==
//                                                             state.suraNumber)
//                                                     ? highlightColors[getValue("quranPageolorsIndex")]
//                                                         .withOpacity(.28)
//                                                     : shouldHighlightText
//                                                         ? quran.getVerse(e["surah"], i) == widget.highlightVerse
//                                                             ? highlightColors[getValue("quranPageolorsIndex")]
//                                                                 .withOpacity(
//                                                                     .25)
//                                                             : selectedSpan ==
//                                                                     " ${e["surah"]}$i"
//                                                                 ? highlightColors[getValue("quranPageolorsIndex")]
//                                                                     .withOpacity(
//                                                                         .25)
//                                                                 : Colors
//                                                                     .transparent
//                                                         : selectedSpan ==
//                                                                 " ${e["surah"]}$i"
//                                                             ? highlightColors[getValue("quranPageolorsIndex")]
//                                                                 .withOpacity(.25)
//                                                             : Colors.transparent,
//                                           ),
//                                           children: [
//                                             TextSpan(
//                                                 text:
//                                                     " ${convertToArabicNumber((i).toString())} "
//                                                 //               quran.getVerseEndSymbol()
//                                                 ,
//                                                 style: TextStyle(
//                                                     color: isVerseStarred(
//                                                             e["surah"], i)
//                                                         ? Colors.amber
//                                                         : secondaryColors[getValue(
//                                                             "quranPageolorsIndex")],
//                                                     fontFamily:
//                                                         "KFGQPC Uthmanic Script HAFS Regular")),
//
//                                             //               ],
//                                             //             ),
//                                             //           ),
//                                             //         ),
//                                             //     ),
//                                             //     ),
//                                           ],
//                                         ));
//                                         if (_bookmarks
//                                             .where((element) =>
//                                                 element["suraNumber"] ==
//                                                     e["surah"] &&
//                                                 element["verseNumber"] == i)
//                                             .isNotEmpty) {
//                                           spans.add(WidgetSpan(
//                                               alignment:
//                                                   PlaceholderAlignment.middle,
//                                               child: Icon(
//                                                 Icons.bookmark,
//                                                 color: Color(int.parse(
//                                                     "0x${_bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
//                                               )));
//                                         }
//                                       }
//                                       return spans;
//                                     }).toList(),
//                                   ),
//                                 )),
//                           ),
//                         ),
//                       );
//                     } else if (snapshot.hasError) {
//                       return VisibilityDetector(
//                         key: Key(_index.toString()),
//                         onVisibilityChanged: (VisibilityInfo info) {
//                           if (info.visibleFraction == 1) {
//                             updateValue("lastRead", _index);
//                           }
//                         },
//                         child: Column(
//                           children: [
//                             Directionality(
//                               textDirection: m.TextDirection.rtl,
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 20.0.w, vertical: 26.h),
//                                 child: SizedBox(
//                                     width: double.infinity,
//                                     child: RichText(
//                                       key: richTextKeys[_index - 1],
//                                       textDirection: m.TextDirection.rtl,
//                                       textAlign: TextAlign.center,
//                                       softWrap: true,
//                                       //locale: const Locale("ar"),
//                                       text: TextSpan(
//                                         locale: const Locale("ar"),
//                                         children: quran
//                                             .getPageData(_index)
//                                             .expand((e) {
//                                           // print(e);
//                                           List<InlineSpan> spans = [];
//                                           for (var i = e["start"];
//                                               i <= e["end"];
//                                               i++) {
//                                             // Header
//                                             if (i == 1) {
//                                               spans.add(WidgetSpan(
//                                                 child: HeaderWidget(
//                                                     e: e,
//                                                     jsonData: jsonData),
//                                               ));
//
//                                               if (_index != 187 && _index != 1) {
//                                                 spans.add(WidgetSpan(
//                                                     child: Basmallah(
//                                                   index: getValue(
//                                                       "quranPageolorsIndex"),
//                                                 )));
//                                               }
//                                               if (_index == 187 || _index == 1) {
//                                                 spans.add(WidgetSpan(
//                                                     child: Container(
//                                                   height: 10.h,
//                                                 )));
//                                               }
//                                             }
//
//                                             // Verses
//                                             spans.add(TextSpan(
//                                               locale: const Locale("ar"),
//                                               recognizer:
//                                                   initLongPressGestureRecognizer(e: e, i: i, index: _index),
//                                               text: quran.getVerse(e["surah"], i),
//                                               style: TextStyle(
//                                                 color: primaryColors[getValue("quranPageolorsIndex")],
//                                                 fontSize: getValue("verticalViewFontSize").toDouble(),
//                                                 // wordSpacing: -1.4,
//                                                 fontFamily: getValue("selectedFontFamily"),
//                                                 backgroundColor: _bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).isNotEmpty
//                                                     ? Color(int.parse("0x${_bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
//                                                     : shouldHighlightText
//                                                         ? quran.getVerse(e["surah"], i) ==
//                                                                 widget
//                                                                     .highlightVerse
//                                                             ? highlightColors[getValue("quranPageolorsIndex")]
//                                                                 .withOpacity(
//                                                                     .25)
//                                                             : selectedSpan ==
//                                                                     " ${e["surah"]}$i"
//                                                                 ? highlightColors[getValue("quranPageolorsIndex")]
//                                                                     .withOpacity(
//                                                                         .25)
//                                                                 : Colors
//                                                                     .transparent
//                                                         : selectedSpan ==
//                                                                 " ${e["surah"]}$i"
//                                                             ? highlightColors[getValue(
//                                                                     "quranPageolorsIndex")]
//                                                                 .withOpacity(.25)
//                                                             : Colors.transparent,
//                                               ),
//                                               children: [
//                                                 TextSpan(
//                                                     text:
//                                                         " ${convertToArabicNumber((i).toString())} "
//                                                     //               quran.getVerseEndSymbol()
//                                                     ,
//                                                     style: TextStyle(
//                                                         color: isVerseStarred(
//                                                                 e["surah"], i)
//                                                             ? Colors.amber
//                                                             : secondaryColors[
//                                                                 getValue(
//                                                                     "quranPageolorsIndex")],
//                                                         fontFamily:
//                                                             "KFGQPC Uthmanic Script HAFS Regular")),
//
//                                                 //               ],
//                                                 //             ),
//                                                 //           ),
//                                                 //         ),
//                                                 //     ),
//                                                 //     ),
//                                               ],
//                                             ));
//                                             if (_bookmarks
//                                                 .where((element) =>
//                                                     element["suraNumber"] ==
//                                                         e["surah"] &&
//                                                     element["verseNumber"] == i)
//                                                 .isNotEmpty) {
//                                               spans.add(WidgetSpan(
//                                                   alignment:
//                                                       PlaceholderAlignment
//                                                           .middle,
//                                                   child: Icon(
//                                                     Icons.bookmark,
//                                                     color: Color(int.parse(
//                                                         "0x${_bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
//                                                   )));
//                                             }
//                                           }
//                                           return spans;
//                                         }).toList(),
//                                       ),
//                                     )),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ); // print("snapshot.hasError");
//                       // print(snapshot.error);
//                     }
//
//                     return Container();
//                   }),
//
//             ],
//           );
//         }
//         return Container();
//       },
//     );
//   }
// }
