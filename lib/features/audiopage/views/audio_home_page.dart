import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/QuranPages/widgets/easy_container.dart';
import 'package:azkark/features/audiopage/models/reciter.dart';
import 'package:azkark/features/audiopage/views/widgets/audio_cart_item.dart';
import 'package:azkark/generated/assets.dart';
import 'package:azlistview_plus/azlistview_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_annimated_staggered/simple_annimated_staggered.dart'; // import this

class RecitersPage extends StatefulWidget {
  const RecitersPage({super.key});
  @override
  _RecitersPageState createState() => _RecitersPageState();


}

class _RecitersPageState extends State<RecitersPage> {
  late List<Reciter> reciters;
  bool isLoading = true;
  late Dio dio;
  late List<Reciter> favoriteRecitersList;

  @override
  void initState() {
    super.initState();
    reciters = [];
    dio = Dio();
    getFavoriteList();
    fetchReciters();
  }

  List<String>? getLettersForLocale(String locale) {
    for (var language in languagesLetters) {
      if (language.containsKey(locale)) {
        return language[locale];
      }
    }
    // Return an empty list or handle the case where the locale is not found.
    return [];
  }

  getFavoriteList() {
    var jsonData = getValue("favoriteRecitersList");
    if (jsonData != null) {
      final data = json.decode(jsonData) as List<dynamic>;

      setState(() {
        favoriteRecitersList = data.map((reciterJson) {
          final matches = reciters.where((element) => element.id == reciterJson);
          if (matches.isNotEmpty) {
            return matches.first;
          }
          return null; // or handle default case
        }).whereType<Reciter>().toList();
        // favoriteRecitersList = data
        //     .map((reciterJson) => reciters.where((element) => element.id == reciterJson).first)
        //     .toList();
        isLoading = false;
      });
    }
  }

  final ContainerTransitionType _transitionType =
      ContainerTransitionType.fadeThrough;
  List<Reciter> filteredReciters = []; // Store the filtered list
  List<Moshaf> rewayat = [];
  List suwar = []; // Store

  getAndStoreRecitersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await Dio().get('http://mp3quran.net/api/v3/reciters?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
      final response2 = await Dio().get('http://mp3quran.net/api/v3/moshaf?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
      final response3 = await Dio().get('http://mp3quran.net/api/v3/suwar?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');

      if (response.data != null) {
        final jsonData = json.encode(response.data['reciters']);
        prefs.setString("reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}", jsonData);
      }
      if (response2.data != null) {
        final jsonData2 = json.encode(response2.data);
        prefs.setString("moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}", jsonData2);
      }
      if (response3.data != null) {
        final jsonData3 = json.encode(response3.data['suwar']);
        prefs.setString("suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}", jsonData3);
      }
    } catch (error) {
      print('Error while storing data: $error');
    }
  }

  Future<void> fetchReciters() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString(
              "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") ==
          null) {
            
        await getAndStoreRecitersData();
      }

      // print(prefs.getString(
      //         "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}"));

      final jsonData = prefs.getString("reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}");
      final jsonData2 = prefs.getString("moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}");
      final jsonData3 = prefs.getString("suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}");
