import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/prayer/domain/entity/prayer_entity.dart';
import 'package:azkark/features/refactor/prayer/domain/repository/prayer_repository.dart';

class GetAllPrayerUseCase {
  const GetAllPrayerUseCase(this._repository);

  final PrayerRepository _repository;

  Future<Result<List<PrayerEntity>>> call() => _repository.getAllPrayer();
}
