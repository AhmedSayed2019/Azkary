import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/calender/domain/entity/calendar_date_entity.dart';
import 'package:azkark/features/refactor/calender/domain/repository/calendar_repository.dart';

class ConvertToHijriUseCase {
  const ConvertToHijriUseCase(this._repository);

  final CalendarRepository _repository;

  Result<CalendarDateEntity> call(DateTime gregorianDate) =>
      _repository.convertToHijri(gregorianDate);
}
