import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/calender/domain/entity/calendar_date_entity.dart';

/// Contract for converting a Gregorian date into its Hijri representation.
/// Implemented by `CalendarRepositoryImp` in the data layer; use cases
/// depend on this abstraction only.
abstract interface class CalendarRepository {
  Result<CalendarDateEntity> convertToHijri(DateTime gregorianDate);
}
