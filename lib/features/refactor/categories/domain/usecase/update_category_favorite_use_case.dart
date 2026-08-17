import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/categories/domain/repository/category_repository.dart';

class UpdateCategoryFavoriteUseCase {
  const UpdateCategoryFavoriteUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Result<void>> call({
    required int id,
    required bool favorite,
  }) {
    return _repository.updateFavorite(id: id, favorite: favorite);
  }
}
