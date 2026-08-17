import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/domain/repository/sebha_repository.dart';

class UpdateSebhaUseCase {
  const UpdateSebhaUseCase(this._repository);

  final SebhaRepository _repository;

  Future<Result<SebhaEntity>> call(SebhaEntity sebha) {
    return _repository.updateSebha(sebha);
  }
}
