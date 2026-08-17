import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/calender/domain/entity/calendar_date_entity.dart';
import 'package:azkark/features/refactor/calender/domain/usecase/convert_to_hijri_use_case.dart';
import 'package:flutter/foundation.dart';

class CalendarViewModel extends ChangeNotifier {
  final _tag = 'CalendarViewModel';

  CalendarViewModel({required ConvertToHijriUseCase convertToHijri})
      : _convertToHijri = convertToHijri;

  final ConvertToHijriUseCase _convertToHijri;
  bool _disposed = false;

  ///Variables
  CalendarDateEntity? _entity;
  String? _error;

  ///Getters
  CalendarDateEntity? get entity => _entity;

  String? get error => _error;

  /// Falls back to "today" until the first conversion resolves, so the date
  /// picker always has a value to seed itself with.
  DateTime get selectedDate => _entity?.gregorianDate ?? DateTime.now();

  ///Calling API functions

  void init() => selectDate(DateTime.now());

  /// Converts [date] to Hijri and updates state. This is a pure, synchronous
  /// computation (no I/O), so there is no loading flag — the result is
  /// always available on the next frame.
  void selectDate(DateTime date) {
    final result = _convertToHijri(date);
    switch (result) {
      case Ok(:final data):
        _entity = data;
        _error = null;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.selectDate: $message');
    }
    _notify();
  }

  void retry() => selectDate(selectedDate);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
