import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/domain/repository/settings_repository.dart';

class UpdateFontFamilyUseCase {
  const UpdateFontFamilyUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(int value) => _repository.updateFontFamily(value);
}
