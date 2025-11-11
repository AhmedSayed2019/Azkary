import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/util/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:screenshot/screenshot.dart';

class HomeDateView extends StatefulWidget {
  const HomeDateView({Key? key}) : super(key: key);

  @override
  State<HomeDateView> createState() => _HomeDateViewState();
}

class _HomeDateViewState extends State<HomeDateView> {

  final DateTime _dateTime = DateTime.now();
  var _today = HijriCalendar.now();
  Color goldColor = const Color.fromARGB(255, 150, 97, 0);

  updateDateData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    HijriCalendar.setLocal(context.locale.languageCode == "ar" ? "ar" : "en");
    _today = HijriCalendar.now();
    setState(() {});
  }


  @override
  void initState() {
    updateDateData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: kScreenPadding.copyWith(bottom: 0),

      decoration: const BoxDecoration().customColor(Theme.of(context).cardColor).radius(),
      // color: Theme.of(context).cardColor,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllLarge.w,vertical: kFormPaddingAllSmall.h),
      // height: 55.h,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.end,
        children:  [
          Text(DateFormat.EEEE(context.locale.languageCode).format(_dateTime), style: const TextStyle().semiBoldStyle(fontSize: 14).customColor(teal)),
          Expanded(child: Text('|', style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(teal),textAlign: TextAlign.center,)),
          RichText(
            text: TextSpan(
              // text: 'Hello ',
              style: DefaultTextStyle.of(context).style,
              children:  <TextSpan>[
                // TextSpan(text: DateFormat.EEEE(context.locale.languageCode).format(_dateTime), style:  const TextStyle().semiBoldStyle(fontSize: 16).primaryTextColor()),
                // TextSpan(text:'|', style:  const TextStyle().semiBoldStyle(fontSize: 16).primaryTextColor()),
                TextSpan(text: _today.toFormat("dd-MMMM -yyyy"), style:  const TextStyle().semiBoldStyle(fontSize: 14).primaryTextColor()),
                TextSpan(text:'  |  ', style:  const TextStyle().semiBoldStyle(fontSize: 16).primaryTextColor()),
                TextSpan(text: DateFormat("dd-MMMM-yyyy",context.locale.languageCode).format(_dateTime), style:  const TextStyle().semiBoldStyle(fontSize: 14).primaryTextColor()),
              ],
            ),
          ),

          // Expanded(child: Text(DateFormat.EEEE(context.locale.languageCode).format(_dateTime), style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(teal))),
          // Text('|', style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(teal)),
          //
          // // Expanded(child: Text(_today.toFormat("dd - MMMM - yyyy"), style: TextStyle(color:  goldColor, fontSize: 18.sp))),
          // Text(_today.toFormat("dd - MMMM - yyyy"), style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(teal)),
          // SizedBox(width: kFormPaddingAllNormal.w),
          // Text('|', style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(teal)),
          //
          // SizedBox(width: kFormPaddingAllNormal.w),
          // Text(DateFormat("dd - MMMM - yyyy",context.locale.languageCode).format(_dateTime), style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(teal)),
          // Text(DateFormat.yMMMEd(context.locale.languageCode).format(_dateTime), style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(teal)),
        ],
      ),
    );
  }
}
