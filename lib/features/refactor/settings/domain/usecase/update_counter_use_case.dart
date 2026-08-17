import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/domain/repository/settings_repository.dart';

class UpdateCounterUseCase {
  const UpdateCounterUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(bool value) => _repository.updateCounter(value);
}
