import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/domain/repository/sebha_repository.dart';

class GetAllSebhaUseCase {
  const GetAllSebhaUseCase(this._repository);

  final SebhaRepository _repository;

  Future<Result<List<SebhaEntity>>> call() => _repository.getAllSebha();
}
