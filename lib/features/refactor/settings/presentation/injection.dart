import 'package:azkark/features/refactor/settings/data/datasource/local/settings_local_datasource.dart';
import 'package:azkark/features/refactor/settings/data/repository/settings_repository_imp.dart';
import 'package:azkark/features/refactor/settings/domain/repository/settings_repository.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/get_settings_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_counter_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_diacritics_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_font_family_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_font_size_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_sanad_use_case.dart';
import 'package:azkark/features/refactor/settings/presentation/settings_view_model.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/providers/settings_provider.dart';

/// Registers the settings refactor slice with GetIt. Called once from
/// `lib/injection.dart` alongside the app's other init calls — must run
/// after `SettingsProvider` has already been registered there, since
/// [SettingsLocalDataSource] wraps that existing singleton (see its doc
/// comment for why).
Future<void> initSettingsRefactorFeatures() async {
  if (!getIt.isRegistered<SettingsLocalDataSource>()) {
    getIt.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSource(getIt<SettingsProvider>()),
    );
  }

  if (!getIt.isRegistered<SettingsRepository>()) {
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImp(getIt<SettingsLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetSettingsUseCase>()) {
    getIt.registerLazySingleton<GetSettingsUseCase>(
      () => GetSettingsUseCase(getIt<SettingsRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateCounterUseCase>()) {
    getIt.registerLazySingleton<UpdateCounterUseCase>(
      () => UpdateCounterUseCase(getIt<SettingsRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateDiacriticsUseCase>()) {
    getIt.registerLazySingleton<UpdateDiacriticsUseCase>(
      () => UpdateDiacriticsUseCase(getIt<SettingsRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateSanadUseCase>()) {
    getIt.registerLazySingleton<UpdateSanadUseCase>(
      () => UpdateSanadUseCase(getIt<SettingsRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateFontFamilyUseCase>()) {
    getIt.registerLazySingleton<UpdateFontFamilyUseCase>(
      () => UpdateFontFamilyUseCase(getIt<SettingsRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateFontSizeUseCase>()) {
    getIt.registerLazySingleton<UpdateFontSizeUseCase>(
      () => UpdateFontSizeUseCase(getIt<SettingsRepository>()),
    );
  }

  // App-scoped VM (registerLazySingleton, not registerFactory): SettingsEntity
  // backs UI across many screens today via the legacy SettingsProvider, so
  // this VM is exposed the same way — one shared instance wired into
  // `lib/providers.dart` via `ChangeNotifierProvider`.
  if (!getIt.isRegistered<SettingsViewModel>()) {
    getIt.registerLazySingleton<SettingsViewModel>(
      () => SettingsViewModel(
        getSettings: getIt<GetSettingsUseCase>(),
        updateCounter: getIt<UpdateCounterUseCase>(),
        updateDiacritics: getIt<UpdateDiacriticsUseCase>(),
        updateSanad: getIt<UpdateSanadUseCase>(),
        updateFontFamily: getIt<UpdateFontFamilyUseCase>(),
        updateFontSize: getIt<UpdateFontSizeUseCase>(),
      ),
    );
  }
}
