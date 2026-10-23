import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/azkar/domain/entity/zekr_entity.dart';
import 'package:azkark/features/refactor/azkar/domain/usecase/get_azkar_use_case.dart';
import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';
import 'package:azkark/features/refactor/categories/domain/usecase/update_category_favorite_use_case.dart';
import 'package:azkark/features/refactor/settings/domain/usecase/get_settings_use_case.dart';
import 'package:flutter/foundation.dart';

/// Replaces the legacy `AzkarProvider` + the `setState` bookkeeping that
/// lived inside `ViewAzkar`: the zekr list, the per-zekr counters, the sanad
/// toggles and the reading preferences are all owned here.
///
/// Two of its use cases come from sibling slices — `UpdateCategoryFavoriteUseCase`
/// (categories) and `GetSettingsUseCase` (settings). Both are *domain*
/// dependencies injected through GetIt, which keeps the `categories` and
/// `settings` tables owned by exactly one datasource instead of being written
/// from two places.
class AzkarListViewModel extends ChangeNotifier {
  final _tag = 'AzkarListViewModel';

  AzkarListViewModel({
    required GetAzkarUseCase getAzkar,
    required GetSettingsUseCase getSettings,
    required UpdateCategoryFavoriteUseCase updateCategoryFavorite,
  })  : _getAzkar = getAzkar,
        _getSettings = getSettings,
        _updateCategoryFavorite = updateCategoryFavorite;

  final GetAzkarUseCase _getAzkar;
  final GetSettingsUseCase _getSettings;
  final UpdateCategoryFavoriteUseCase _updateCategoryFavorite;
  bool _disposed = false;

  ///Variables
  CategoryEntity? _category;
  List<ZekrEntity> _items = [];
  List<int> _counters = const [];
  List<bool> _sanadVisible = const [];
  bool _isLoading = false;
  String? _error;
  bool _counterEnabled = false;
  bool _diacriticsEnabled = false;
  bool _sanadEnabled = false;
  bool _showFontSlider = false;
  double _fontSize = 18;
  String _fontFamily = '0';

  ///Getters
  List<ZekrEntity> get items => _items;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get counterEnabled => _counterEnabled;

  bool get diacriticsEnabled => _diacriticsEnabled;

  bool get sanadEnabled => _sanadEnabled;

  bool get showFontSlider => _showFontSlider;

  double get fontSize => _fontSize;

  String get fontFamily => _fontFamily;

  bool get favorite => _category?.favorite ?? false;

  String get title {
    final category = _category;
    if (category == null) return '';
    return _diacriticsEnabled
        ? category.nameWithDiacritics
        : category.nameWithoutDiacritics;
  }

  int counterAt(int index) => index < _counters.length ? _counters[index] : 0;

  bool sanadVisibleAt(int index) =>
      index < _sanadVisible.length && _sanadVisible[index];

  ///Calling API functions

  /// Seeds the VM with the category whose azkar are about to be read. Called
  /// by the screen's `initState` before [init] — the screen receives the
  /// entity as a route parameter.
  void configure(CategoryEntity category) {
    _category = category;
  }

  Future<void> init() => load();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();

    await _loadSettings();

    final result = await _getAzkar(azkarIndex: _category?.azkarIndex ?? '');
    switch (result) {
      case Ok(:final data):
        _items = data;
        _counters = List<int>.filled(data.length, 0);
        _sanadVisible = List<bool>.filled(data.length, _sanadEnabled);
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.load: $message');
    }

    _isLoading = false;
    _notify();
  }

  Future<void> retry() => load();

  /// Reading preferences are a nice-to-have on this screen: if they fail to
  /// load the azkar are still readable with the defaults, so a failure here
  /// never becomes the screen's [error].
  Future<void> _loadSettings() async {
    final result = await _getSettings();
    switch (result) {
      case Ok(:final data):
        _counterEnabled = data.counter;
        _diacriticsEnabled = data.diacritics;
        _sanadEnabled = data.sanad;
        _fontSize = data.fontSize;
        _fontFamily = '${data.fontFamily}';
      case Err(:final message):
        debugPrint('$_tag._loadSettings: $message');
    }
  }

  Future<bool> toggleFavorite() async {
    final category = _category;
    if (category == null) return false;

    final favorite = !category.favorite;
    _category = category.copyWith(favorite: favorite);
    _notify();

    final result =
        await _updateCategoryFavorite(id: category.id, favorite: favorite);
    switch (result) {
      case Ok():
        return true;
      case Err(:final message):
        // الرجوع للحالة السابقة: لا نُظهر نجمة مفضّلة لم تُحفظ فعلًا
        _category = category;
        _error = message;
        debugPrint('$_tag.toggleFavorite: $message');
        _notify();
        return false;
    }
  }

  void toggleCounter() {
    // إطفاء العدّاد يصفّر التسبيح الجاري — تمامًا كما كان في ViewAzkar
    if (_counterEnabled) _counters = List<int>.filled(_items.length, 0);
    _counterEnabled = !_counterEnabled;
    _notify();
  }

  void toggleDiacritics() {
    _diacriticsEnabled = !_diacriticsEnabled;
    _notify();
  }

  void toggleSanad() {
    _sanadEnabled = !_sanadEnabled;
    _sanadVisible = List<bool>.filled(_items.length, _sanadEnabled);
    _notify();
  }

  void toggleSanadAt(int index) {
    if (index < 0 || index >= _sanadVisible.length) return;
    final next = [..._sanadVisible];
    next[index] = !next[index];
    _sanadVisible = next;
    _notify();
  }

  void increment(int index) {
    if (index < 0 || index >= _counters.length) return;
    if (_counters[index] >= _items[index].counterNumber) return;
    final next = [..._counters];
    next[index] = next[index] + 1;
    _counters = next;
    _notify();
  }

  void resetCounterAt(int index) {
    if (index < 0 || index >= _counters.length) return;
    if (_counters[index] == 0) return;
    final next = [..._counters];
    next[index] = 0;
    _counters = next;
    _notify();
  }

  void resetAllCounters() {
    if (_counters.every((c) => c == 0)) return;
    _counters = List<int>.filled(_items.length, 0);
    _notify();
  }

  void toggleFontSlider() {
    _showFontSlider = !_showFontSlider;
    _notify();
  }

  void setFontSize(double value) {
    if (_fontSize == value) return;
    _fontSize = value;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
