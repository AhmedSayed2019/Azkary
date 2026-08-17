import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';

/// Data-layer DTO for a category row from the local `categories` table.
/// `favorite` is kept as the raw `0`/`1` int that sqflite stores; it is
/// converted to a `bool` only at the [toEntity] boundary.
class CategoryModel {
  const CategoryModel({
    required int id,
    required int sectionId,
    required String nameWithDiacritics,
    required String nameWithoutDiacritics,
    required String azkarIndex,
    required int favorite,
  })  : _id = id,
        _sectionId = sectionId,
        _nameWithDiacritics = nameWithDiacritics,
        _nameWithoutDiacritics = nameWithoutDiacritics,
        _azkarIndex = azkarIndex,
        _favorite = favorite;

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as int? ?? 0,
        sectionId: map['section_id'] as int? ?? 0,
        nameWithDiacritics: map['name_with_diacritics'] as String? ?? '',
        nameWithoutDiacritics:
            map['name_without_diacritics'] as String? ?? '',
        azkarIndex: map['azkar_index'] as String? ?? '',
        favorite: map['favorite'] as int? ?? 0,
      );

  final int _id;
  final int _sectionId;
  final String _nameWithDiacritics;
  final String _nameWithoutDiacritics;
  final String _azkarIndex;
  final int _favorite;

  int get id => _id;

  int get sectionId => _sectionId;

  String get nameWithDiacritics => _nameWithDiacritics;

  String get nameWithoutDiacritics => _nameWithoutDiacritics;

  String get azkarIndex => _azkarIndex;

  int get favorite => _favorite;

  CategoryEntity toEntity() => CategoryEntity(
        id: _id,
        sectionId: _sectionId,
        nameWithDiacritics: _nameWithDiacritics,
        nameWithoutDiacritics: _nameWithoutDiacritics,
        azkarIndex: _azkarIndex,
        favorite: _favorite == 1,
      );
}
