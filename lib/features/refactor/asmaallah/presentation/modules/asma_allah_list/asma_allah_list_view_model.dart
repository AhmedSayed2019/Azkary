import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/asmaallah/domain/entity/asma_allah_entity.dart';
import 'package:azkark/features/refactor/asmaallah/domain/usecase/get_all_asma_allah_use_case.dart';
import 'package:flutter/foundation.dart';

class AsmaAllahListViewModel extends ChangeNotifier {
  final _tag = 'AsmaAllahListViewModel';

  AsmaAllahListViewModel({
    required GetAllAsmaAllahUseCase getAllAsmaAllah,
  }) : _getAllAsmaAllah = getAllAsmaAllah;

  final GetAllAsmaAllahUseCase _getAllAsmaAllah;
  bool _disposed = false;

  ///Variables
  List<AsmaAllahEntity> _items = [];
  List<bool> _showDescription = [];
  bool _showAllDescription = false;
  bool _isLoading = false;
  String? _error;

  ///Getters
  List<AsmaAllahEntity> get items => _items;

  /// Names of every loaded item — used to seed the search screen, mirroring
  /// the legacy `AsmaAllahProvider.allAmaAllah` getter.
  List<String> get allNames => _items.map((e) => e.name).toList();

  bool get showAllDescription => _showAllDescription;

  bool get isLoading => _isLoading;

  String? get error => _error;

  /// Whether the description for [index] is currently expanded. Bounds are
  /// checked defensively — the legacy screen indexed a separate `List<bool>`
  /// built once in `initState` with no guard, which could throw a
  /// `RangeError` if the underlying data changed shape after first build.
  bool showDescriptionAt(int index) {
    if (index < 0 || index >= _showDescription.length) return false;
    return _showDescription[index];
  }

  ///Calling API functions

  Future<void> init() => load();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();

    final result = await _getAllAsmaAllah();
    switch (result) {
      case Ok(:final data):
        _items = data;
        _showDescription = List<bool>.filled(data.length, _showAllDescription);
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.load: $message');
    }

    _isLoading = false;
    _notify();
  }

  Future<void> retry() => load();

  void toggleDescriptionAt(int index) {
    if (index < 0 || index >= _showDescription.length) return;
    _showDescription[index] = !_showDescription[index];
    _notify();
  }

  /// Expands/collapses every item's description at once, mirroring the
  /// legacy app bar's "show all descriptions" toggle.
  void toggleAllDescriptions() {
    _showAllDescription = !_showAllDescription;
    _showDescription = List<bool>.filled(_items.length, _showAllDescription);
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
