import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/prayer/domain/entity/prayer_entity.dart';
import 'package:azkark/features/refactor/prayer/domain/usecase/get_all_prayer_use_case.dart';
import 'package:azkark/features/refactor/prayer/domain/usecase/update_prayer_favorite_use_case.dart';
import 'package:flutter/foundation.dart';

class PrayerListViewModel extends ChangeNotifier {
  final _tag = 'PrayerListViewModel';

  PrayerListViewModel({
    required GetAllPrayerUseCase getAllPrayer,
    required UpdatePrayerFavoriteUseCase updatePrayerFavorite,
  })  : _getAllPrayer = getAllPrayer,
        _updatePrayerFavorite = updatePrayerFavorite;

  final GetAllPrayerUseCase _getAllPrayer;
  final UpdatePrayerFavoriteUseCase _updatePrayerFavorite;
  bool _disposed = false;

  ///Variables
  List<PrayerEntity> _items = [];
  List<String> _surahNames = [];
  bool _isLoading = false;
  String? _error;

  ///Getters
  List<PrayerEntity> get items => _items;

  /// Unique surah names, in the order they first appear in [items] —
  /// replaces the legacy `PrayerProvider._prayerGuide` map keys.
  List<String> get surahNames => _surahNames;

  bool get isLoading => _isLoading;

  String? get error => _error;

  /// All verses belonging to [surah], in table order. Safe even if [surah]
  /// is unknown (returns an empty list instead of throwing, unlike the
  /// legacy `PrayerProvider.getAyatSurah` which used a `!` non-null
  /// assertion on a possibly-missing map key).
  List<PrayerEntity> ayatOfSurah(String surah) =>
      _items.where((e) => e.surah == surah).toList(growable: false);

  ///Calling API functions

  Future<void> init() => load();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();

    final result = await _getAllPrayer();
    switch (result) {
      case Ok(:final data):
        _items = data;
        _surahNames = _items.map((e) => e.surah).toSet().toList(growable: false);
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.load: $message');
    }

    _isLoading = false;
    _notify();
  }

  Future<void> retry() => load();

  Future<bool> toggleFavorite(PrayerEntity entity) async {
    final favorite = !entity.favorite;
    final result =
        await _updatePrayerFavorite(id: entity.id, favorite: favorite);
    switch (result) {
      case Ok():
        final index = _items.indexWhere((e) => e.id == entity.id);
        if (index != -1) {
          final next = [..._items];
          next[index] = entity.copyWith(favorite: favorite);
          _items = next;
        }
        _notify();
        return true;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.toggleFavorite: $message');
        _notify();
        return false;
    }
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
