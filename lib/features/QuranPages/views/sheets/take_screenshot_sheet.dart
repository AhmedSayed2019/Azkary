import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/QuranPages/helpers/remove_html_tags.dart';
import 'package:azkark/features/QuranPages/helpers/translation/translationdata.dart';
import 'package:azkark/features/QuranPages/views/screenshot_preview.dart';
import 'package:azkark/features/QuranPages/widgets/easy_container.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';

import '../../../../widgets/dialog/base/simple_dialogs.dart';
import '../../helpers/translation/get_translation_data.dart' as translate;

Future<void> showTakeScreenshotSheet({
  required BuildContext context,
  required int index,
  required int surahNumber,
  required int verseNumber,
  required dynamic jsonData,
  required bool isDownloading,
  required Function(dynamic) onUpdateDataOfCurrentTranslation,
}) async {
  try {

   await  showCustomDialog(
      // animationType: DialogTransitionType.size,
       context,  _TakeScreenshotSheet(
        index: index,
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        jsonData: jsonData,
        isDownloading: isDownloading,
        onUpdateDataOfCurrentTranslation: onUpdateDataOfCurrentTranslation,
      ), onDismissCallback: (){},
    );
  } catch (e) {
    debugPrint('Error taking screenshot: $e');
    Fluttertoast.showToast(msg: 'Error taking screenshot');
  }
}

class _TakeScreenshotSheet extends StatefulWidget {
  final int _index;
  final int _surahNumber;
  final int _verseNumber;
  final dynamic _jsonData;
  final bool _isDownloading;
  final Function(dynamic) _onUpdateDataOfCurrentTranslation;

  _TakeScreenshotSheet({
    required int index,
    required int surahNumber,
    required int verseNumber,
    required dynamic jsonData,

    required bool isDownloading,
    required Function(dynamic) onUpdateDataOfCurrentTranslation,
  })  : _index = index,
        _surahNumber = surahNumber,
        _isDownloading = isDownloading,
        _onUpdateDataOfCurrentTranslation = onUpdateDataOfCurrentTranslation,

        _verseNumber = verseNumber,
        _jsonData = jsonData;

  @override
  State<_TakeScreenshotSheet> createState() => _TakeScreenshotSheetState();
}

class _TakeScreenshotSheetState extends State<_TakeScreenshotSheet> {
  Directory? _appDir;
 late  int _firstVerse ;
 late  int _lastVerse ;
  _onDownload(setstatter, i) async {
    if (widget._isDownloading != translationDataList[i].url) {
      if (File("${_appDir!.path}/${translationDataList[i].typeText}.json").existsSync() || i == 0 || i == 1) {
        updateValue("addTafseerValue", i);
        setState(() {});
        setstatter(() {});
      } else {
        PermissionStatus status = await Permission.storage.request();
        PermissionStatus status2 = await Permission.manageExternalStorage.request();

        if (status.isGranted && status2.isGranted) {
        } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
          await openAppSettings();
        } else if (status.isDenied) {

        }
        await Dio().download(translationDataList[i].url, "${_appDir!.path}/${translationDataList[i].typeText}.json");
      }
      _getTranslationData();
      updateValue("addTafseerValue", i);
      setState(() {});
      setstatter(() {});
    }

