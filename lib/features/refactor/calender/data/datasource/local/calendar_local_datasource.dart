import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/calender/data/model/calendar_date_model.dart';
import 'package:hijri/hijri_calendar.dart';

/// Wraps the `hijri` package's Gregorian→Hijri conversion and never throws —
/// failures (e.g. a date outside the package's supported range) are
/// surfaced as [Err] so the repository/use-case/VM layers above never have
/// to deal with a raw exception.
class CalendarLocalDataSource {
  Result<CalendarDateModel> convertToHijri(DateTime gregorianDate) {
    try {
      final hijri = HijriCalendar.fromDate(gregorianDate);
      return Ok(CalendarDateModel.fromHijri(hijri, gregorianDate));
    } catch (e) {
      return Err('Failed to convert date to Hijri: $e');
    }
  }
}
