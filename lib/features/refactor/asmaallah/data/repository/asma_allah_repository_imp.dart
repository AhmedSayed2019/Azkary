import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/asmaallah/data/datasource/local/asma_allah_local_datasource.dart';
import 'package:azkark/features/refactor/asmaallah/domain/entity/asma_allah_entity.dart';
import 'package:azkark/features/refactor/asmaallah/domain/repository/asma_allah_repository.dart';

class AsmaAllahRepositoryImp implements AsmaAllahRepository {
  const AsmaAllahRepositoryImp(this._localDataSource);

  final AsmaAllahLocalDataSource _localDataSource;

  @override
  Future<Result<List<AsmaAllahEntity>>> getAllAsmaAllah() async {
    final result = await _localDataSource.getAllAsmaAllah();
    return switch (result) {
      Ok(:final data) => Ok(data.map((m) => m.toEntity()).toList()),
      Err(:final message) => Err(message),
    };
  }
}
