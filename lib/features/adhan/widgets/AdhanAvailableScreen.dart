import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/helpers/extensions.dart';
import 'package:azkark/data/models/locationInfo.dart';
import 'package:azkark/features/adhan/providers/adhan_provider.dart';
import 'package:azkark/features/adhan/widgets/AdhanDateChanger.dart';
import 'package:azkark/features/adhan/widgets/AdhanList.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdhanAvailableScreen extends StatelessWidget {
  final PageController _adhanListPageController;
  final LocationInfo _locationInfo;

  AdhanAvailableScreen(this._locationInfo)
      : _adhanListPageController = PageController(initialPage: centerPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Consumer<AdhanProvider>(
          builder: (_, v, child) => v.currentDate.isToday
              ? Container()
              : FloatingActionButton(
                  onPressed: () => _adhanListPageController.animateToPage(
                      centerPage,
                      duration: const Duration(milliseconds: 200), curve: Curves.bounceIn),
                  child: Icon(Icons.refresh),
                ),
        ),
        appBar: AppBar(
          elevation: 0,
          title: Text(tr("adhan")),
        ),
        body: Padding(
          padding: kScreenPadding,
          child: Column(
            children: [
              AdhanDateChanger(_adhanListPageController),
              Expanded(child: AdhanList(_adhanListPageController)),
            ],
          ),
        ));
  }
}
