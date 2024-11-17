class PrayerModel {
  int _id, _ayaNumber, _favorite;
  String _surah, _aya;

  factory PrayerModel.fromMap(Map<String, dynamic> map) =>
      PrayerModel(
        id: map['id'],
        surah: map['surah'],
        ayaNumber: map['aya_number'],
        aya: map['aya'],
        favorite: map['favorite'],

      );


  PrayerModel({
    required int id,
    required int ayaNumber,
    required int favorite,
    required String surah,
    required String aya,
  })
      : _id = id,
        _ayaNumber = ayaNumber,
        _favorite = favorite,
        _surah = surah,
        _aya = aya;



  void setFavorite(int value) {
    _favorite = value;
  }

  int get id => _id;

  String get surah => _surah;

  int get ayaNumber => _ayaNumber;

  String get aya => _aya;

  int get favorite => _favorite;
}
