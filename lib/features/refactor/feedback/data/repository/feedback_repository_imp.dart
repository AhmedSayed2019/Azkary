import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/feedback/data/datasource/local/feedback_form_local_datasource.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_entity.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_type.dart';
import 'package:azkark/features/refactor/feedback/domain/repository/feedback_repository.dart';

class FeedbackRepositoryImp implements FeedbackRepository {
  const FeedbackRepositoryImp(this._localDataSource);

  final FeedbackFormLocalDataSource _localDataSource;

  @override
  Future<Result<FeedbackFormEntity>> getFeedbackForm({
    required FeedbackFormType type,
    String? title,
  }) async {
    final result =
        await _localDataSource.getFeedbackForm(type: type, title: title);
    return switch (result) {
      Ok(:final data) => Ok(data.toEntity()),
      Err(:final message) => Err(message),
    };
  }
}
