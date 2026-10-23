import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/report/data/datasource/remote/report_remote_datasource.dart';
import 'package:azkark/features/refactor/report/data/model/report_model.dart';
import 'package:azkark/features/refactor/report/domain/entity/report_draft_entity.dart';
import 'package:azkark/features/refactor/report/domain/repository/report_repository.dart';

class ReportRepositoryImp implements ReportRepository {
  const ReportRepositoryImp(this._remoteDataSource, {required this.localeOf});

  final ReportRemoteDataSource _remoteDataSource;

  /// اللغة تُقرأ عند الإرسال لا عند التسجيل في GetIt: المستودع كائن مفرد
  /// طويل العمر، والمستخدم قد يبدّل لغة التطبيق بينهما.
  final String Function() localeOf;

  @override
  Future<Result<String>> submit(ReportDraftEntity draft) async {
    final environment = await ReportEnvironment.capture(locale: localeOf());
    return _remoteDataSource.submit(
      ReportModel(draft: draft, environment: environment),
    );
  }
}
