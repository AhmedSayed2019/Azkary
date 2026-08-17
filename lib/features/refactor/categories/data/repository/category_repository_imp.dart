import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/categories/data/datasource/local/category_local_datasource.dart';
import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';
import 'package:azkark/features/refactor/categories/domain/repository/category_repository.dart';

class CategoryRepositoryImp implements CategoryRepository {
  const CategoryRepositoryImp(this._localDataSource);

  final CategoryLocalDataSource _localDataSource;

  @override
  Future<Result<List<CategoryEntity>>> getAllCategories() async {
    final result = await _localDataSource.getAllCategories();
    return switch (result) {
      Ok(:final data) => Ok(data.map((m) => m.toEntity()).toList()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<void>> updateFavorite({
    required int id,
    required bool favorite,
  }) {
    return _localDataSource.updateFavorite(id: id, favorite: favorite);
  }
}
