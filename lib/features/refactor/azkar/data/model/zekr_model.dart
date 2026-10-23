import 'package:azkark/core/localization/db_translations.dart';
import 'package:azkark/features/refactor/azkar/domain/entity/zekr_entity.dart';

/// Data-layer DTO for a row of the local `azkar` table.
class ZekrModel {
  const ZekrModel({
    required int id,
    required int categoryId,
    required int counterNumber,
    required String textWithDiacritics,
    required String textWithoutDiacritics,
    required String sanad,
    required String counterText,
  })  : _id = id,
        _categoryId = categoryId,
        _counterNumber = counterNumber,
        _textWithDiacritics = textWithDiacritics,
        _textWithoutDiacritics = textWithoutDiacritics,
        _sanad = sanad,
        _counterText = counterText;

  factory ZekrModel.fromMap(Map<String, dynamic> map) => ZekrModel(
        id: map['id'] as int? ?? 0,
        categoryId: map['category_id'] as int? ?? 0,
        counterNumber: map['counter_number'] as int? ?? 0,
        textWithDiacritics: map['text_with_diacritics'] as String? ?? '',
        textWithoutDiacritics: map['text_without_diacritics'] as String? ?? '',
        sanad: map['sanad'] as String? ?? '',
        counterText: map['counter_text'] as String? ?? '',
      );

  final int _id;
  final int _categoryId;
  final int _counterNumber;
  final String _textWithDiacritics;
  final String _textWithoutDiacritics;
  final String _sanad;
  final String _counterText;

  int get id => _id;

  int get categoryId => _categoryId;

  int get counterNumber => _counterNumber;

  String get textWithDiacritics => _textWithDiacritics;

  String get textWithoutDiacritics => _textWithoutDiacritics;

  String get sanad => _sanad;

  String get counterText => _counterText;

  ZekrEntity toEntity() => ZekrEntity(
        id: _id,
        categoryId: _categoryId,
        counterNumber: _counterNumber,
        textWithDiacritics: _textWithDiacritics,
        textWithoutDiacritics: _textWithoutDiacritics,
        sanad: _sanad,
        counterText: _counterText,
        // النص العربي لا يُستبدل بالترجمة أبدًا — هو ما يُتلى. الترجمة سطر
        // معنى تحته، ولا وجود لها ما دامت الواجهة عربية.
        meaning: DbTranslations.isTranslating
            ? DbTranslations.zekrMeaning(_id)
            : null,
      );
}
