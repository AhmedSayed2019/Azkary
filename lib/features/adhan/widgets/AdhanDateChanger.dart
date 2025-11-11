// import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkark/app.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/helpers/extensions.dart';
import 'package:azkark/features/adhan/providers/adhan_provider.dart';
import 'package:azkark/features/adhan/widgets/AdhanList.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const _padding = 16.0;


LinearGradient getOnBackgroundGradient({double opacity = 1}) {
  return LinearGradient(colors: [
    const Color(0xFF134E5E).withOpacity(opacity),
    const Color(0xFF71B280).withOpacity(opacity),
  ],);
}


class AdhanDateChanger extends StatelessWidget {
  final PageController _adhanListPageController;

  const AdhanDateChanger(this._adhanListPageController);

  Future moveToDate(BuildContext context, DateTime currentDate) async {
    final date = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2070),);

    if (date != null) {
      final days = DateTime.now().daysFrom(date);
      _adhanListPageController.jumpToPage(centerPage + days);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adhanProvider = context.watch<AdhanProvider>();
    return Container(

      padding: const EdgeInsets.symmetric(vertical: _padding),
      decoration: BoxDecoration(gradient: getOnBackgroundGradient(), borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                icon: Icon(Directionality.of(context).toString().contains(TextDirection.LTR.value.toLowerCase()) ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right, color: Colors.white,),
                onPressed: () => _adhanListPageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn,)),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => moveToDate(context, adhanProvider.currentDate),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(adhanProvider.currentDate.getHizriDateForLocale(), style:  const TextStyle().titleStyle( ).primaryLiteTextColor(),),

                    _CustomDivider(width: context.width * (context.isLargeScreen ? 0.3 : 0.5),),
                    Text(DateFormat("EEEE, dd MMM yyyy", appContext?.locale.languageCode,).format(adhanProvider.currentDate), style:  const TextStyle().regularStyle( ).primaryLiteTextColor(),),


                  ],
                ),
              ),
            ),
            IconButton(
                icon: Icon(
                  Directionality.of(context).toString().contains(TextDirection.LTR.value.toLowerCase())
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_left,
                  color: Colors.white,
                ),
                onPressed: () {
                  _adhanListPageController.nextPage(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeIn,);
                },)
          ],
        ),
      ),
    );
  }

}

class _CustomDivider extends StatelessWidget {
  final double width;

  const _CustomDivider({required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
          width: width,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 4.0),
            borderRadius: BorderRadius.circular(4.0),
          ),),
    );
  }
}
