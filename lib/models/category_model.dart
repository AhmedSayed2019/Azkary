class CategoryModel {
  final int _id, _sectionId;

  final String _nameWithDiacritics, _nameWithoutDiacritics, _azkarIndex;
  int _favorite;

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
      id: map['id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      favorite: map['favorite'] ?? 0,
      nameWithDiacritics: map['name_with_diacritics'] ?? '',
      nameWithoutDiacritics: map['name_without_diacritics'] ?? '',
      azkarIndex: map['azkar_index'] ?? '');

  void setFavorite(int value) {
    _favorite = value;
  }

  int get id => _id;

  int get sectionId => _sectionId;

  String get nameWithDiacritics => _nameWithDiacritics;

  String get nameWithoutDiacritics => _nameWithoutDiacritics;

  int get favorite => _favorite;

  String get azkarIndex => _azkarIndex;

  CategoryModel({
    required int id,
    required int sectionId,
    required int favorite,
    required String nameWithDiacritics,
    required String nameWithoutDiacritics,
    required String azkarIndex,
  })  : _id = id,
        _sectionId = sectionId,
        _favorite = favorite,
        _nameWithDiacritics = nameWithDiacritics,
        _nameWithoutDiacritics = nameWithoutDiacritics,
        _azkarIndex = azkarIndex;
}
