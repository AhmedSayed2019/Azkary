import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/azkar/data/datasource/local/azkar_local_datasource.dart';
import 'package:azkark/features/refactor/azkar/domain/entity/zekr_entity.dart';
import 'package:azkark/features/refactor/azkar/domain/repository/azkar_repository.dart';

class AzkarRepositoryImp implements AzkarRepository {
  const AzkarRepositoryImp(this._localDataSource);

  final AzkarLocalDataSource _localDataSource;

  @override
  Future<Result<List<ZekrEntity>>> getAzkar({
    required String azkarIndex,
  }) async {
    final result = await _localDataSource.getAzkar(azkarIndex);
    return switch (result) {
      Ok(:final data) => Ok(data.map((m) => m.toEntity()).toList()),
      Err(:final message) => Err(message),
    };
  }
}
