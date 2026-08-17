import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/data/datasource/local/sebha_local_datasource.dart';
import 'package:azkark/features/refactor/sebha/data/model/sebha_model.dart';
import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/domain/repository/sebha_repository.dart';

class SebhaRepositoryImp implements SebhaRepository {
  const SebhaRepositoryImp(this._localDataSource);

  final SebhaLocalDataSource _localDataSource;

  @override
  Future<Result<List<SebhaEntity>>> getAllSebha() async {
    final result = await _localDataSource.getAllSebha();
    return switch (result) {
      Ok(:final data) => Ok(data.map((m) => m.toEntity()).toList()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<SebhaEntity>> addSebha({
    required String name,
    required int counter,
  }) async {
    final result =
        await _localDataSource.addSebha(name: name, counter: counter);
    return switch (result) {
      Ok(:final data) => Ok(data.toEntity()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<SebhaEntity>> updateSebha(SebhaEntity sebha) async {
    final result =
        await _localDataSource.updateSebha(SebhaModel.fromEntity(sebha));
    return switch (result) {
      Ok(:final data) => Ok(data.toEntity()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<void>> deleteSebha(int id) => _localDataSource.deleteSebha(id);

  @override
  Future<Result<void>> updateFavorite({
    required int id,
    required bool favorite,
  }) {
    return _localDataSource.updateFavorite(id: id, favorite: favorite);
  }
}
