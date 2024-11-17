
import 'package:azkark/pages/quran/surah/surah_images_screen.dart';
import 'package:flutter/material.dart';
import '../../core/constant.dart';


import '../../util/background.dart';
import '../../util/colors.dart';
import '../../util/helpers.dart';
import '../../util/navigate_between_pages/scale_route.dart';
import 'widget/arabic_sura_number_widget.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({Key? key}) : super(key: key);

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {


  @override
  void initState() {
    buildQuranImagesList();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Background(),

        Scaffold(
          // drawer: const MyDrawer(),
          // floatingActionButton: FloatingActionButton(
          //   tooltip: 'Go to bookmark',
          //   child: const Icon(Icons.bookmark),
          //   backgroundColor: Colors.green,
          //   onPressed: () async {
          //     fabIsClicked = true;
          //     if (await readBookmark() == true) {
          //       Navigator.push(context, ScaleRoute(page: SurahImagesBuilder(sura:quranList[bookmarkedSura])));
          //
          //
          //     }
          //   },
          // ),
          appBar: AppBar(
            elevation: 0.0,
            title: Text(translate(context, 'quran'), style: new TextStyle(color: teal[50], fontWeight: FontWeight.w700, fontSize: 18)),
          ),
            body:  _indexCreator( context)
        ),
      ],
    );
  }

  Container _indexCreator(context) {
    return Container(
      color: teal[50],
      child: ListView(
        children: [
          for (int index = 0; index < quranList.length; index++)
            Container(
              color: index % 2 == 0 ? teal[50] : teal[100],
              child: TextButton(
                child: Row(
                  children: [
                    ArabicSuraNumber(number: index),
                    const SizedBox(width: 5),
                    Spacer(),
                    Image.asset(getSurahImage(index),width: 68,height: 68,color: teal),

                  ],
                ),
                onPressed: () {
                  fabIsClicked = false;
                   Navigator.push(context, ScaleRoute(page: SurahImagesBuilder(sura:quranList[index] )));
                },
              ),
            ),
        ],
      ),
    );
  }


}




