import 'package:equatable/equatable.dart';

/// Immutable domain representation of a single sebha (tasbih) counter.
class SebhaEntity extends Equatable {
  const SebhaEntity({
    required int id,
    required String name,
    required int counter,
    required bool favorite,
  })  : _id = id,
        _name = name,
        _counter = counter,
        _favorite = favorite;

  final int _id;
  final String _name;
  final int _counter;
  final bool _favorite;

  int get id => _id;

  String get name => _name;

  int get counter => _counter;

  bool get favorite => _favorite;

  SebhaEntity copyWith({
    String? name,
    int? counter,
    bool? favorite,
  }) {
    return SebhaEntity(
      id: _id,
      name: name ?? _name,
      counter: counter ?? _counter,
      favorite: favorite ?? _favorite,
    );
  }

  @override
  List<Object?> get props => [_id, _name, _counter, _favorite];
}
