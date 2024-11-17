
class SurahModel {
  final int _id;
  final int _jozz;
  final int _suraNo;
  final String _suraNameEn;
  final String _suraNameAr;
  final int _page;
  final int _lineStart;
  final int _lineEnd;
  final int _ayaNo;
  final String _ayaText;
  final String _ayaTextEmlaey;

  factory SurahModel.fromJson(Map<String, dynamic> json) => SurahModel(
    id: json["id"],
    jozz: json["jozz"],
    suraNo: json["sura_no"],
    suraNameEn: json["sura_name_en"],
    suraNameAr: json["sura_name_ar"],
    page: json["page"],
    lineStart: json["line_start"],
    lineEnd: json["line_end"],
    ayaNo: json["aya_no"],
    ayaText: json["aya_text"],
    ayaTextEmlaey: json["aya_text_emlaey"],
  );



  const SurahModel({
    required int id,
    required int jozz,
    required int suraNo,
    required String suraNameEn,
    required String suraNameAr,
    required int page,
    required int lineStart,
    required int lineEnd,
    required int ayaNo,
    required String ayaText,
    required String ayaTextEmlaey,
  })  : _id = id,
        _jozz = jozz,
        _suraNo = suraNo,
        _suraNameEn = suraNameEn,
        _suraNameAr = suraNameAr,
        _page = page,
        _lineStart = lineStart,
        _lineEnd = lineEnd,
        _ayaNo = ayaNo,
        _ayaText = ayaText,
        _ayaTextEmlaey = ayaTextEmlaey;

  String get ayaText => _ayaText;

  String get suraNameAr => _suraNameAr;

  int get page => _page;
}
