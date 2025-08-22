import 'dart:convert';

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:azkark/features/QuranPages/bloc/quran_page_player_bloc.dart';
import 'package:azkark/features/QuranPages/views/screens/quran_pages/quran_pages_screen.dart';
import 'package:azkark/features/QuranPages/widgets/easy_container.dart';
import 'package:azkark/generated/assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/constants.dart';
import '../../../helpers/convertNumberToAr.dart';
import '../../../widgets/hizb_quarter_circle.dart';

class SurahListPage extends StatefulWidget {
  final dynamic jsonData;
  final dynamic quarterJsonData;

  const SurahListPage({
    Key? key,
    required this.jsonData,
    required this.quarterJsonData,
  }) : super(key: key);

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  bool _isLoading = true;
  String _searchQuery = "";
  List<dynamic>? _filteredData;
  List<dynamic> _bookmarks = [];
  int _juzNumberLastRead = 0;
  Set<String> _starredVerses = {};
  final _itemScrollController = ItemScrollController();
  final _textEditingController = TextEditingController();
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<int> pageNumbers = [];

  // Define the tabs
  final List<Tab> _tabs = <Tab>[
    Tab(text: 'surah'.tr()),
    Tab(text: 'juz'.tr()),
    Tab(text: 'quarter'.tr()),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _getStarredVerses(),
      _fetchBookmarks(),
      _getJuzNumber(),
      _addFilteredData(),
      _initializePageNumbers(),
    ]);
  }

  Future<void> _getStarredVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString("starredVerses");
    if (savedData != null) {
      setState(() {
        _starredVerses = Set<String>.from(json.decode(savedData));
      });
    }
  }

  Future<void> _fetchBookmarks() async {
    final bookmarksStr = getValue("bookmarks");
    if (bookmarksStr != null) {
      setState(() {
        _bookmarks = json.decode(bookmarksStr);
      });
    }
  }

  Future<void> _getJuzNumber() async {
    final lastRead = getValue("lastRead");
    if (lastRead != null && lastRead != "non") {
      final pageData = quran.getPageData(lastRead)[0];
      setState(() {
        _juzNumberLastRead = quran.getJuzNumber(
          pageData["surah"],
          pageData["start"],
        );
      });
    }
  }

  Future<void> _addFilteredData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _filteredData = (widget.jsonData as List<dynamic>);
      _isLoading = false;
    });
  }

  Future<void> _initializePageNumbers() async {
    pageNumbers = List.generate(114, (index) {
      final suraNumber = index + 1;
      return quran.getPageNumber(suraNumber, 1);
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300.withOpacity(.5),
          highlightColor: quranPagesColorLight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
            child: ListTile(
              leading: Container(width: 45, height: 45, color: backgroundColor),
              title: Container(height: 15, color: backgroundColor),
              subtitle: Container(height: 12, color: backgroundColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleWidget(int index, int hizbNumber) {
    final baseDecoration = BoxDecoration(
      shape: BoxShape.circle,
      color: quranPagesColorLight.withOpacity(.1),
    );
    const textColor = Color.fromARGB(228, 0, 0, 0);

    switch (index) {
      case 0:
        return Container(
          width: 33.sp,
          height: 33.sp,
          decoration: baseDecoration,
          child: Center(
            child: Text(
              hizbNumber.toString(),
              style: TextStyle(fontSize: 14.sp, color: textColor),
            ),
          ),
        );
      case 1:
        return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: baseDecoration,
          child: QuarterCircle(color: textColor, size: 20.sp),
        );
      case 2:
        return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: baseDecoration,
          child: HalfCircle(color: textColor, size: 20.sp),
        );
      case 3:
        return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: baseDecoration,
          child: ThreeQuartersCircle(color: textColor, size: 20.sp),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: Container(
          decoration: BoxDecoration(color: quranPagesColorLight),
          child: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: quranPagesColorLight,
            appBar: _buildAppBar(),
            endDrawer: _buildEndDrawer(),
            body: Column(
              children: [
                _buildSearchBar(),
                // TabBar(
                //   indicatorSize: TabBarIndicatorSize.tab,
                //   indicatorColor: Colors.white,
                //   indicatorWeight: 4,
                //   tabs: _tabs,
                //   onTap: (index) => setState(() => _currentIndex = index),
                // ),
                Expanded(
                  child: TabBarView(

                    children: [
                      _buildSurahList(),
                      _buildJuzList(),
                      _buildQuarterList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width.w, 90.h),
      child: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 8.h),
            child: Builder(
              builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openEndDrawer(), icon: const Icon( Iconsax.bookmark, color: backgroundColor)),
            ),
          ),
        ],
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
          child: IconButton(icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.r), bottomRight: Radius.circular(16.r))),
        elevation: 0,
        centerTitle: true,
        backgroundColor: getValue("darkMode") ? darkModeSecondaryColor : blueColor,
        title: Text("alQuran".tr(), style: TextStyle(color: Colors.white, fontSize: 20.sp)),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.04,
          ),
          child:  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              indicatorWeight: 4,
              tabs: _tabs,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        )
      ),
    );
  }

  Widget _buildEndDrawer() {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * .7,
        color: quranPagesColorLight,
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildBookmarksList(),
            _buildStarredVersesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList() {
    if (_bookmarks.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      separatorBuilder: (_, __) => const Divider(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) => _buildBookmarkItem(index),
    );
  }

  Widget _buildBookmarkItem(int index) {
    final bookmark = _bookmarks[index];
    final suraNumber = int.parse(bookmark["suraNumber"].toString());
    final verseNumber = int.parse(bookmark["verseNumber"].toString());
    final verse = quran.getVerse(suraNumber, verseNumber);
    final suraName = context.locale.languageCode == "ar" 
        ? quran.getSurahNameArabic(suraNumber)
        : quran.getSurahNameEnglish(suraNumber);

    return EasyContainer(
      borderRadius: 18,
      color: primaryColors[0].withOpacity(.05),
      onTap: () => _navigateToQuranPage(suraNumber, verseNumber, verse),
      child: Column(
        children: [
          _buildBookmarkHeader(bookmark),
          const Divider(),
          _buildVerseText(verse),
          const Divider(),
          _buildSuraInfo(suraName, verseNumber),
        ],
      ),
    );
  }

  Widget _buildBookmarkHeader(Map<String, dynamic> bookmark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bookmark,
          color: Color(int.parse("0x${bookmark["color"]}")),
        ),
        SizedBox(width: 20.w),
        Text(
          bookmark["name"],
          style: TextStyle(
            fontFamily: "cairo",
            fontSize: 14.sp,
            color: getValue("darkMode")
                ? Colors.white.withOpacity(.87)
                : primaryColors[0],
          ),
        ),
      ],
    );
  }

  Widget _buildVerseText(String verse) {
    return SizedBox(
      child: Text(
        verse,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: fontFamilies[0],
          fontSize: 18.sp,
          color: getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : primaryColors[0],
        ),
      ),
    );
  }

  Widget _buildSuraInfo(String suraName, int verseNumber) {
    return Column(
      children: [
        Text(
          suraName,
          style: TextStyle(
            color: getValue("darkMode")
                ? Colors.white.withOpacity(.87)
                : Colors.black87,
          ),
        ),
        Text(
          convertToArabicNumber(verseNumber.toString()),
          style: TextStyle(
            fontSize: 24.sp,
            color: Colors.blueAccent,
            fontFamily: "KFGQPC Uthmanic Script HAFS Regular",
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToQuranPage(int suraNumber, int verseNumber, String verse) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (builder) => BlocProvider(
          create: (context) => QuranPagePlayerBloc(),
          child: QuranDetailsPage(
            shouldHighlightSura: false,
            pageNumber: quran.getPageNumber(suraNumber, verseNumber),
            jsonData: widget.jsonData,
            shouldHighlightText: true,
            highlightVerse: verse,
            quarterJsonData: widget.quarterJsonData,
          ),
        ),
      ),
    );
  }

  Widget _buildStarredVersesList() {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0.h),
            child: Text(
              "starredverses".tr(),
              style: TextStyle(
                color: getValue("darkMode")
                    ? Colors.white.withOpacity(.87)
                    : Colors.black,
                fontSize: 18.sp,
              ),
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _starredVerses.map((verse) => _buildStarredVerseItem(verse)).toList(),
        ),
      ],
    );
  }

  Widget _buildStarredVerseItem(String verse) {
    return EasyContainer(
      color: primaryColors[0].withOpacity(.05),
      onTap: () async {
        // Navigate to verse implementation
      },
      child: Text(
        verse,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: fontFamilies[0],
          fontSize: 18.sp,
          color: getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : primaryColors[0],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: Container(
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                        child: TextField(
                          textAlign: TextAlign.right,
                          controller: _textEditingController,
                          onChanged: _handleSearchQueryChange,
                          style: TextStyle(
                            fontFamily: "aldahabi",
                            fontSize: 14.sp,
                            color: getValue("darkMode")
                                ? const Color.fromARGB(228, 255, 255, 255)
                                : const Color.fromARGB(190, 0, 0, 0),
                          ),
                          cursorColor: getValue("darkMode")
                              ? quranPagesColorDark
                              : quranPagesColorLight,
                          decoration: InputDecoration(
                            hintText: 'searchQuran'.tr(),
                            hintStyle: TextStyle(
                              fontFamily: "aldahabi",
                              fontSize: 14.sp,
                              color: getValue("darkMode")
                                  ? Colors.white70
                                  : const Color.fromARGB(73, 0, 0, 0),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    _buildSearchIcon(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchIcon() {
    return GestureDetector(
      onTap: _clearSearch,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _searchQuery.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.close,
                  color: getValue("darkMode")
                      ? Colors.white70
                      : const Color.fromARGB(73, 0, 0, 0),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.search,
                  color: getValue("darkMode")
                      ? Colors.white70
                      : const Color.fromARGB(73, 0, 0, 0),
                ),
              ),
      ),
    );
  }

  void _handleSearchQueryChange(String value) {
    setState(() {
      _searchQuery = value;
      if (value.isEmpty) {
        _filteredData = widget.jsonData as List<dynamic>;
        return;
      }

      if (value.length > 3 || value.contains(" ")) {
        _filteredData = (widget.jsonData as List<dynamic>).where((sura) {
          final suraName = sura['englishName'].toString().toLowerCase();
          final suraNameTranslated = quran.getSurahNameArabic(sura["number"] as int);
          return suraName.contains(value.toLowerCase()) ||
              suraNameTranslated.toLowerCase().contains(value.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    if (_searchQuery.isNotEmpty) {
      setState(() {
        _searchQuery = "";
        _filteredData = widget.jsonData as List<dynamic>;
        _textEditingController.clear();
      });
    }
  }

  Widget _buildSurahList() {
    if (_isLoading) return _buildShimmerLoading();

    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        if (getValue("lastRead") != "non") _buildLastReadSection(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => Padding(padding: EdgeInsets.symmetric(horizontal: 8.0.w), child: Divider(color: Colors.grey.withOpacity(.5))),
          itemCount: _filteredData?.length ?? 0,
          itemBuilder: (_, index) => _buildSurahListItem(index),
        ),
      ],
    );
  }

  Widget _buildLastReadSection() {
    final pageData = quran.getPageData(getValue("lastRead"))[0];
    final suraName = context.locale.languageCode == "ar"
        ? quran.getSurahNameArabic(pageData["surah"])
        : quran.getSurahName(pageData["surah"]);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: EasyContainer(
        color: orangeColor,
        height: 60.h,
        padding: 0,
        margin: 0,
        borderRadius: 15.r,
        onTap: () => _navigateToLastRead(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("lastRead".tr(), style: const TextStyle(color: Colors.white)),
              Text("$suraName - ${getValue("lastRead")}", style: const TextStyle(color: Colors.white)),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToLastRead() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => QuranPagePlayerBloc(),
          child: QuranDetailsPage(
            shouldHighlightSura: false,
            pageNumber: getValue("lastRead"),
            jsonData: widget.jsonData,
            shouldHighlightText: false,
            highlightVerse: "",
            quarterJsonData: widget.quarterJsonData,
          ),
        ),
      ),
    );
    setState(() {});
  }

  Widget _buildSurahListItem(int index) {
    final sura = _filteredData![index];
    final suraNumber = index + 1;
    final suraNumberInQuran = sura["number"];
    final suraName = sura["englishName"];
    final suraNameTranslated = sura["englishNameTranslation"];
    final ayahCount = quran.getVerseCount(suraNumber);


    return GestureDetector(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (builder) =>
                    BlocProvider(
                      create: (context) => QuranPagePlayerBloc(),
                      child: QuranDetailsPage(
                          shouldHighlightSura: true,
                          shouldHighlightText: false,
                          highlightVerse: "",
                          jsonData: widget.jsonData,
                          quarterJsonData: widget.quarterJsonData,
                          pageNumber: pageNumbers[index]),
                    )));
      },
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(Assets.quranSuraFrame))),
          child: Center(child: Text(suraNumberInQuran.toString(), style: TextStyle(color: orangeColor, fontSize: 14.sp))),
        ),
        title: SizedBox(
          width: 90.w,
          child: Row(
            children: [
              Text(suraName, style: TextStyle(color: getValue("darkMode") ? Colors.white70 : blueColor, fontSize: 14.sp, fontWeight: FontWeight.w700,fontFamily: "uthmanic")),
              _buildBookmarkIcon(suraNumberInQuran),
            ],
          ),
        ),
        subtitle: Text("$suraNameTranslated ($ayahCount)", style: TextStyle(fontFamily: "uthmanic", fontSize: 14.sp, color: Colors.grey.withOpacity(.8))),
        trailing: Text(suraNumber.toString(), style: TextStyle(fontFamily: "uthmanic", fontSize: 14.sp, color: Colors.grey.withOpacity(.8))),
      ),
    );
  }

  Widget _buildBookmarkIcon(int suraNumber) {
    final bookmarkIndex = _bookmarks.indexWhere(
      (a) => a.toString().split("-")[0] == "$suraNumber",
    );

    if (bookmarkIndex == -1) return const SizedBox.shrink();

    return Icon(
      Icons.bookmark,
      size: 16.sp,
      color: colorsOfBookmarks2[bookmarkIndex].withOpacity(.7),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        return ListTile(
          leading: _buildCircleWidget(0, index + 1),
          title: Text('${'juz'.tr()} ${index + 1}',
            style: TextStyle(
              fontSize: 16.sp,
              color: getValue("darkMode") ? Colors.white70 : Colors.black87,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuarterList() {
    return ListView.builder(
      itemCount: 240,
      itemBuilder: (context, index) {
        final quarterIndex = index % 4;
        final hizbNumber = (index ~/ 4) + 1;
        
        return ListTile(
          leading: _buildCircleWidget(quarterIndex, hizbNumber),
          title: Text(
            '${'quarter'.tr()} ${index + 1}',
            style: TextStyle(
              fontSize: 16.sp,
              color: getValue("darkMode") ? Colors.white70 : Colors.black87,
            ),
          ),
        );
      },
    );
  }
}
