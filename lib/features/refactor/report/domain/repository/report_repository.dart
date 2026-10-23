import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/report/domain/entity/report_draft_entity.dart';

/// عقد إرسال البلاغ. تنفيذه `ReportRepositoryImp` في طبقة البيانات، وحالات
/// الاستخدام لا تعرف Firestore ولا غيرها.
abstract interface class ReportRepository {
  /// يُرجع معرّف المستند عند النجاح — يُعرض للمستخدم كرقم مرجعي ويسهّل
  /// إيجاد البلاغ في لوحة Firebase حين يتابعنا بشأنه.
  Future<Result<String>> submit(ReportDraftEntity draft);
}
