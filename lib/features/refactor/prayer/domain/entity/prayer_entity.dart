import 'package:equatable/equatable.dart';

/// Immutable domain representation of a single prayer-guide verse (aya)
/// grouped under a surah name.
class PrayerEntity extends Equatable {
  const PrayerEntity({
    required int id,
    required String surah,
    required int ayaNumber,
    required String aya,
    required bool favorite,
  })  : _id = id,
        _surah = surah,
        _ayaNumber = ayaNumber,
        _aya = aya,
        _favorite = favorite;

  final int _id;
  final String _surah;
  final int _ayaNumber;
  final String _aya;
  final bool _favorite;

  int get id => _id;

  String get surah => _surah;

  int get ayaNumber => _ayaNumber;

  String get aya => _aya;

  bool get favorite => _favorite;

  PrayerEntity copyWith({bool? favorite}) {
    return PrayerEntity(
      id: _id,
      surah: _surah,
      ayaNumber: _ayaNumber,
      aya: _aya,
      favorite: favorite ?? _favorite,
    );
  }

  @override
  List<Object?> get props => [_id, _surah, _ayaNumber, _aya, _favorite];
}
