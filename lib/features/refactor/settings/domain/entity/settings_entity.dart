import 'package:equatable/equatable.dart';

/// Immutable domain representation of the single app-wide settings row
/// (`counter`/`diacritics`/`sanad` toggles + font family/size preferences).
class SettingsEntity extends Equatable {
  const SettingsEntity({
    required bool counter,
    required bool diacritics,
    required bool sanad,
    required int fontFamily,
    required double fontSize,
  })  : _counter = counter,
        _diacritics = diacritics,
        _sanad = sanad,
        _fontFamily = fontFamily,
        _fontSize = fontSize;

  final bool _counter;
  final bool _diacritics;
  final bool _sanad;
  final int _fontFamily;
  final double _fontSize;

  bool get counter => _counter;

  bool get diacritics => _diacritics;

  bool get sanad => _sanad;

  int get fontFamily => _fontFamily;

  double get fontSize => _fontSize;

  SettingsEntity copyWith({
    bool? counter,
    bool? diacritics,
    bool? sanad,
    int? fontFamily,
    double? fontSize,
  }) {
    return SettingsEntity(
      counter: counter ?? _counter,
      diacritics: diacritics ?? _diacritics,
      sanad: sanad ?? _sanad,
      fontFamily: fontFamily ?? _fontFamily,
      fontSize: fontSize ?? _fontSize,
    );
  }

  @override
  List<Object?> get props =>
      [_counter, _diacritics, _sanad, _fontFamily, _fontSize];
}
