import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_entity.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_type.dart';
import 'package:azkark/features/refactor/feedback/domain/repository/feedback_repository.dart';

class GetFeedbackFormUseCase {
  const GetFeedbackFormUseCase(this._repository);

  final FeedbackRepository _repository;

  Future<Result<FeedbackFormEntity>> call({
    required FeedbackFormType type,
    String? title,
  }) =>
      _repository.getFeedbackForm(type: type, title: title);
}
