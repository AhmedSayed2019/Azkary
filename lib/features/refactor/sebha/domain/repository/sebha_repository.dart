import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';

/// Contract for reading/writing sebha (tasbih) items. Implemented by
/// [SebhaRepositoryImp] in the data layer; use cases depend on this
/// abstraction only.
abstract interface class SebhaRepository {
  Future<Result<List<SebhaEntity>>> getAllSebha();

  Future<Result<SebhaEntity>> addSebha({
    required String name,
    required int counter,
  });

  Future<Result<SebhaEntity>> updateSebha(SebhaEntity sebha);

  Future<Result<void>> deleteSebha(int id);

  Future<Result<void>> updateFavorite({
    required int id,
    required bool favorite,
  });
}
