import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';
import 'package:azkark/features/refactor/categories/domain/usecase/get_all_categories_use_case.dart';
import 'package:azkark/features/refactor/categories/domain/usecase/update_category_favorite_use_case.dart';
import 'package:flutter/foundation.dart';

/// Replaces the legacy `CategoriesProvider` for the "all categories" list
/// screen. A per-screen factory VM (not an app-scoped singleton) — see
/// `presentation/injection.dart` for the registration rationale.
class CategoriesListViewModel extends ChangeNotifier {
  final _tag = 'CategoriesListViewModel';

  CategoriesListViewModel({
    required GetAllCategoriesUseCase getAllCategories,
    required UpdateCategoryFavoriteUseCase updateCategoryFavorite,
  })  : _getAllCategories = getAllCategories,
        _updateCategoryFavorite = updateCategoryFavorite;

  final GetAllCategoriesUseCase _getAllCategories;
  final UpdateCategoryFavoriteUseCase _updateCategoryFavorite;
  bool _disposed = false;

  ///Variables
  List<CategoryEntity> _items = [];
  bool _isLoading = false;
  String? _error;

  ///Getters
  List<CategoryEntity> get items => _items;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ///Calling API functions

  Future<void> init() => load();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();

    final result = await _getAllCategories();
    switch (result) {
      case Ok(:final data):
        _items = data;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.load: $message');
    }

    _isLoading = false;
    _notify();
  }

  Future<void> retry() => load();

  List<String> get allCategoryNames =>
      _items.map((e) => e.nameWithoutDiacritics).toList();

  Future<bool> toggleFavorite(CategoryEntity entity) async {
    final favorite = !entity.favorite;
    final result =
        await _updateCategoryFavorite(id: entity.id, favorite: favorite);
    switch (result) {
      case Ok():
        _upsertLocally(entity.copyWith(favorite: favorite));
        return true;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.toggleFavorite: $message');
        _notify();
        return false;
    }
  }

  void _upsertLocally(CategoryEntity entity) {
    final index = _items.indexWhere((e) => e.id == entity.id);
    if (index == -1) return;
    final next = [..._items];
    next[index] = entity;
    _items = next;
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
