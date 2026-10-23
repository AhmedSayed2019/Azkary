import 'package:azkark/core/result.dart';
import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/azkar/data/model/zekr_model.dart';

/// Wraps every [DatabaseHelper] call needed by the azkar feature and never
/// throws — failures are surfaced as [Err] so the repository/use-case/VM
/// layers above never have to deal with a raw exception.
class AzkarLocalDataSource {
  AzkarLocalDataSource(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  static const String _table = 'azkar';

  /// [azkarIndex] is the category's raw `azkar_index` column — a
  /// comma-separated id list. `DatabaseHelper.getData` preserves that order
  /// in its `ORDER BY CASE id` clause, which is why the legacy
  /// `AzkarProvider.sortByIds` re-sort was dead weight and is not ported.
  Future<Result<List<ZekrModel>>> getAzkar(String azkarIndex) async {
    try {
      final rows = await _databaseHelper.getData(_table, azkarIndex);
      return Ok(rows.map(ZekrModel.fromMap).toList());
    } catch (e) {
      return Err('Failed to load azkar: $e');
    }
  }
}
