import 'package:azkark/core/result.dart';
import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/sebha/data/model/sebha_model.dart';

/// Wraps every [DatabaseHelper] call needed by the sebha feature and never
/// throws — failures are surfaced as [Err] so the repository/use-case/VM
/// layers above never have to deal with a raw exception.
class SebhaLocalDataSource {
  SebhaLocalDataSource(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  static const String _table = 'tasbih';

  Future<Result<List<SebhaModel>>> getAllSebha() async {
    try {
      final rows = await _databaseHelper.getData(_table, '-1');
      return Ok(rows.map(SebhaModel.fromMap).toList());
    } catch (e) {
      return Err('Failed to load sebha items: $e');
    }
  }

  Future<Result<SebhaModel>> addSebha({
    required String name,
    required int counter,
  }) async {
    try {
      final id = await _databaseHelper.insert(_table, {
        'name': name,
        'counter': counter,
        'favorite': 0,
      });
      return Ok(SebhaModel(id: id, name: name, counter: counter, favorite: 0));
    } catch (e) {
      return Err('Failed to add sebha item: $e');
    }
  }

  Future<Result<SebhaModel>> updateSebha(SebhaModel sebha) async {
    try {
      await _databaseHelper.updateTasbih(
        id: sebha.id,
        name: sebha.name,
        counter: sebha.counter,
      );
      return Ok(sebha);
    } catch (e) {
      return Err('Failed to update sebha item: $e');
    }
  }

  Future<Result<void>> deleteSebha(int id) async {
    try {
      await _databaseHelper.delete(table: _table, id: id);
      return const Ok(null);
    } catch (e) {
      return Err('Failed to delete sebha item: $e');
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
      return Err('Failed to update sebha favorite: $e');
    }
  }
}
