import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/azkar/domain/entity/zekr_entity.dart';
import 'package:azkark/features/refactor/azkar/domain/repository/azkar_repository.dart';

class GetAzkarUseCase {
  const GetAzkarUseCase(this._repository);

  final AzkarRepository _repository;

  Future<Result<List<ZekrEntity>>> call({required String azkarIndex}) =>
      _repository.getAzkar(azkarIndex: azkarIndex);
}
