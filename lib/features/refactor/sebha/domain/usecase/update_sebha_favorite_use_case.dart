import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/repository/sebha_repository.dart';

class UpdateSebhaFavoriteUseCase {
  const UpdateSebhaFavoriteUseCase(this._repository);

  final SebhaRepository _repository;

  Future<Result<void>> call({
    required int id,
    required bool favorite,
  }) {
    return _repository.updateFavorite(id: id, favorite: favorite);
  }
}
