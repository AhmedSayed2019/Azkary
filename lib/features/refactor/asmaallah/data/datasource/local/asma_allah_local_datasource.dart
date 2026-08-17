import 'package:azkark/core/result.dart';
import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/asmaallah/data/model/asma_allah_model.dart';

/// Wraps the [DatabaseHelper] call needed by the asmaallah (99 names of
/// Allah) feature and never throws — failures are surfaced as [Err] so the
/// repository/use-case/VM layers above never have to deal with a raw
/// exception.
class AsmaAllahLocalDataSource {
  AsmaAllahLocalDataSource(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  static const String _table = 'asmaallah';

  Future<Result<List<AsmaAllahModel>>> getAllAsmaAllah() async {
    try {
      final rows = await _databaseHelper.getData(_table, '-1');
      return Ok(rows.map(AsmaAllahModel.fromMap).toList());
    } catch (e) {
      return Err('Failed to load asmaallah items: $e');
    }
  }
}
