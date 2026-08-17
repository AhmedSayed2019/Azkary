import 'package:azkark/features/refactor/settings/domain/entity/settings_entity.dart';

/// Data-layer DTO for the single settings row. `counter`/`diacritics`/`sanad`
/// are kept as the raw `0`/`1` ints the database stores; they are converted
/// to `bool` only at the [toEntity] boundary.
class SettingsModel {
  const SettingsModel({
    required int counter,
    required int diacritics,
    required int sanad,
    required int fontFamily,
    required double fontSize,
  })  : _counter = counter,
        _diacritics = diacritics,
        _sanad = sanad,
        _fontFamily = fontFamily,
        _fontSize = fontSize;

  final int _counter;
  final int _diacritics;
  final int _sanad;
  final int _fontFamily;
  final double _fontSize;

  int get counter => _counter;

  int get diacritics => _diacritics;

  int get sanad => _sanad;

  int get fontFamily => _fontFamily;

  double get fontSize => _fontSize;

  SettingsEntity toEntity() => SettingsEntity(
        counter: _counter == 1,
        diacritics: _diacritics == 1,
        sanad: _sanad == 1,
        fontFamily: _fontFamily,
        fontSize: _fontSize,
      );
}
