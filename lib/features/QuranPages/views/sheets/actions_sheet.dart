import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/QuranPages/bloc/player_bloc_bloc.dart';
import 'package:azkark/features/QuranPages/bloc/quran_page_player_bloc.dart';
import 'package:azkark/features/QuranPages/models/reciter.dart';
import 'package:azkark/features/QuranPages/views/download_helper.dart';
import 'package:azkark/features/QuranPages/views/sheets/take_screenshot_sheet.dart';
import 'package:azkark/features/QuranPages/widgets/bookmark_dialog.dart';
import 'package:azkark/features/QuranPages/widgets/easy_container.dart';
import 'package:azkark/features/QuranPages/widgets/tafseer_and_translation_sheet.dart';
import 'package:azkark/features/home/home_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran/quran.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../widgets/dialog/base/simple_dialogs.dart';

showAyahOptionsSheet({
  required context,
  required int index,
  required int surahNumber,
  required int verseNumber,
  required dynamic dataOfCurrentTranslation,
  required Function(dynamic) onUpdateDataOfCurrentTranslation,
  required List<GlobalKey> richTextKeys,
  required List bookmarks,
  required bool isDownloading,
  required dynamic jsonData,
  required List<QuranPageReciter> reciters,
  required Directory? appDir,
  required ItemScrollController itemScrollController,
}) =>
    showMaterialModalBottomSheet(
        enableDrag: true,
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.transparent,
        context: context,
        animationCurve: Curves.easeInOutQuart,
        elevation: 0,
        bounce: true,
        builder: (c) => _ActionsSheet(
            index: index,
            reciters: reciters,
          isDownloading: isDownloading,
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            jsonData: jsonData,
            richTextKeys: richTextKeys,
            itemScrollController: itemScrollController,
          onUpdateDataOfCurrentTranslation: onUpdateDataOfCurrentTranslation,
            bookmarks: bookmarks,
            appDir: appDir, dataOfCurrentTranslation: dataOfCurrentTranslation,));

class _ActionsSheet extends StatefulWidget {
  final int _index;
  final int _surahNumber;
  final int _verseNumber;
  final dynamic _dataOfCurrentTranslation;
  final Function(dynamic) _onUpdateDataOfCurrentTranslation;
  final List<GlobalKey> _richTextKeys;
  final List _bookmarks;
  final dynamic _jsonData;
  final bool _isDownloading;
  final List<QuranPageReciter> _reciters;
  final Directory? _appDir;
  final ItemScrollController _itemScrollController;


  @override
  State<_ActionsSheet> createState() => _ActionsSheetState();

  const _ActionsSheet({
    required int index,
    required int surahNumber,
    required int verseNumber,
    required dynamic dataOfCurrentTranslation,
    required Function(dynamic) onUpdateDataOfCurrentTranslation,
    required List<GlobalKey> richTextKeys,
    required List bookmarks,
    required dynamic jsonData,
    required bool isDownloading,
    required List<QuranPageReciter> reciters,
    required Directory? appDir,
    required ItemScrollController itemScrollController,
  })  : _index = index,
        _surahNumber = surahNumber,
        _verseNumber = verseNumber,
        _dataOfCurrentTranslation = dataOfCurrentTranslation,
        _onUpdateDataOfCurrentTranslation = onUpdateDataOfCurrentTranslation,
        _richTextKeys = richTextKeys,
        _bookmarks = bookmarks,
        _isDownloading = isDownloading,
        _jsonData = jsonData,
        _reciters = reciters,
        _appDir = appDir,
        _itemScrollController = itemScrollController;
}

class _ActionsSheetState extends State<_ActionsSheet> {
  late Future<List<Uint8List>> dashFramesFuture;
  late DownloadHelper _downloadHelper;

  @override
  void initState() {
    _downloadHelper=Provider.of<DownloadHelper>(context,listen: false);
    // _downloadHelper.init();
    super.initState();
  }


  Set<String> starredVerses = {};
  List bookmarks = [];



  fetchBookmarks() {
    bookmarks = json.decode(getValue("bookmarks"));
    setState(() {});
    // print(bookmarks);
  }

  bool isVerseStarred(int surahNumber, int verseNumber) {
    final verseKey = "$surahNumber-$verseNumber";
    return starredVerses.contains(verseKey);
  }

  removeStarredVerse(int surahNumber, int verseNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data as a string, not as a map
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      // Decode the JSON string to a List<String>
      starredVerses = Set<String>.from(json.decode(savedData));
    }

