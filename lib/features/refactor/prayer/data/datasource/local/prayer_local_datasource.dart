import 'package:azkark/core/result.dart';
import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/prayer/data/model/prayer_model.dart';

/// Wraps every [DatabaseHelper] call needed by the prayer feature and never
/// throws — failures are surfaced as [Err] so the repository/use-case/VM
/// layers above never have to deal with a raw exception.
class PrayerLocalDataSource {
  PrayerLocalDataSource(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  static const String _table = 'prayer';

  Future<Result<List<PrayerModel>>> getAllPrayer() async {
    try {
      final rows = await _databaseHelper.getData(_table, '-1');
      return Ok(rows.map(PrayerModel.fromMap).toList());
    } catch (e) {
      return Err('Failed to load prayer items: $e');
    }
  }

  Future<Result<void>> updateFavorite({
    required int id,
    required bool favorite,
  }) async {
    try {
      await _databaseHelper.updateFavoriteInTables(
        _table,
        favorite ? 1 : 0,
        id,
      );
      return const Ok(null);
    } catch (e) {
      return Err('Failed to update prayer favorite: $e');
    }
  }
}
