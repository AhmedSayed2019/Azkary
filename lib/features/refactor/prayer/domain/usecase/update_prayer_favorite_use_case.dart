import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/prayer/domain/repository/prayer_repository.dart';

class UpdatePrayerFavoriteUseCase {
  const UpdatePrayerFavoriteUseCase(this._repository);

  final PrayerRepository _repository;

  Future<Result<void>> call({
    required int id,
    required bool favorite,
  }) {
    return _repository.updateFavorite(id: id, favorite: favorite);
  }
}
