import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/add_sebha_use_case.dart';
import 'package:azkark/features/refactor/sebha/domain/usecase/update_sebha_use_case.dart';
import 'package:flutter/foundation.dart';

class AddEditSebhaViewModel extends ChangeNotifier {
  final _tag = 'AddEditSebhaViewModel';

  AddEditSebhaViewModel({
    required AddSebhaUseCase addSebha,
    required UpdateSebhaUseCase updateSebha,
  })  : _addSebha = addSebha,
        _updateSebha = updateSebha;

  final AddSebhaUseCase _addSebha;
  final UpdateSebhaUseCase _updateSebha;
  bool _disposed = false;

  ///Variables
  String _name = '';
  int _counter = 0;
  bool _isSaving = false;
  String? _error;

  ///Getters
  String get name => _name;

  int get counter => _counter;

  bool get isSaving => _isSaving;

  String? get error => _error;

  ///Calling API functions

  /// Seeds the form for either "add" ([existing] == null) or "edit".
  void configure(SebhaEntity? existing) {
    _name = existing?.name ?? '';
    _counter = existing?.counter ?? 0;
  }

  void onNameChanged(String value) {
    _name = value;
    _notify();
  }

  void onCounterChanged(String value) {
    // Bug fix: the legacy dialog called int.parse(value) directly here,
    // which threw whenever the field was emptied. Parse defensively.
    _counter = int.tryParse(value) ?? 0;
    _notify();
  }

  Future<SebhaEntity?> save({SebhaEntity? existing}) async {
    _isSaving = true;
    _error = null;
    _notify();

    final result = existing == null
        ? await _addSebha(name: _name, counter: _counter)
        : await _updateSebha(
            existing.copyWith(name: _name, counter: _counter),
          );

    _isSaving = false;
    switch (result) {
      case Ok(:final data):
        _notify();
        return data;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.save: $message');
        _notify();
        return null;
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
