import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/domain/entity/settings_entity.dart';

/// Contract for reading/writing the app settings row. Implemented by
/// [SettingsRepositoryImp] in the data layer; use cases depend on this
/// abstraction only.
abstract interface class SettingsRepository {
  Future<Result<SettingsEntity>> getSettings();

  Future<Result<void>> updateCounter(bool value);

  Future<Result<void>> updateDiacritics(bool value);

  Future<Result<void>> updateSanad(bool value);

  Future<Result<void>> updateFontFamily(int value);

  Future<Result<void>> updateFontSize(double value);
}
