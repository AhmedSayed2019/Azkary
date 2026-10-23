import 'package:azkark/core/localization/db_translations.dart';
import 'package:azkark/features/refactor/asmaallah/domain/entity/asma_allah_entity.dart';

/// Data-layer DTO for a row from the local `asmaallah` table.
class AsmaAllahModel {
  const AsmaAllahModel({
    required int id,
    required String name,
    required String description,
  })  : _id = id,
        _name = name,
        _description = description;

  /// The legacy `AsmaAllahModel.fromMap` fell back to `0`/`''` for missing
  /// keys via `??`, which silently swallowed a malformed/unexpected row
  /// instead of surfacing it. Kept here for parity with the seeded data,
  /// but each field is now defensively cast rather than assumed non-null.
  factory AsmaAllahModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as int? ?? 0;
    final description = map['description'] as String? ?? '';
    return AsmaAllahModel(
      id: id,
      // الاسم العربي يبقى كما هو — هو ما يُدعى به
      name: map['name'] as String? ?? '',
      // بلغة غير العربية: معنى الاسم ثم شرحه مترجمًا
      description: DbTranslations.isTranslating
          ? '${DbTranslations.asmaName(id, '')}\n\n'
                  '${DbTranslations.asmaDescription(id, description)}'
              .trim()
          : description,
    );
  }

  final int _id;
  final String _name;
  final String _description;

  int get id => _id;

  String get name => _name;

  String get description => _description;

  AsmaAllahEntity toEntity() => AsmaAllahEntity(
        id: _id,
        name: _name,
        description: _description,
      );
}
