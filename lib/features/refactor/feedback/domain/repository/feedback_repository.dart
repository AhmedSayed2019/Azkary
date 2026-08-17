import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_entity.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_type.dart';

/// Contract for resolving a [FeedbackFormType] to the [FeedbackFormEntity]
/// (the form URL) that should be opened in a webview. Implemented by
/// `FeedbackRepositoryImp` in the data layer; use cases depend on this
/// abstraction only.
abstract interface class FeedbackRepository {
  /// [title] is required (and must be non-empty) for
  /// [FeedbackFormType.duaErrorReport] — it is embedded in the prefilled
  /// form URL. It is ignored for every other form type.
  Future<Result<FeedbackFormEntity>> getFeedbackForm({
    required FeedbackFormType type,
    String? title,
  });
}
