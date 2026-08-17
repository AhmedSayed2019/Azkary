import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_entity.dart';

/// Data-layer DTO for a resolved feedback form URL.
class FeedbackFormModel {
  const FeedbackFormModel({required String url}) : _url = url;

  final String _url;

  String get url => _url;

  FeedbackFormEntity toEntity() => FeedbackFormEntity(url: _url);
}
