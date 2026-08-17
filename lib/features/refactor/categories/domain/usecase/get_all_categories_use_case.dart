import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';
import 'package:azkark/features/refactor/categories/domain/repository/category_repository.dart';

class GetAllCategoriesUseCase {
  const GetAllCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Result<List<CategoryEntity>>> call() =>
      _repository.getAllCategories();
}
