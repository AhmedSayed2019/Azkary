class AsmaAllahModel {
 final int _id;
 final String _name, _description;

  AsmaAllahModel(
    this._id,
    this._name,
    this._description,
  );

 factory AsmaAllahModel.fromMap(Map<String, dynamic> map) =>
      AsmaAllahModel(map['id']??0, map['name']??'', map['description']??'');


  int get id => _id;

  String get name => _name;

  String get description => _description;
}
