import 'dart:convert';

class SectionModel {
 final int _id;
 final String _name;
 final List<int> _categoriesIndex;

 factory SectionModel.fromMap(Map<String, dynamic> map) =>
     SectionModel(id: map['id'], name:  map['name'], categoriesIndex: List.from(jsonDecode(map['categories_index'])) );

  //   _id = map['id'];
  //   _name = map['name'];
  //   _categoriesIndex = List.from(jsonDecode(map['categories_index']));
  // }

  int get id => _id;

  String get name => _name;

  List<int> get categoriesIndex => _categoriesIndex;

 const SectionModel({
   required int id,
   required String name,
   required List<int> categoriesIndex,
 })
     : _id = id,
       _name = name,
       _categoriesIndex = categoriesIndex;
}
