import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';

/// Data-layer DTO for a sebha (tasbih) row from the local `tasbih` table.
/// `favorite` is kept as the raw `0`/`1` int that sqflite stores; it is
/// converted to a `bool` only at the [toEntity] boundary.
class SebhaModel {
  const SebhaModel({
    required int id,
    required String name,
    required int counter,
    required int favorite,
  })  : _id = id,
        _name = name,
        _counter = counter,
        _favorite = favorite;

  factory SebhaModel.fromMap(Map<String, dynamic> map) => SebhaModel(
        id: map['id'] as int,
        name: map['name'] as String,
        counter: map['counter'] as int,
        favorite: map['favorite'] as int,
      );

  factory SebhaModel.fromEntity(SebhaEntity entity) => SebhaModel(
        id: entity.id,
        name: entity.name,
        counter: entity.counter,
        favorite: entity.favorite ? 1 : 0,
      );

  final int _id;
  final String _name;
  final int _counter;
  final int _favorite;

  int get id => _id;

  String get name => _name;

  int get counter => _counter;

  int get favorite => _favorite;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'counter': _counter,
        'favorite': _favorite,
      };

  SebhaEntity toEntity() => SebhaEntity(
        id: _id,
        name: _name,
        counter: _counter,
        favorite: _favorite == 1,
      );
}
