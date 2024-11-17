class FavoriteModel {
  final int _id, _itemId;

  factory FavoriteModel.fromMap(Map<String, dynamic> map) =>FavoriteModel(id:  map['id']??0, itemId:  map['item_id']??0);

  const FavoriteModel({
    required int id,
    required int itemId,
  })
      : _id = id,
        _itemId = itemId;



  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'item_id': _itemId,
    };
  }

  int get id => _id;

  int get itemId => _itemId;
}
