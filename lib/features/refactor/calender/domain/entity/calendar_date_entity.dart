import 'package:equatable/equatable.dart';

/// Immutable domain representation of a single day, carrying both its
/// Gregorian [DateTime] and its formatted Hijri counterpart.
class CalendarDateEntity extends Equatable {
  const CalendarDateEntity({
    required DateTime gregorianDate,
    required String hijriFormatted,
  })  : _gregorianDate = gregorianDate,
        _hijriFormatted = hijriFormatted;

  final DateTime _gregorianDate;
  final String _hijriFormatted;

  DateTime get gregorianDate => _gregorianDate;

  String get hijriFormatted => _hijriFormatted;

  /// Placeholder used while the first conversion hasn't resolved yet, so
  /// shimmer/loading UIs have a realistic shape to render.
  static CalendarDateEntity get shimmerSeed => CalendarDateEntity(
        gregorianDate: DateTime.now(),
        hijriFormatted: '-- - ---- - ----',
      );

  @override
  List<Object?> get props => [_gregorianDate, _hijriFormatted];
}
