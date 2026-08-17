import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/asmaallah/domain/entity/asma_allah_entity.dart';
import 'package:azkark/features/refactor/asmaallah/domain/repository/asma_allah_repository.dart';

class GetAllAsmaAllahUseCase {
  const GetAllAsmaAllahUseCase(this._repository);

  final AsmaAllahRepository _repository;

  Future<Result<List<AsmaAllahEntity>>> call() =>
      _repository.getAllAsmaAllah();
}
