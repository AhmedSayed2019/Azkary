import 'package:azkark/features/refactor/calender/domain/entity/calendar_date_entity.dart';
import 'package:hijri/hijri_calendar.dart';

/// DTO wrapping a [HijriCalendar] conversion result. No business logic here
/// — just the plugin-facing shape plus a mapping to [CalendarDateEntity].
class CalendarDateModel {
  CalendarDateModel({
    required DateTime gregorianDate,
    required String hijriFormatted,
  })  : _gregorianDate = gregorianDate,
        _hijriFormatted = hijriFormatted;

  /// Builds a model from the `hijri` package's calendar object for
  /// [gregorianDate], formatted as `dd - MMMM - yyyy`.
  factory CalendarDateModel.fromHijri(
    HijriCalendar hijri,
    DateTime gregorianDate,
  ) {
    return CalendarDateModel(
      gregorianDate: gregorianDate,
      hijriFormatted: hijri.toFormat('dd - MMMM - yyyy'),
    );
  }

  final DateTime _gregorianDate;
  final String _hijriFormatted;

  DateTime get gregorianDate => _gregorianDate;

  String get hijriFormatted => _hijriFormatted;

  CalendarDateEntity toEntity() => CalendarDateEntity(
        gregorianDate: _gregorianDate,
        hijriFormatted: _hijriFormatted,
      );
}
