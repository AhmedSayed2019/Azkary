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
  factory AsmaAllahModel.fromMap(Map<String, dynamic> map) => AsmaAllahModel(
        id: map['id'] as int? ?? 0,
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
      );

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
