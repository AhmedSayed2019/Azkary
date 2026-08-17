import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/domain/repository/settings_repository.dart';

class UpdateFontSizeUseCase {
  const UpdateFontSizeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(double value) => _repository.updateFontSize(value);
}
