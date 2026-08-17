import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/feedback/data/model/feedback_form_model.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_type.dart';

/// Builds the Google Form URL for each [FeedbackFormType]. There is no
/// network/DB I/O involved — these are the same static Google Forms links
/// the legacy `lib/features/feedback/form_links.dart` used — but the result
/// is still wrapped in [Result] so failures (e.g. a missing required
/// [FeedbackFormType.duaErrorReport] title) flow through the same
/// repository/use-case/VM pipeline as every other refactor slice instead of
/// throwing.
class FeedbackFormLocalDataSource {
  const FeedbackFormLocalDataSource();

  static const String _bugReportUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSc1Ok8YRqF2LEoWyM5Mm9rAmtOdyKL4ECQFPIcYizQjbkQ7Sw/viewform?usp=sf_link';

  static const String _featureRequestUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSfXXydvTK8vKEyWWMbhSKKNJ_ysWJ2mNYG2bcH28E95TJI0SQ/viewform?usp=sf_link';

  static const String _adhanReportUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSfG9U9jUeuHNwIEM4xNxWsLE66wnxnAu8kDYIvPEfL9L5vPvA/viewform?usp=sf_link';

  static const String _duaErrorReportBaseUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSfBJKNXf-OLCpi5_G6ykpHqEuRmBGQy-j4IYY0etZOb-44FSA/viewform';

  Future<Result<FeedbackFormModel>> getFeedbackForm({
    required FeedbackFormType type,
    String? title,
  }) async {
    switch (type) {
      case FeedbackFormType.bugReport:
        return const Ok(FeedbackFormModel(url: _bugReportUrl));
      case FeedbackFormType.featureRequest:
        return const Ok(FeedbackFormModel(url: _featureRequestUrl));
      case FeedbackFormType.adhanReport:
        return const Ok(FeedbackFormModel(url: _adhanReportUrl));
      case FeedbackFormType.duaErrorReport:
        final trimmed = title?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return const Err(
            'A title is required to report a dua/azkar error.',
          );
        }
        // Bug fix vs. the legacy `getDuaErrorReportForm`: the title is now
        // percent-encoded before being embedded in the query string, so
        // titles containing spaces, `&`, `#`, Arabic text, etc. no longer
        // produce a malformed/truncated form URL.
        final uri = Uri.parse(_duaErrorReportBaseUrl).replace(
          queryParameters: {
            'usp': 'pp_url',
            'entry.43825494': trimmed,
          },
        );
        return Ok(FeedbackFormModel(url: uri.toString()));
    }
  }
}
