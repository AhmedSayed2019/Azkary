import 'package:equatable/equatable.dart';

/// Immutable domain representation of a single azkar category (e.g. "أذكار
/// الصباح"). Mirrors the legacy `CategoryModel` shape, minus persistence
/// concerns.
class CategoryEntity extends Equatable {
  const CategoryEntity({
    required int id,
    required int sectionId,
    required String nameWithDiacritics,
    required String nameWithoutDiacritics,
    required String azkarIndex,
    required bool favorite,
  })  : _id = id,
        _sectionId = sectionId,
        _nameWithDiacritics = nameWithDiacritics,
        _nameWithoutDiacritics = nameWithoutDiacritics,
        _azkarIndex = azkarIndex,
        _favorite = favorite;

  final int _id;
  final int _sectionId;
  final String _nameWithDiacritics;
  final String _nameWithoutDiacritics;
  final String _azkarIndex;
  final bool _favorite;

  int get id => _id;

  int get sectionId => _sectionId;

  String get nameWithDiacritics => _nameWithDiacritics;

  String get nameWithoutDiacritics => _nameWithoutDiacritics;

  /// Raw `azkar_index` value used to fetch this category's azkar rows.
  String get azkarIndex => _azkarIndex;

  bool get favorite => _favorite;

  CategoryEntity copyWith({bool? favorite}) {
    return CategoryEntity(
      id: _id,
      sectionId: _sectionId,
      nameWithDiacritics: _nameWithDiacritics,
      nameWithoutDiacritics: _nameWithoutDiacritics,
      azkarIndex: _azkarIndex,
      favorite: favorite ?? _favorite,
    );
  }

  @override
  List<Object?> get props => [
        _id,
        _sectionId,
        _nameWithDiacritics,
        _nameWithoutDiacritics,
        _azkarIndex,
        _favorite,
      ];
}
