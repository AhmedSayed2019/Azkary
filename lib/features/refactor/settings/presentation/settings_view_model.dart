import 'package:azkark/features/refactor/settings/domain/entity/settings_entity.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/get_settings_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_counter_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_diacritics_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_font_family_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_font_size_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/update_sanad_use_case.dart';
import 'package:azkark/core/result.dart';
import 'package:flutter/foundation.dart';

/// App-scoped settings ViewModel: registered as a `registerLazySingleton`
/// and exposed via `ChangeNotifierProvider` from `lib/providers.dart` (see
/// `initSettingsRefactorProvider`), *not* a per-screen factory VM. The
/// legacy `SettingsProvider` is still read directly by several far-flung
/// widgets/pages outside this feature (see
/// `SettingsLocalDataSource` for the full list and rationale) — this VM sits
/// on top of the same underlying state so both stay in sync.
class SettingsViewModel extends ChangeNotifier {
  final _tag = 'SettingsViewModel';

  SettingsViewModel({
    required GetSettingsUseCase getSettings,
    required UpdateCounterUseCase updateCounter,
    required UpdateDiacriticsUseCase updateDiacritics,
    required UpdateSanadUseCase updateSanad,
    required UpdateFontFamilyUseCase updateFontFamily,
    required UpdateFontSizeUseCase updateFontSize,
  })  : _getSettings = getSettings,
        _updateCounterUseCase = updateCounter,
        _updateDiacriticsUseCase = updateDiacritics,
        _updateSanadUseCase = updateSanad,
        _updateFontFamilyUseCase = updateFontFamily,
        _updateFontSizeUseCase = updateFontSize;

  final GetSettingsUseCase _getSettings;
  final UpdateCounterUseCase _updateCounterUseCase;
  final UpdateDiacriticsUseCase _updateDiacriticsUseCase;
  final UpdateSanadUseCase _updateSanadUseCase;
  final UpdateFontFamilyUseCase _updateFontFamilyUseCase;
  final UpdateFontSizeUseCase _updateFontSizeUseCase;

  ///Variables
  SettingsEntity? _settings;
  bool _isLoading = false;
  String? _error;

  ///Getters
  SettingsEntity? get settings => _settings;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ///Calling API functions

  Future<void> init() => load();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getSettings();
    switch (result) {
      case Ok(:final data):
        _settings = data;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.load: $message');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> retry() => load();

  Future<bool> updateCounter(bool value) async {
    final previous = _settings;
    if (previous == null) return false;
    _settings = previous.copyWith(counter: value);
    notifyListeners();

    final result = await _updateCounterUseCase(value);
    return _applyResult(result, previous, tag: 'updateCounter');
  }

  Future<bool> updateDiacritics(bool value) async {
    final previous = _settings;
    if (previous == null) return false;
    _settings = previous.copyWith(diacritics: value);
    notifyListeners();

    final result = await _updateDiacriticsUseCase(value);
    return _applyResult(result, previous, tag: 'updateDiacritics');
  }

  Future<bool> updateSanad(bool value) async {
    final previous = _settings;
    if (previous == null) return false;
    _settings = previous.copyWith(sanad: value);
    notifyListeners();

    final result = await _updateSanadUseCase(value);
    return _applyResult(result, previous, tag: 'updateSanad');
  }

  Future<bool> updateFontFamily(int value) async {
    final previous = _settings;
    if (previous == null) return false;
    _settings = previous.copyWith(fontFamily: value);
    notifyListeners();

    final result = await _updateFontFamilyUseCase(value);
    return _applyResult(result, previous, tag: 'updateFontFamily');
  }

  Future<bool> updateFontSize(double value) async {
    final previous = _settings;
    if (previous == null) return false;
    _settings = previous.copyWith(fontSize: value);
    notifyListeners();

    final result = await _updateFontSizeUseCase(value);
    return _applyResult(result, previous, tag: 'updateFontSize');
  }

  /// Reverts the optimistic update on failure so the UI never shows a value
  /// that was never actually persisted.
  bool _applyResult(Result<void> result, SettingsEntity previous,
      {required String tag}) {
    switch (result) {
      case Ok():
        return true;
      case Err(:final message):
        _settings = previous;
        _error = message;
        debugPrint('$_tag.$tag: $message');
        notifyListeners();
        return false;
    }
  }
}
