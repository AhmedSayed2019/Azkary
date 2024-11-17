class SebhaModel {
  int _id, _counter, _favorite;
  String _name;

  factory SebhaModel.fromMap(Map<String, dynamic> map) => SebhaModel(

    id : map['id'],
    name : map['name'],
    counter : map['counter'],
    favorite : map['favorite'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'counter': _counter,
      'favorite': _favorite,
    };
  }

  void setId(int value) {
    _id = value;
  }

  set setName(String value) {
    _name = value;
  }

  set setCounter(int value) {
    _counter = value;
  }

  void setFavorite(int value) {
    _favorite = value;
  }

  int get id => _id;

  String get name => _name;

  int get counter => _counter;

  int get favorite => _favorite;

  SebhaModel({
    required int id,
    required int counter,
    required int favorite,
    required String name,
  })  : _id = id,
        _counter = counter,
        _favorite = favorite,
        _name = name;
}
