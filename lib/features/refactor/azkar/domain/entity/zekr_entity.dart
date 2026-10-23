import 'package:equatable/equatable.dart';

/// Immutable domain representation of a single zekr row. Mirrors the legacy
/// `ZekrModel` (`lib/models/zekr_model.dart`) minus persistence concerns,
/// plus [meaning] — the translated meaning shown under the Arabic text when
/// the UI language is not Arabic.
class ZekrEntity extends Equatable {
  const ZekrEntity({
    required int id,
    required int categoryId,
    required int counterNumber,
    required String textWithDiacritics,
    required String textWithoutDiacritics,
    required String sanad,
    required String counterText,
    String? meaning,
  })  : _id = id,
        _categoryId = categoryId,
        _counterNumber = counterNumber,
        _textWithDiacritics = textWithDiacritics,
        _textWithoutDiacritics = textWithoutDiacritics,
        _sanad = sanad,
        _counterText = counterText,
        _meaning = meaning;

  final int _id;
  final int _categoryId;
  final int _counterNumber;
  final String _textWithDiacritics;
  final String _textWithoutDiacritics;
  final String _sanad;
  final String _counterText;
  final String? _meaning;

  int get id => _id;

  int get categoryId => _categoryId;

  /// How many times this zekr is meant to be repeated — the counter's target.
  int get counterNumber => _counterNumber;

  String get textWithDiacritics => _textWithDiacritics;

  String get textWithoutDiacritics => _textWithoutDiacritics;

  String get sanad => _sanad;

  String get counterText => _counterText;

  String? get meaning => _meaning;

  @override
  List<Object?> get props => [
        _id,
        _categoryId,
        _counterNumber,
        _textWithDiacritics,
        _textWithoutDiacritics,
        _sanad,
        _counterText,
        _meaning,
      ];
}
