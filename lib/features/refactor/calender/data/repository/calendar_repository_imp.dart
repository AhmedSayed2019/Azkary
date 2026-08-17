import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/calender/data/datasource/local/calendar_local_datasource.dart';
import 'package:azkark/features/refactor/calender/domain/entity/calendar_date_entity.dart';
import 'package:azkark/features/refactor/calender/domain/repository/calendar_repository.dart';

class CalendarRepositoryImp implements CalendarRepository {
  const CalendarRepositoryImp(this._localDataSource);

  final CalendarLocalDataSource _localDataSource;

  @override
  Result<CalendarDateEntity> convertToHijri(DateTime gregorianDate) {
    final result = _localDataSource.convertToHijri(gregorianDate);
    return switch (result) {
      Ok(:final data) => Ok(data.toEntity()),
      Err(:final message) => Err(message),
    };
  }
}
