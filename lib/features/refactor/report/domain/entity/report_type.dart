/// ما الذي يُبلّغ عنه المستخدم.
///
/// خلَف `FeedbackFormType`: النوع كان يختار *رابط نموذج Google* يُفتح في
/// WebView، وصار يختار حقل `type` في مستند Firestore — فالقيمة المخزّنة
/// نصّ ثابت لا فهرس، حتى تظل بلاغات النسخ القديمة قابلة للتصفية بعد أي
/// إعادة ترتيب للثوابت هنا.
enum ReportType {
  bug('bug', 'report_type_bug'),
  feature('feature', 'report_type_feature'),
  adhan('adhan', 'report_type_adhan'),
  content('content', 'report_type_content');

  const ReportType(this.wireName, this.labelKey);

  /// القيمة كما تُكتب في Firestore.
  final String wireName;

  /// مفتاح الترجمة المعروض في مُحدِّد النوع.
  final String labelKey;

  static ReportType fromWire(String? raw) => ReportType.values.firstWhere(
        (t) => t.wireName == raw,
        orElse: () => ReportType.bug,
      );
}
