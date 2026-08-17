import 'package:equatable/equatable.dart';

/// Immutable domain representation of one of the 99 names of Allah.
class AsmaAllahEntity extends Equatable {
  const AsmaAllahEntity({
    required int id,
    required String name,
    required String description,
  })  : _id = id,
        _name = name,
        _description = description;

  final int _id;
  final String _name;
  final String _description;

  int get id => _id;

  String get name => _name;

  String get description => _description;

  @override
  List<Object?> get props => [_id, _name, _description];
}
