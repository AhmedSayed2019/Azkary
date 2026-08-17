import 'package:equatable/equatable.dart';

/// A feedback form ready to be opened in a webview: the Google Form [url]
/// to load. The screen title is a presentation-layer concern (localized
/// per [FeedbackFormType](../entity/feedback_form_type.dart) or overridden
/// by the caller), so it isn't carried here.
class FeedbackFormEntity extends Equatable {
  const FeedbackFormEntity({required String url}) : _url = url;

  final String _url;

  String get url => _url;

  @override
  List<Object?> get props => [_url];
}
