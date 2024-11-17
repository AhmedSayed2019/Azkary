class ZekrModel {
 final int _id, _categoryId, _counterNumber;
 final String _textWithDiacritics, _textWithoutDiacritics, _sanad, _counterText;

 factory ZekrModel.fromMap(Map<String, dynamic> map) =>
     ZekrModel(id: map['id']??0,
         categoryId: map['category_id']??0,
         counterNumber: map['counter_number']??0,
         textWithDiacritics: map['text_with_diacritics']??'',
         textWithoutDiacritics: map['text_without_diacritics']??'',
         sanad: map['sanad']??'',
         counterText: map['counter_text']??''
     );

  // ZekrModel.fromMap(Map<String, dynamic> map) {
  //   _id = map['id'];
  //   _categoryId = map['category_id'];
  //   _textWithDiacritics = map['text_with_diacritics'];
  //   _textWithoutDiacritics = map['text_without_diacritics'];
  //   _sanad = map['sanad'];
  //   _counterText = map['counter_text'];
  //   _counterNumber = map['counter_number'];
  // }

  int get id => _id;

  int get categoryId => _categoryId;

  String get textWithDiacritics => _textWithDiacritics;

  get textWithoutDiacritics => _textWithoutDiacritics;

  String get sanad => _sanad;

  String get counterText => _counterText;

  int get counterNumber => _counterNumber;

 const ZekrModel({
   required int id,
   required int categoryId,
   required int counterNumber,
   required String textWithDiacritics,
   required String textWithoutDiacritics,
   required String sanad,
   required String counterText,
 })
     : _id = id,
       _categoryId = categoryId,
       _counterNumber = counterNumber,
       _textWithDiacritics = textWithDiacritics,
       _textWithoutDiacritics = textWithoutDiacritics,
       _sanad = sanad,
       _counterText = counterText;
}
