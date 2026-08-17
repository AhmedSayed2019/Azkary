import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/domain/repository/sebha_repository.dart';

class AddSebhaUseCase {
  const AddSebhaUseCase(this._repository);

  final SebhaRepository _repository;

  Future<Result<SebhaEntity>> call({
    required String name,
    required int counter,
  }) {
    return _repository.addSebha(name: name, counter: counter);
  }
}