// print(jsonData);
print(jsonData2);
// print(jsonData3);

      if (jsonData != null) {
        final data = json.decode(jsonData) as List<dynamic>;
        final data2 = json.decode(jsonData2!)["riwayat"] as List<dynamic>;

        final data3 = json.decode(jsonData3!) as List<dynamic>;
        print(json.decode(jsonData3));
        reciters = data.map((reciter) => Reciter.fromJson(reciter)).toList();
        reciters
            .sort((a, b) => a.letter.toString().compareTo(b.letter.toString()));
        filteredReciters = reciters;
        ////
        rewayat = data2.map((reciter) => Moshaf.fromJson(reciter)).toList();

        ////
        suwar = data3;

        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error while fetching data: $error');
    }
  }

  void filterReciters(String query) {
    setState(() {
      filteredReciters = reciters.where((reciter) {
        // You can define your filtering logic here.
        // For example, check if the reciter's name contains the query (case-insensitive).
        return reciter.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });

    itemScrollController.scrollTo(
        index: 0, duration: const Duration(seconds: 1));
  }

  void filterRecitersDownloaded(String query) {
    setState(() {
      filteredReciters = reciters.where((reciter) {
        // You can define your filtering logic here.
        // For example, check if the reciter's name contains the query (case-insensitive).
        return reciter.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });

    itemScrollController.scrollTo(
        index: 0, duration: const Duration(seconds: 1));
  }

  getRewayaReciters(String id) {
    filteredReciters = [];
    for (var element in reciters) {
      if (element.moshaf.any((element) => element.id.toString() == id)) {
        filteredReciters.add(element);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: SystemUiOverlay.values); // TODO: implement dispose
    super.dispose();
  }

  ItemScrollController itemScrollController = ItemScrollController();
  TextEditingController textEditingController = TextEditingController();
  var searchQuery = "";
  var selectedMode = "all";
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return 
        Scaffold(
          backgroundColor:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
          appBar: AppBar(
            backgroundColor:getValue("darkMode")?darkModeSecondaryColor.withOpacity(.9): blueColor,
            elevation: 0,
            title: Text("allReciters".tr(), style: const TextStyle(color: Colors.white)),
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () =>Navigator.pop(context),
                icon: const Icon(Entypo.logout, color: Colors.white)),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            bottom: PreferredSize(
              preferredSize: Size(screenSize.width, screenSize.height * .1),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xffF6F6F6),
                              borderRadius: BorderRadius.circular(5.r)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                                  child: TextField(
                                    controller: textEditingController,
                                    onChanged: (value) {
                                      setState(() {searchQuery = value;});
                                      filterReciters(value); // Call the filter method when the text changes
                                    },
                                    decoration: InputDecoration(
                                      hintText: "searchreciters".tr(),
                                      hintStyle: TextStyle(fontFamily: "cairo", fontSize: 14.sp, color: const Color.fromARGB(73, 0, 0, 0)),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    fetchReciters();
                                    // textEditingController.text = "";
                                    textEditingController.clear();
                                    FocusManager.instance.primaryFocus?.unfocus();

                                    setState(() {searchQuery = "";});
                                  },
                                  child: Icon(searchQuery == "" ? FontAwesome.search : Icons.close, color: const Color.fromARGB(73, 0, 0, 0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              enableDrag: true,
                              backgroundColor: Colors.white,
                              isDismissible: true,
                              // showDragHandle: true,
                              // isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14))),
                              context: context,
                              builder: ((context) {
                                return StatefulBuilder(
                                  builder: (context, s) {
                                    return Container(
                                      child: ListView(
                                        children: [
                                          EasyContainer(
                                            elevation: 0,
                                            padding: 0,
                                            margin: 0,
                                            onTap: () async {
                                              if (selectedMode != "all") {
                                                fetchReciters();
                                                setState(() {
                                                  selectedMode = "all";
                                                }); //       s((){});

                                                // await Future.delayed(
                                                //     const Duration(milliseconds: 200));
                                                Navigator.pop(context);

                                                // print(favoriteRecitersList.length);

                                                itemScrollController.scrollTo(
                                                    index: 0,
                                                    duration: const Duration(
                                                        seconds: 1));
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0.0.h),
                                              child: SizedBox(
                                                height: 45.h,
                                                // color: Colors.red,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 30.w,
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .all_inclusive_rounded,
                                                      color:
                                                          selectedMode == "all"
                                                              ?  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                                                              : Colors.grey,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    Text("all".tr()),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Icon(
                                                            selectedMode ==
                                                                    "all"
                                                                ? FontAwesome
                                                                    .dot_circled
                                                                : FontAwesome
                                                                    .circle_empty,
                                                            color: selectedMode ==
                                                                    "all"
                                                                ?  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                                                                : Colors.grey,
                                                            size: 20.sp,
                                                          ),
                                                          SizedBox(
                                                            width: 40.w,
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 15.h,
                                            color: Colors.grey,
                                          ),
                                          EasyContainer(
                                            elevation: 0,
                                            padding: 0,
                                            margin: 0,
                                            onTap: () async {
                                              // filteredReciters = [];

                                              setState(() {
                                                selectedMode = "favorite";
                                              });
                                              // s((){});
                                              // await Future.delayed(
                                              //     const Duration(milliseconds: 200));
                                              Navigator.pop(context);

                                              itemScrollController.scrollTo(
                                                  index: 0,
                                                  duration: const Duration(
                                                      seconds: 1));
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0.0.h),
                                              child: SizedBox(
                                                height: 45.h,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 30.w,
                                                    ),
                                                    Icon(
                                                      Icons.favorite,
                                                      color: selectedMode ==
                                                              "favorite"
                                                          ?  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                                                          : Colors.grey,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    Text("favorites".tr()),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Icon(
                                                            selectedMode ==
                                                                    "favorite"
                                                                ? FontAwesome
                                                                    .dot_circled
                                                                : FontAwesome
                                                                    .circle_empty,
                                                            color: selectedMode ==
                                                                    "favorite"
                                                                ?  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                                                                : Colors.grey,
                                                            size: 20.sp,
                                                          ),
                                                          SizedBox(
                                                            width: 40.w,
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 15.h,
                                            color: Colors.grey,
                                          ),
                                          ListView(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              children: rewayat
                                                  .map((e) => Column(
                                                        children: [
                                                          EasyContainer(
                                                            elevation: 0,
                                                            padding: 0,
                                                            margin: 0,
                                                            onTap: () async {
                                                              // filteredReciters =
                                                              //     [];
                                                              // filteredReciters =
                                                              //     reciters.where(
                                                              //         (reciter) {
                                                              //   final hasMatchingMoshaf =
                                                              //       reciter
                                                              //           .moshaf
                                                              //           .any(
                                                              //               (moshaf) {
                                                              //     // printYellow("{ moshaf.name }== ${e["name"]}")
                                                              //     return (moshaf
                                                              //             .id ==
                                                              //         e.id);
                                                              //   });
                                                              //   // print('Reciter: ${reciter.name}, Has Matching Moshaf: $hasMatchingMoshaf');
                                                              //   return hasMatchingMoshaf;
                                                              // }).toList();
                                                              getRewayaReciters(
                                                                  selectedMode);
                                                              print(
                                                                  filteredReciters
                                                                      .length);
                                                              setState(() {
                                                                selectedMode = e
                                                                    .moshafType
                                                                    .toString();
                                                              });
                                                              //  s((){});

                                                              // await Future.delayed(
                                                              //   const Duration(
                                                              //       milliseconds:
                                                              //           200));
                                                              Navigator.pop(
                                                                  context);

                                                              itemScrollController.scrollTo(
                                                                  index: 0,
                                                                  duration:
                                                                      const Duration(
                                                                          seconds:
                                                                              1));
                                                            },
                                                            child: SizedBox(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10.0.h),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          30.w,
                                                                    ),
                                                                    Image(
                                                                        height: 25
                                                                            .h,
                                                                        color: selectedMode == e.moshafType
                                                                            ? null
                                                                            : Colors
                                                                                .grey,
                                                                        image: const AssetImage(
                                                                             Assets.quranReading,)),
                                                                    SizedBox(
                                                                      width:
                                                                          10.w,
                                                                    ),
                                                                    Text(
                                                                        e.name),
                                                                    Expanded(
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Icon(
                                                                            selectedMode == e.moshafType.toString()
                                                                                ? FontAwesome.dot_circled
                                                                                : FontAwesome.circle_empty,
                                                                            color: selectedMode == e.moshafType.toString()
                                                                                ?  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                                                                                : Colors.grey,
                                                                            size:
                                                                                20.sp,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                40.w,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 12.h,
                                                          ),
                                                        ],
                                                      ))
                                                  .toList()),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }));
                        },
                        icon: const Icon(FontAwesome.filter,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: darkPrimaryColor),
                )
              : AnimationLimiter(
                  child: AzListView(
                    physics: const BouncingScrollPhysics(),
                    indexBarData:
                        getLettersForLocale(context.locale.languageCode)!,
                    indexBarHeight: screenSize.height,
                    itemScrollController: itemScrollController,
                    hapticFeedback: true,
                    indexBarItemHeight: 20,
                    data: selectedMode == "favorite" ? favoriteRecitersList : filteredReciters,
                    itemCount: selectedMode == "favorite" ? favoriteRecitersList.length : filteredReciters.length,
                    itemBuilder: (context, index) {
                      final reciter = selectedMode == "favorite" ? favoriteRecitersList[index] : filteredReciters[index];
                      return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: AudioCartItem(reciter: reciter, favoriteRecitersList: favoriteRecitersList, suwar: suwar)
                              ),
                            ),
                          );
                    },
                  ),
                ),
        )
    ;
  }
}
