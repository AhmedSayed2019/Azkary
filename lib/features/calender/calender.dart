import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart' as j;
import 'package:jhijri_picker/jhijri_picker.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  int index = 1;
  var _today = j.HijriCalendar.now().toFormat(
                    "dd - MMMM - yyyy",
                  );
  var date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Background(),
        Scaffold(
          appBar: AppBar(
            title: Text( tr("calender"), style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            // backgroundColor:  getValue("darkMode") ? darkModeSecondaryColor :  blueColor,
          ),
          body: ListView(
            children: [
              SizedBox(
                height: 30.h,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: JGlobalDatePicker (
                  widgetType: WidgetType.JContainer,
                  // pickerType: index == 0 ? PickerType.JHijri : PickerType.JHijri,
                  buttons: const SizedBox(),
                  primaryColor: Theme.of(context).primaryColor,
                  calendarTextColor: Colors.black,
                  backgroundColor: Colors.white,
                  borderRadius: const Radius.circular(10),
                  headerTitle: Container(
                    decoration:   BoxDecoration(color:  Theme.of(context).cardColor),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                index = 0;
                              });
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                        tr("calender"),
                                  style: TextStyle(
                                      color: index == 0
                                          ?  Colors.black
                                          :   Colors.black26,
                                      fontSize: 18.sp),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                index = 1;
                              });
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text( tr("normalCalender"),
                                  style: TextStyle(
                                      color: index == 1 ?   Colors.black :   Colors.black26,
                                      fontSize: 18.sp),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  startDate: JDateModel(dateTime: DateTime.parse("1984-12-24")),
                  selectedDate: JDateModel(dateTime: DateTime.now()),
                  endDate: JDateModel(dateTime: DateTime.parse("2030-09-20")),
                  pickerMode: DatePickerMode.day,
                  pickerTheme: Theme.of(context),
                  locale: context.locale,
                  textDirection: m.TextDirection.rtl,
                  onChange: (val) {
                    date = val.date;
                    _today = j. HijriCalendar.fromDate(val.date).toFormat("dd - MMMM - yyyy");
                    setState(() {});
                    // return val;
                  },
                ),
              ),
              SizedBox(height: 50.h),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(color: (teal[400]), borderRadius: BorderRadius.circular(20.r)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(_today, style: TextStyle(color:  Colors.black, fontSize: 20.sp)),
                          Text(DateFormat.yMMMEd(context.locale.languageCode).format(date), style: TextStyle(color:   Colors.black, fontSize: 20.sp)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
