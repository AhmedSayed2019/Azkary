
import 'package:azkark/data/models/surah_model.dart';
import 'package:azkark/pages/quran/surah/widgets/surah_text_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/constant.dart';
import '../../../providers/settings_provider.dart';
import '../../../util/background.dart';
import '../../../util/colors.dart';
import 'widgets/surah_with_list_widget.dart';

final ItemPositionsListener itemPositionsListener =
    ItemPositionsListener.create();

class SurahImagesBuilder extends StatefulWidget {
  final Map _sura;

  @override
  State<SurahImagesBuilder> createState() => _SurahImagesBuilderState();

  const SurahImagesBuilder({
    required Map sura,
  }) : _sura = sura;
}

class _SurahImagesBuilderState extends State<SurahImagesBuilder> {
  bool _isView = false;
  late PageController? _controller;



  @override
  void initState() {
    _controller = PageController(initialPage: widget._sura['startPage']-1);
    super.initState();
  }




  SafeArea _singleSuraBuilder() {
    return SafeArea(
      child: Container(
        color: teal,
          child: PhotoViewGallery.builder(

            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions.customChild(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(quranImages[index],fit: BoxFit.fill,),
                )
              );
            },
            itemCount: quranImages.length,
            pageController: _controller,
            loadingBuilder: (context, event) => Center(child: Container(width: 20.0, height: 20.0)),
            backgroundDecoration: BoxDecoration(color: teal[300]),
            onPageChanged: (v){},
          )
      ),
    );


    // return SafeArea(
    //     child: PhotoView(
    //   imageProvider: CachedNetworkImageProvider(imageUrl),
    //   minScale: PhotoViewComputedScale.contained * 0.8,
    //   maxScale: PhotoViewComputedScale.covered * 1.8,
    //   initialScale: PhotoViewComputedScale.contained,
    // ));
    // String fullSura = '';
    // int previousVerses = 0;
    // if (widget._suraIndex + 1 != 1) {
    //   for (int i = widget._suraIndex - 1; i >= 0; i--) {
    //     previousVerses = previousVerses + noOfVerses[i];
    //   }
    // }
    //
    // // if (!_isView)
    //   for (int i = 0; i < lengthOfSura; i++) {
    //     fullSura += (widget._ayatElQuran[i + previousVerses].ayaText);
    //   }
    //


    // return SafeArea(
    //   child: Container(
    //     // margin: EdgeInsets.all(16),
    //     color:  teal[50],
    //     // color: const Color.fromARGB(255, 253, 251, 240),
    //     child: _isView
    //         ? SurahWithListWidget(suraIndex:  widget._suraIndex , ayatElQuran: ayatElQuran,   previousVerses: previousVerses)
    //         : fullSura.isEmpty
    //         ? CupertinoActivityIndicator()
    //         :SurahTextWidget(suraIndex:  widget._suraIndex , fullSura: fullSura, fontSize: _fontSize),
    //
    //   ),
    // );

  }





  @override
  Widget build(BuildContext context) {

      return Stack(
        children: [
          Background(),

          Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(widget._sura['name'], style:  TextStyle(color: teal[50], fontWeight: FontWeight.w700, fontSize: 18)),
              actions: [
                // Tooltip(
                //   message: _isView?'عرض بطريقة النص':'عرض بطريقة التتابع',
                //   child: TextButton(
                //     child: const Icon(Icons.chrome_reader_mode, color: Colors.white),
                //     onPressed: () {
                //       setState(() {
                //         _isView = !_isView;
                //       });
                //     },
                //   ),
                // ),
              ]
            ),
            body: _singleSuraBuilder(),
          ),
        ],
      );
  }
}
