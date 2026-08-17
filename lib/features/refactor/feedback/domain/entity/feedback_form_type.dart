/// Which Google Form the feedback webview should open.
///
/// [duaErrorReport] additionally requires a non-empty `title` (the dua/text
/// being reported) — see [FeedbackRepository.getFeedbackForm].
enum FeedbackFormType {
  bugReport,
  featureRequest,
  adhanReport,
  duaErrorReport,
}
