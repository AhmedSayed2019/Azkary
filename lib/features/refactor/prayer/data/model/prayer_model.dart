import 'package:azkark/features/refactor/prayer/domain/entity/prayer_entity.dart';

/// Data-layer DTO for a prayer-guide verse row from the local `prayer`
/// table. `favorite` is kept as the raw `0`/`1` int that sqflite stores; it
/// is converted to a `bool` only at the [toEntity] boundary.
class PrayerModel {
  const PrayerModel({
    required int id,
    required String surah,
    required int ayaNumber,
    required String aya,
    required int favorite,
  })  : _id = id,
        _surah = surah,
        _ayaNumber = ayaNumber,
        _aya = aya,
        _favorite = favorite;

  factory PrayerModel.fromMap(Map<String, dynamic> map) => PrayerModel(
        id: map['id'] as int,
        surah: map['surah'] as String,
        ayaNumber: map['aya_number'] as int,
        aya: map['aya'] as String,
        favorite: map['favorite'] as int,
      );

  factory PrayerModel.fromEntity(PrayerEntity entity) => PrayerModel(
        id: entity.id,
        surah: entity.surah,
        ayaNumber: entity.ayaNumber,
        aya: entity.aya,
        favorite: entity.favorite ? 1 : 0,
      );

  final int _id;
  final String _surah;
  final int _ayaNumber;
  final String _aya;
  final int _favorite;

  int get id => _id;

  String get surah => _surah;

  int get ayaNumber => _ayaNumber;

  String get aya => _aya;

  int get favorite => _favorite;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'surah': _surah,
        'aya_number': _ayaNumber,
        'aya': _aya,
        'favorite': _favorite,
      };

  PrayerEntity toEntity() => PrayerEntity(
        id: _id,
        surah: _surah,
        ayaNumber: _ayaNumber,
        aya: _aya,
        favorite: _favorite == 1,
      );
}
