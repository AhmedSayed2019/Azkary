import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/delete_sebha_use_case.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/get_all_sebha_use_case.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/update_sebha_favorite_use_case.dart';
import 'package:flutter/foundation.dart';

class SebhaListViewModel extends ChangeNotifier {
  final _tag = 'SebhaListViewModel';

  SebhaListViewModel({
    required GetAllSebhaUseCase getAllSebha,
    required DeleteSebhaUseCase deleteSebha,
    required UpdateSebhaFavoriteUseCase updateSebhaFavorite,
  })  : _getAllSebha = getAllSebha,
        _deleteSebha = deleteSebha,
        _updateSebhaFavorite = updateSebhaFavorite;

  final GetAllSebhaUseCase _getAllSebha;
  final DeleteSebhaUseCase _deleteSebha;
  final UpdateSebhaFavoriteUseCase _updateSebhaFavorite;
  bool _disposed = false;

  ///Variables
  List<SebhaEntity> _items = [];
  bool _isLoading = false;
  String? _error;

  ///Getters
  List<SebhaEntity> get items => _items;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ///Calling API functions

  Future<void> init() => load();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();

    final result = await _getAllSebha();
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

  /// Inserts [entity] (new item) or replaces the existing one with the same
  /// id, without a full reload — used after add/edit succeed.
  void upsertLocally(SebhaEntity entity) {
    final index = _items.indexWhere((e) => e.id == entity.id);
    final next = [..._items];
    if (index == -1) {
      next.add(entity);
    } else {
      next[index] = entity;
    }
    _items = next;
    _notify();
  }

  Future<bool> deleteSebha(int id) async {
    final result = await _deleteSebha(id);
    switch (result) {
      case Ok():
        _items = _items.where((e) => e.id != id).toList();
        _notify();
        return true;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.deleteSebha: $message');
        _notify();
        return false;
    }
  }

  Future<bool> toggleFavorite(SebhaEntity entity) async {
    final favorite = !entity.favorite;
    final result =
        await _updateSebhaFavorite(id: entity.id, favorite: favorite);
    switch (result) {
      case Ok():
        upsertLocally(entity.copyWith(favorite: favorite));
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
