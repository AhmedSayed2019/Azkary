import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/domain/entity/settings_entity.dart';
import 'package:azkark/features/refactor/settings/domain/repository/settings_repository.dart';

class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<SettingsEntity>> call() => _repository.getSettings();
}
