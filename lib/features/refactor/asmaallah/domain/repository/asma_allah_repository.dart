import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/asmaallah/domain/entity/asma_allah_entity.dart';

/// Contract for reading the 99 names of Allah. Implemented by
/// [AsmaAllahRepositoryImp] in the data layer; use cases depend on this
/// abstraction only. Read-only — the legacy `AsmaAllahProvider` never wrote
/// to the `asmaallah` table, so no mutating operations are exposed here.
abstract interface class AsmaAllahRepository {
  Future<Result<List<AsmaAllahEntity>>> getAllAsmaAllah();
}
