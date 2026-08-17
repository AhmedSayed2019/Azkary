import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/features/refactor/calender/presentation/modules/calendar/calendar_view_model.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:jhijri_picker/jhijri_picker.dart';

/// Replaces the legacy `CalenderPage` — shows a Hijri/Gregorian date picker
/// plus the converted-date summary card, backed by [CalendarViewModel] (a
/// factory VM resolved from GetIt, not a `ChangeNotifierProvider`).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // The picker only supports a fixed date range; kept as the legacy screen
  // defined it.
  static final _pickerStartDate = DateTime(1984, 12, 24);
  static final _pickerEndDate = DateTime(2030, 09, 20);

  late final CalendarViewModel _vm;

  /// Purely cosmetic tab selector for the header labels — the underlying
  /// picker is always Hijri, matching the legacy screen's behaviour.
  int _headerTabIndex = 1;

  @override
  void initState() {
    super.initState();
    _vm = getIt<CalendarViewModel>()..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Background(),
        Scaffold(
          appBar: AppBar(
            title: Text(tr('calender'), style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) {
              return ListView(
                children: [
                  SizedBox(height: 30.h),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: JGlobalDatePicker(
                      widgetType: WidgetType.JContainer,
                      buttons: const SizedBox(),
                      primaryColor: Theme.of(context).primaryColor,
                      calendarTextColor: Colors.black,
                      backgroundColor: Colors.white,
                      borderRadius: const Radius.circular(10),
                      headerTitle: _HeaderTabs(
                        selectedIndex: _headerTabIndex,
                        onSelect: (index) => setState(() => _headerTabIndex = index),
                      ),
                      startDate: JDateModel(dateTime: _pickerStartDate),
                      selectedDate: JDateModel(dateTime: _vm.selectedDate),
                      endDate: JDateModel(dateTime: _pickerEndDate),
                      pickerMode: DatePickerMode.day,
                      pickerTheme: Theme.of(context),
                      locale: context.locale,
                      textDirection: m.TextDirection.rtl,
                      onChange: (val) => _vm.selectDate(val.date),
                    ),
                  ),
                  SizedBox(height: 50.h),
                  _SelectedDateCard(
                    hijriFormatted: _vm.entity?.hijriFormatted ?? '',
                    gregorianDate: _vm.selectedDate,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderTabs extends StatelessWidget {
  const _HeaderTabs({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onSelect(0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    tr('calender'),
                    style: TextStyle(
                      color: selectedIndex == 0 ? Colors.black : Colors.black26,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onSelect(1),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    tr('normalCalender'),
                    style: TextStyle(
                      color: selectedIndex == 1 ? Colors.black : Colors.black26,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDateCard extends StatelessWidget {
  const _SelectedDateCard({
    required this.hijriFormatted,
    required this.gregorianDate,
  });

  final String hijriFormatted;
  final DateTime gregorianDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(color: teal[400], borderRadius: BorderRadius.circular(20.r)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(hijriFormatted, style: TextStyle(color: Colors.black, fontSize: 20.sp)),
                Text(
                  DateFormat.yMMMEd(context.locale.languageCode).format(gregorianDate),
                  style: TextStyle(color: Colors.black, fontSize: 20.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
