import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/prayer/data/datasource/local/prayer_local_datasource.dart';
import 'package:azkark/features/refactor/prayer/domain/entity/prayer_entity.dart';
import 'package:azkark/features/refactor/prayer/domain/repository/prayer_repository.dart';

class PrayerRepositoryImp implements PrayerRepository {
  const PrayerRepositoryImp(this._localDataSource);

  final PrayerLocalDataSource _localDataSource;

  @override
  Future<Result<List<PrayerEntity>>> getAllPrayer() async {
    final result = await _localDataSource.getAllPrayer();
    return switch (result) {
      Ok(:final data) => Ok(data.map((m) => m.toEntity()).toList()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<void>> updateFavorite({
    required int id,
    required bool favorite,
  }) {
    return _localDataSource.updateFavorite(id: id, favorite: favorite);
  }
}
