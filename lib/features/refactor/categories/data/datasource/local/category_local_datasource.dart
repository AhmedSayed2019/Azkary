import 'package:azkark/core/result.dart';
import 'package:azkark/database/database_helper.dart';
import 'package:azkark/features/refactor/categories/data/model/category_model.dart';

/// Wraps every [DatabaseHelper] call needed by the categories feature and
/// never throws — failures are surfaced as [Err] so the repository/use-case/
/// VM layers above never have to deal with a raw exception.
class CategoryLocalDataSource {
  CategoryLocalDataSource(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  static const String _table = 'categories';

  Future<Result<List<CategoryModel>>> getAllCategories() async {
    try {
      final rows = await _databaseHelper.getData(_table, '-1');
      return Ok(rows.map(CategoryModel.fromMap).toList());
    } catch (e) {
      return Err('Failed to load categories: $e');
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
      return Err('Failed to update category favorite: $e');
    }
  }
}
