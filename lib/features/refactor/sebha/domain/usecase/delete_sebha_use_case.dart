import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/repository/sebha_repository.dart';

class DeleteSebhaUseCase {
  const DeleteSebhaUseCase(this._repository);

  final SebhaRepository _repository;

  Future<Result<void>> call(int id) => _repository.deleteSebha(id);
}
