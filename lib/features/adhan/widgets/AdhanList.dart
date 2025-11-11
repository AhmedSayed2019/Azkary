import 'package:azkark/data/models/adhan.dart';
import 'package:azkark/features/adhan/providers/adhan_provider.dart';
import 'package:azkark/features/adhan/widgets/AdhanItem.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const centerPage = 20000;

class AdhanList extends StatelessWidget {
  final PageController _pageController;


  const AdhanList(this._pageController);

  @override
  Widget build(BuildContext context) {
    final adhanProvider = context.read<AdhanProvider>();


    return PageView.builder(
      itemCount: centerPage * 2 + 1,
      controller: _pageController,
      onPageChanged: (newPage) {
        adhanProvider.changeDayOfDate(newPage - centerPage);
      },
      itemBuilder: (ctx, index) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: _AdhanListView(
            dateTime: DateTime.now().add(Duration(days: index - centerPage)),
            key: Key(index.toString()),
          ),
        );
      },
    );
  }
}

class _AdhanListView extends StatelessWidget {
  final DateTime dateTime;

  const _AdhanListView({required this.dateTime, Key? key,})
      : super(key: key);



  @override
  Widget build(BuildContext context) {
    final NumberFormat timeFormat = NumberFormat('00', context.locale.languageCode);
    final adhanProvider = context.read<AdhanProvider>();
    final List<Adhan> _adhans = adhanProvider.getAdhanData(dateTime);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _adhans.length,
      itemBuilder: (_, i) {
        return Padding(
          padding:  EdgeInsets.only(top: i == 0 ? 16 : 0, bottom: i == _adhans.length -1 ? 32 : 0),
          child: AdhanItem(_adhans[i], timeFormat),
        );
      },
    );
  }
}
