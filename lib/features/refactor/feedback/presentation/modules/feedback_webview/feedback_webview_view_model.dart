import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_type.dart';
import 'package:azkark/features/refactor/feedback/domain/usecase/get_feedback_form_use_case.dart';
import 'package:flutter/foundation.dart';

class FeedbackWebviewViewModel extends ChangeNotifier {
  final _tag = 'FeedbackWebviewViewModel';

  FeedbackWebviewViewModel({required GetFeedbackFormUseCase getFeedbackForm})
      : _getFeedbackForm = getFeedbackForm;

  final GetFeedbackFormUseCase _getFeedbackForm;
  bool _disposed = false;

  ///Variables
  FeedbackFormType? _type;
  String? _title;
  String? _url;
  bool _isLoading = false;
  String? _error;

  ///Getters
  String? get url => _url;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ///Calling API functions

  /// Entry point — call once from the screen's `initState`. [type] selects
  /// which Google Form to resolve; [title] is only required for
  /// [FeedbackFormType.duaErrorReport] (the dua/azkar text being reported).
  Future<void> init({required FeedbackFormType type, String? title}) async {
    _type = type;
    _title = title;
    await load();
  }

  Future<void> load() async {
    final type = _type;
    if (type == null) return;

    _url = null;
    _isLoading = true;
    _error = null;
    _notify();

    final result = await _getFeedbackForm(type: type, title: _title);
    switch (result) {
      case Ok(:final data):
        _url = data.url;
      case Err(:final message):
        _error = message;
        debugPrint('$_tag.load: $message');
    }

    _isLoading = false;
    _notify();
  }

  Future<void> retry() => load();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
