import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/data/datasource/local/settings_local_datasource.dart';
import 'package:azkark/features/refactor/settings/domain/entity/settings_entity.dart';
import 'package:azkark/features/refactor/settings/domain/repository/settings_repository.dart';

class SettingsRepositoryImp implements SettingsRepository {
  const SettingsRepositoryImp(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Result<SettingsEntity>> getSettings() async {
    final result = await _localDataSource.getSettings();
    return switch (result) {
      Ok(:final data) => Ok(data.toEntity()),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<void>> updateCounter(bool value) =>
      _localDataSource.updateField('counter', value ? 1 : 0);

  @override
  Future<Result<void>> updateDiacritics(bool value) =>
      _localDataSource.updateField('diacritics', value ? 1 : 0);

  @override
  Future<Result<void>> updateSanad(bool value) =>
      _localDataSource.updateField('sanad', value ? 1 : 0);

  @override
  Future<Result<void>> updateFontFamily(int value) =>
      _localDataSource.updateField('font_family', value);

  @override
  Future<Result<void>> updateFontSize(double value) =>
      _localDataSource.updateField('font_size', value);
}
