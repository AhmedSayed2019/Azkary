import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';

/// Contract for reading/writing azkar categories. Implemented by
/// [CategoryRepositoryImp] in the data layer; use cases depend on this
/// abstraction only.
abstract interface class CategoryRepository {
  Future<Result<List<CategoryEntity>>> getAllCategories();

  Future<Result<void>> updateFavorite({
    required int id,
    required bool favorite,
  });
}
