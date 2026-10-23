import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/azkar/domain/entity/zekr_entity.dart';

/// Contract for reading the azkar of one category. Implemented by
/// [AzkarRepositoryImp] in the data layer; use cases depend on this
/// abstraction only.
abstract interface class AzkarRepository {
  Future<Result<List<ZekrEntity>>> getAzkar({required String azkarIndex});
}
