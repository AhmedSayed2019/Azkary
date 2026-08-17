import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/domain/repository/settings_repository.dart';

class UpdateSanadUseCase {
  const UpdateSanadUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(bool value) => _repository.updateSanad(value);
}
