import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/prayer/domain/entity/prayer_entity.dart';

/// Contract for reading/writing prayer-guide verses. Implemented by
/// [PrayerRepositoryImp] in the data layer; use cases depend on this
/// abstraction only.
abstract interface class PrayerRepository {
  Future<Result<List<PrayerEntity>>> getAllPrayer();

  Future<Result<void>> updateFavorite({
    required int id,
    required bool favorite,
  });
}