    final verseKey = "$surahNumber-$verseNumber"; // Create the same unique key
    starredVerses.remove(verseKey);

    final jsonData = json.encode(
        starredVerses.toList()); // Convert Set to List for serialization
    prefs.setString("starredVerses", jsonData);
    Fluttertoast.showToast(msg: "Removed from Starred verses");
  }

   addStarredVerse(int surahNumber, int verseNumber) async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();

     // Retrieve the data as a string, not as a map
     final String? savedData = prefs.getString("starredVerses");

     if (savedData != null) {
       // Decode the JSON string to a List<String>
       starredVerses = Set<String>.from(json.decode(savedData));
     }

     final verseKey = "$surahNumber-$verseNumber"; // Create a unique key
     starredVerses.add(verseKey);

     final jsonData = json.encode(
         starredVerses.toList()); // Convert Set to List for serialization
     prefs.setString("starredVerses", jsonData);
     Fluttertoast.showToast(msg: "Added to Starred verses");
   }


  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setstatee) => Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColors[getValue("quranPageolorsIndex")],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    "${context.locale.languageCode == "ar" ? quran.getSurahNameArabic(widget._surahNumber) : quran.getSurahNameEnglish(widget._surahNumber)}: ${widget._verseNumber}",
                    style: TextStyle(
                        color: primaryColors[
                        getValue("quranPageolorsIndex")]),
                  ),
                  trailing: SizedBox(
                    width: 200.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              isVerseStarred(widget._surahNumber, widget._verseNumber)
                                  ? removeStarredVerse(
                                  widget._surahNumber, widget._verseNumber)
                                  : addStarredVerse(
                                  widget._surahNumber, widget._verseNumber);
                              setstatee(() {});
                              setState(() {});
                              widget._richTextKeys[widget._index - 1]
                                  .currentState
                                  ?.build(context);
                            },
                            icon: Icon(
                              isVerseStarred(widget._surahNumber, widget._verseNumber)
                                  ? FontAwesome.star
                                  : FontAwesome.star_empty,
                              color: primaryColors[
                              getValue("quranPageolorsIndex")],
                            )),
                        // widget._index, widget._surahNumber, widget._verseNumber
                        IconButton(
                            onPressed: () => showTakeScreenshotSheet(
                                context: context,
                                index:  widget._index,
                                surahNumber: widget._surahNumber,
                                verseNumber: widget._verseNumber,
                                jsonData: widget._jsonData,
                                isDownloading: widget._isDownloading,
                                onUpdateDataOfCurrentTranslation: widget._onUpdateDataOfCurrentTranslation,
                            ),
                            icon: Icon(Icons.share,
                                color: primaryColors[
                                getValue("quranPageolorsIndex")])),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 10.h,
                  color: primaryColors[getValue("quranPageolorsIndex")],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: primaryColors[getValue("quranPageolorsIndex")].withOpacity(.05)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget._bookmarks.isNotEmpty)
                            ListView.separated(
                                separatorBuilder: (context, index) =>
                                const Divider(),
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemCount: widget._bookmarks.length,
                                itemBuilder: (c, i) {
                                  return GestureDetector(
                                    // color: Colors.transparent,
                                    onTap: () async {
                                      List bookmarks = json.decode(
                                          getValue("bookmarks"));

                                      bookmarks[i]["verseNumber"] =
                                          widget._verseNumber;

                                      bookmarks[i]["suraNumber"] =
                                          widget._surahNumber;

                                      updateValue("bookmarks",
                                          json.encode(bookmarks));
                                      // print(getValue("bookmarks"));
                                      setState(() {});
                                      fetchBookmarks();
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          Icon(
                                            Icons.bookmark,
                                            color: Color(int.parse(
                                                "0x${widget._bookmarks[i]["color"]}")),
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          Text(widget._bookmarks[i]["name"],
                                              style: TextStyle(
                                                  fontFamily: "cairo",
                                                  fontSize: 14.sp,
                                                  color: primaryColors[
                                                  getValue(
                                                      "quranPageolorsIndex")])),
                                          SizedBox(
                                            width: 30.w,
                                          ),
                                          // if (getValue("redBookmark") != null)
                                          Expanded(
                                            child: Align(
                                              alignment:
                                              Alignment.centerRight,
                                              child: Text(
                                                  getVerse(
                                                    int.parse(widget._bookmarks[
                                                    i][
                                                    "suraNumber"]
                                                        .toString()),
                                                    int.parse(widget._bookmarks[
                                                    i][
                                                    "verseNumber"]
                                                        .toString()),
                                                  ),
                                                  textDirection: m
                                                      .TextDirection
                                                      .rtl,
                                                  style: TextStyle(
                                                      fontFamily:
                                                      fontFamilies[
                                                      0],
                                                      fontSize: 13.sp,
                                                      color: primaryColors[
                                                      getValue(
                                                          "quranPageolorsIndex")],
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis)),
                                            ),
                                          ),

                                          IconButton(
                                              onPressed: () {
                                                //  String bookmarkName = _nameController.text;
                                                // TODO: Perform actions with bookmarkName and _selectedColor
                                                List bookmarks = json
                                                    .decode(getValue(
                                                    "bookmarks"));
                                                // String hexCode =
                                                //     _selectedColor.value.toRadixString(16).padLeft(8, '0');
                                                Fluttertoast.showToast(
                                                    msg:
                                                    "${bookmarks[i]["name"]} removed");

                                                bookmarks.removeWhere(
                                                        (e) =>
                                                    e["color"] ==
                                                        bookmarks[i]
                                                        ["color"]);
                                                updateValue(
                                                    "bookmarks",
                                                    json.encode(
                                                        bookmarks));
                                                // print(getValue("bookmarks"));
                                                setState(() {});
                                                fetchBookmarks();
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Color(int.parse(
                                                    "0x${widget._bookmarks[i]["color"]}")),
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          if (widget._bookmarks.isNotEmpty) const Divider(),
                          //newBookmark
                          _buildItem(
                              backgroundColor: Colors.transparent,
                              title: "newBookmark".tr(),
                              icon:  Icons.bookmark_add,
                              onTap: () async {
                                await showCustomDialog(
                                     context,
                                    BookmarksDialog(suraNumber: widget._surahNumber, verseNumber: widget._verseNumber), onDismissCallback: (){});
                             // await showAnimatedDialog(
                             //        context: context,
                             //        builder: (context) => BookmarksDialog(suraNumber: widget._surahNumber, verseNumber: widget._verseNumber));

                                fetchBookmarks();
                              },
                              ediWidget:  (getValue("redBookmark") != null)?
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      getVerse(int.parse(getValue("redBookmark").toString().split('-')[0]), int.parse(getValue("redBookmark").toString().split('-')[1])),
                                      textDirection:
                                      m.TextDirection.rtl,
                                      style: TextStyle(fontFamily: fontFamilies[0], fontSize: 13.sp, color: primaryColors[getValue("quranPageolorsIndex")], overflow: TextOverflow.ellipsis)
                                  ),
                                ),
                              ):null
                          ),
                          // SizedBox(height: 10.h),

                          // EasyContainer(
                          //   color: Colors.transparent,
                          //   onTap: () async {
                          //     await showAnimatedDialog(context: context, builder: (context) => BookmarksDialog(suraNumber: widget._surahNumber, verseNumber: widget._verseNumber,));
                          //     fetchBookmarks();
                          //   },
                          //   child: SizedBox(
                          //     width: MediaQuery.of(context).size.width,
                          //     child: Row(
                          //       children: [
                          //         SizedBox(width: 16.w),
                          //         Icon(Icons.bookmark_add, color: secondaryColors[getValue("quranPageolorsIndex")]),
                          //         SizedBox(width: 16.w),
                          //         Text("newBookmark".tr(), style: TextStyle(fontFamily: "cairo", fontSize: 14.sp, color: primaryColors[getValue("quranPageolorsIndex")])),
                          //         SizedBox(width: 16.w),
                          //         if (getValue("redBookmark") != null)
                          //           Expanded(
                          //             child: Align(
                          //               alignment: Alignment.centerRight,
                          //               child: Text(
                          //                   getVerse(int.parse(getValue("redBookmark").toString().split('-')[0]), int.parse(getValue("redBookmark").toString().split('-')[1])),
                          //                   textDirection:
                          //                   m.TextDirection.rtl,
                          //                   style: TextStyle(fontFamily: fontFamilies[0], fontSize: 13.sp, color: primaryColors[getValue("quranPageolorsIndex")], overflow: TextOverflow.ellipsis)
                          //               ),
                          //             ),
                          //           )
                          //       ],
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                //التفسير - الترجمة
                _buildItem(
                  title: "${"tafseer".tr()} - ${"translation".tr()}",
                  icon:  FontAwesome5.book_open,
                  onTap: () =>showMaterialModalBottomSheet(
                      enableDrag: true,
                      // backgroundColor: Colors.transparent,
                      context: context,
                      animationCurve: Curves.easeInOutQuart,
                      elevation: 0,
                      bounce: true,
                      duration: const Duration(milliseconds: 400),
                      backgroundColor: backgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(13.r), topLeft: Radius.circular(13.r))),
                      isDismissible: true,
                      // constraints: BoxConstraints.expand(
                      //   height: MediaQuery.of(context).size.height,
                      // ),
                      builder: (d) {
                        return TafseerAndTranslateSheet(
                            surahNumber: widget._surahNumber,
                            isVerseByVerseSelection: false,
                            verseNumber: widget._verseNumber);
                      }),
                ),
                SizedBox(height: 10.h),
                _buildItem(
                    title: "play".tr(),
                    icon:  FontAwesome5.book_reader,
                    onTap: () async {
                      Navigator.pop(context);
                      await _downloadHelper.downloadAndCacheSuraAudio(quran.getSurahNameEnglish(widget._surahNumber), quran.getVerseCount(widget._surahNumber), widget._surahNumber, widget._reciters[getValue("reciterIndex")].identifier);

                      if (playerPageBloc.state is PlayerBlocPlaying) {
                        if (mounted) {
                          await showDialog(context: context,
                              builder: (a) {
                                return AlertDialog(
                                  content: Text("closeplayer".tr()),
                                  actions: [
                                    TextButton(onPressed: () =>Navigator.pop(context), child: Text("back".tr())),
                                    TextButton(
                                      onPressed: () {
                                        playerPageBloc.add(ClosePlayerEvent());
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("close".tr()),
                                    ),
                                  ],
                                );
                              });
                        }
                      }
                      if (qurapPagePlayerBloc.state
                      is QuranPagePlayerPlaying) {
                        qurapPagePlayerBloc.add(KillPlayerEvent());
                      }

                      qurapPagePlayerBloc.add(PlayFromVerse(widget._verseNumber, widget._reciters[getValue("reciterIndex")].identifier, widget._surahNumber, quran.getSurahNameEnglish(widget._surahNumber)));
                      if (getValue("alignmentType") == "verticalview" && quran.getPageNumber(widget._surahNumber, widget._verseNumber) > 600) {
                        await Future.delayed(const Duration(milliseconds: 1000));
                        widget._itemScrollController.jumpTo(index: quran.getPageNumber(widget._surahNumber, widget._verseNumber));
                      }
                    },
                    ediWidget:  Expanded(child: DropdownButton<int>(
                      value: getValue("reciterIndex"),
                      dropdownColor: backgroundColors[getValue("quranPageolorsIndex")],
                      onChanged: (int? newIndex) {
                        updateValue("reciterIndex", newIndex);
                        setState(() {});
                        setstatee(() {});
                      },
                      items: widget._reciters.map((reciter) {
                        return DropdownMenuItem<int>(
                          value: widget._reciters.indexOf(reciter),
                          child: Text(context.locale.languageCode == "ar" ? reciter.name : reciter.englishName, style: TextStyle(fontSize: 14.sp,color: primaryColors[getValue("quranPageolorsIndex")])),
                        );
                      }).toList(),
                    ),)
                ),


                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 5.h,
                ),
              ],
            ),
          )),
    );
  }
  _buildItem({required String title , Color? backgroundColor ,required IconData icon ,required VoidCallback onTap ,Widget? ediWidget  })=>  EasyContainer(
    borderRadius: 8,
    color: backgroundColor?? primaryColors[getValue("quranPageolorsIndex")].withOpacity(.05),
    onTap:onTap,
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(
            icon,
            color: getValue("quranPageolorsIndex") == 0 ? secondaryColors[getValue("quranPageolorsIndex")] : highlightColors[getValue("quranPageolorsIndex")],
          ),
          SizedBox(width: 16.w),
          Text(title, style: TextStyle(fontFamily: "cairo", fontSize: 14.sp, color: primaryColors[getValue("quranPageolorsIndex")])),
          SizedBox(width: 16.w),
          if(ediWidget!=null)ediWidget
        ],
      ),
    ),
  );
}
