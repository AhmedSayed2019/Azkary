import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/settings/data/model/settings_model.dart';
import 'package:azkark/providers/settings_provider.dart';

/// Wraps the legacy [SettingsProvider] singleton rather than talking to
/// `DatabaseHelper` directly.
///
/// `SettingsProvider` is still read (via `Provider.of`/`getIt`) by ~10
/// far-flung widgets/pages across the app (azkar, asmaallah, prayer,
/// favorites, search, categories, sebha widgets, sections bootstrap) that
/// were left untouched by this migration (see settings feature migration
/// report). Those call sites only ever read the value once (`listen:
/// false`), from the *same* `SettingsProvider` instance registered in
/// `getIt`. If this datasource wrote straight to the database it would
/// desync from that shared in-memory cache: other, already-built screens
/// would keep showing stale values (font size/family, counter/diacritics/
/// sanad toggles) until the app restarted. Routing every read/write through
/// the existing singleton keeps a single source of truth so the new
/// Settings screen and every legacy consumer always agree.
class SettingsLocalDataSource {
  SettingsLocalDataSource(this._settingsProvider);

  final SettingsProvider _settingsProvider;

  Future<Result<SettingsModel>> getSettings() async {
    try {
      final counterField = _settingsProvider.getsettingField('counter');
      final diacriticsField = _settingsProvider.getsettingField('diacritics');
      final sanadField = _settingsProvider.getsettingField('sanad');
      final fontFamilyField = _settingsProvider.getsettingField('font_family');
      final fontSizeField = _settingsProvider.getsettingField('font_size');

      if (counterField is! bool ||
          diacriticsField is! bool ||
          sanadField is! bool ||
          fontFamilyField is! int ||
          fontSizeField is! num) {
        return const Err('Settings have not finished loading yet.');
      }

      return Ok(SettingsModel(
        counter: counterField ? 1 : 0,
        diacritics: diacriticsField ? 1 : 0,
        sanad: sanadField ? 1 : 0,
        fontFamily: fontFamilyField,
        fontSize: fontSizeField.toDouble(),
      ));
    } catch (e) {
      return Err('Failed to load settings: $e');
    }
  }

  Future<Result<void>> updateField(String nameField, dynamic value) async {
    try {
      final success = await _settingsProvider.updateSettings(nameField, value);
      if (!success) {
        return Err('Failed to update settings field: $nameField');
      }
      return const Ok(null);
    } catch (e) {
      return Err('Failed to update settings field $nameField: $e');
    }
  }
}