    setState(() {});
    if (mounted) {
      setstatter(() {});
      Navigator.pop(context);
      setstatter(() {});
    }
    setstatter(() {});
  }

  _getTranslationData() async {
    if (getValue("indexOfTranslationInVerseByVerse") > 1) {
      File file = File("${_appDir!.path}/${translationDataList[getValue("indexOfTranslationInVerseByVerse")].typeText}.json");

      String jsonData = await file.readAsString();
      widget._onUpdateDataOfCurrentTranslation(json.decode(jsonData));
    }
    setState(() {});
  }

  initialize() async {
     _firstVerse = widget._verseNumber;
     _lastVerse = widget._verseNumber;
    _appDir = await getTemporaryDirectory();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    initialize();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setstatter) {
      return Dialog(
        // title: const Text('Share Ayah'),
        backgroundColor: backgroundColors[getValue("quranPageolorsIndex")],

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 20),
                Text("share".tr(), textAlign: TextAlign.left, style: TextStyle(color: primaryColors[getValue("quranPageolorsIndex")], fontWeight: FontWeight.w700, fontSize: 20.0 )),
              ],
            ),
            const SizedBox(height: 20.0), // Add spacing at the top
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('fromayah'.tr(), style: TextStyle(color: primaryColors[getValue("quranPageolorsIndex")], fontSize: 16.0, )),
                const SizedBox(width: 10.0),
                DropdownButton<int>(
                  dropdownColor:
                  backgroundColors[getValue("quranPageolorsIndex")],
                  value: _firstVerse,
                  onChanged: (newValue) {
                    if (newValue! > _lastVerse) {
                      setState(() {_lastVerse = newValue;});
                      setstatter(() {});
                    }
                    setState(() {_firstVerse = newValue;});
                    setstatter(() {});
                    // Handle dropdown selection
                  },
                  items: List.generate(
                    quran.getVerseCount(widget._surahNumber),
                        (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: primaryColors[
                          getValue("quranPageolorsIndex")],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20.0),
                Text('toayah'.tr(), style: TextStyle(color: primaryColors[getValue("quranPageolorsIndex")], fontSize: 16.0,)),
                const SizedBox(width: 10.0),
                DropdownButton<int>(
                  dropdownColor:
                  backgroundColors[getValue("quranPageolorsIndex")],
                  value: _lastVerse,
                  onChanged: (newValue) {
                    if (newValue! > _firstVerse) {
                      setState(() {_lastVerse = newValue;});
                      setstatter(() {});
                    }
                    // Handle dropdown selection
                  },
                  items: List.generate(
                    quran.getVerseCount(widget._surahNumber),
                        (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: primaryColors[
                          getValue("quranPageolorsIndex")],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0), // Add spacing between rows
            RadioListTile(
              activeColor: highlightColors[getValue("quranPageolorsIndex")],
              // fillColor: MaterialStatePropertyAll(primaryColors[getValue("quranPageolorsIndex")]),TODO removed
              title: Text(
                'asimage'.tr(),
                style: TextStyle(
                  color: primaryColors[getValue("quranPageolorsIndex")],
                ),
              ),
              value: 0,
              groupValue: getValue("selectedShareTypeIndex"),
              onChanged: (value) {
                updateValue("selectedShareTypeIndex", value);
                setState(() {});
                setstatter(() {});
              },
            ),
            RadioListTile(
              activeColor: highlightColors[getValue("quranPageolorsIndex")],

              // fillColor: MaterialStatePropertyAll(primaryColors[getValue("quranPageolorsIndex")]), //TODO removed
              title: Text(
                'astext'.tr(),
                style: TextStyle(
                  color: primaryColors[getValue("quranPageolorsIndex")],
                ),
              ),
              value: 1,
              groupValue: getValue("selectedShareTypeIndex"),
              onChanged: (value) {
                updateValue("selectedShareTypeIndex", value);
                setState(() {});
                setstatter(() {});
              },
            ),
            if (getValue("selectedShareTypeIndex") == 1)
              Row(
                children: [
                  Checkbox(
                    fillColor: WidgetStatePropertyAll(
                        primaryColors[getValue("quranPageolorsIndex")]),
                    checkColor:
                    backgroundColors[getValue("quranPageolorsIndex")],
                    value: getValue("textWithoutDiacritics"),
                    onChanged: (newValue) {
                      updateValue("textWithoutDiacritics", newValue);
                      setState(() {});
                      setstatter(() {});
                    },
                  ),
                  Text(
                    'withoutdiacritics'.tr(),
                    style: TextStyle(
                      color: primaryColors[getValue("quranPageolorsIndex")],
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),

            // if (getValue("selectedShareTypeIndex") == 0)
            Row(
              children: [
                Checkbox(
                  fillColor: WidgetStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  checkColor:
                  backgroundColors[getValue("quranPageolorsIndex")],
                  value: getValue("addAppSlogan"),
                  onChanged: (newValue) {
                    updateValue("addAppSlogan", newValue);

                    setState(() {});
                    setstatter(() {});
                  },
                ),
                Text(
                  'addappname'.tr(),
                  style: TextStyle(
                    color: primaryColors[getValue("quranPageolorsIndex")],
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  fillColor: WidgetStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  checkColor:
                  backgroundColors[getValue("quranPageolorsIndex")],
                  value: getValue("addTafseer"),
                  onChanged: (newValue) {
                    updateValue("addTafseer", newValue);

                    setState(() {});
                    setstatter(() {});
                  },
                ),
                Text(
                  'addtafseer'.tr(),
                  style: TextStyle(
                    color: primaryColors[getValue("quranPageolorsIndex")],
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            if (getValue("addTafseer") == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20.w,
                  ),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showMaterialModalBottomSheet(
                              enableDrag: true,
                              animationCurve: Curves.easeInOutQuart,
                              elevation: 0,
                              bounce: true,
                              duration: const Duration(milliseconds: 150),
                              backgroundColor: backgroundColor,
                              context: context,
                              builder: (builder) {
                                return Directionality(
                                  textDirection: ui.TextDirection.rtl,
                                  child: SizedBox(
                                    height:
                                    MediaQuery.of(context).size.height *
                                        .8,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Text(
                                            "choosetranslation".tr(),
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 22.sp,
                                                fontFamily: context.locale
                                                    .languageCode ==
                                                    "ar"
                                                    ? "cairo"
                                                    : "roboto"),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.separated(
                                              separatorBuilder:
                                              ((context, index) {
                                                return const Divider();
                                              }),
                                              itemCount: translationDataList.length,
                                              itemBuilder: (c, i) {
                                                return Container(
                                                  color: i == getValue("addTafseerValue") ? Colors.blueGrey.withOpacity(.1) : Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () => _onDownload(setstatter, i),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 18.0.w, vertical: 2.h),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(translationDataList[i].typeTextInRelatedLanguage, style: TextStyle(color: primaryColor.withOpacity(.9), fontSize: 14.sp)),
                                                          widget._isDownloading /*!= translationDataList[i].url*/ ? Icon(i == 0 || i == 1 ? MfgLabs.hdd : File("${_appDir!.path}/${translationDataList[i].typeText}.json").existsSync() ? Icons.done : Icons.cloud_download, color: Colors.blueAccent, size: 18.sp,)
                                                              : const CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          height: 40.h,
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 14.0.w),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  translationDataList[getValue("addTafseerValue") ?? 0].typeTextInRelatedLanguage,
                                  style: TextStyle(color: Colors.black, fontFamily: translationDataList[getValue("addTafseerValue") ?? 0].typeInNativeLanguage == "العربية" ? "cairo" : "roboto"),
                                ),
                                Icon(
                                  FontAwesome.ellipsis,
                                  size: 24.sp,
                                  color: secondaryColors[
                                  getValue("quranPageolorsIndex")],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (getValue("selectedShareTypeIndex") == 1)
              Padding(
                padding: const EdgeInsets.all(12),
                child: EasyContainer(
                    onTap: () async {
                      if (getValue("selectedShareTypeIndex") == 1) {
                        List verses = [];
                        for (int i = _firstVerse; i <= _lastVerse; i++) {
                          verses.add(quran.getVerse(widget._surahNumber, i, verseEndSymbol: true));
                        }
                          String tafseer = "";
                          for (int verseNumber = _firstVerse; verseNumber <= _lastVerse; verseNumber++) {
                            String translation = await translate.getVerseTranslation(widget._surahNumber, verseNumber, translationDataList[getValue("addTafseerValue")]);
                            tafseer = "$tafseer $translation";
                          }
                        if (getValue("textWithoutDiacritics")) {
                          if (getValue("addTafseer")) {
                            Share.share("{${quran.removeDiacritics(verses.join(''))}} [${quran.getSurahNameArabic(widget._surahNumber)}: $_firstVerse : $_lastVerse]\n\n${removeHtmlTags(quran.removeDiacritics(tafseer))}\n\n${getValue("addAppSlogan") ? "Shared with Azkar - faithful companion" : ""}");
                          } else {
                            Share.share("{${quran.removeDiacritics(verses.join(''))}} [${quran.getSurahNameArabic(widget._surahNumber)}: $_firstVerse : $_lastVerse]${getValue("addAppSlogan") ? "Shared with Azkar - faithful companion" : ""}");
                          }
                        } else {
                          if (getValue("addTafseer")) {
                            Share.share("{${verses.join('')}} [${quran.getSurahNameArabic(widget._surahNumber)}: $_firstVerse : $_lastVerse]\n\n${translationDataList[getValue("addTafseerValue")].typeTextInRelatedLanguage}:\n${removeHtmlTags(tafseer)}\n\n${getValue("addAppSlogan") ? "Shared with Azkar" : ""}");
                          } else {
                            Share.share("{${verses.join('')}} [${quran.getSurahNameArabic(widget._surahNumber)}: $_firstVerse : $_lastVerse]${getValue("addAppSlogan") ? "Shared with Azkar" : ""}");
                          }
                        }
                      }
                    },
                    color: primaryColors[getValue("quranPageolorsIndex")],
                    child: Text("astext".tr(),
                      style: TextStyle(color: backgroundColors[getValue("quranPageolorsIndex")]),
                    )),
              ),
            if (getValue("selectedShareTypeIndex") == 0)
              Padding(
                padding:
                const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: EasyContainer(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => ScreenShotPreviewPage(
                                  index: widget._index,
                                  isQCF: getValue("alignmentType") == "pageview",
                                  surahNumber: widget._surahNumber,
                                  jsonData: widget._jsonData,
                                  firstVerse: _firstVerse,
                                  lastVerse: _lastVerse)));
                    },
                    color: primaryColors[getValue("quranPageolorsIndex")],
                    child: Text("preview".tr(), style: TextStyle(color: backgroundColors[getValue("quranPageolorsIndex")]),)),
              )
          ],
        ),
      );
    });
  }
}
