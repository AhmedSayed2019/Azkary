import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/report/domain/entity/report_draft_entity.dart';
import 'package:azkark/features/refactor/report/domain/repository/report_repository.dart';

class SubmitReportUseCase {
  const SubmitReportUseCase(this._repository);

  final ReportRepository _repository;

  Future<Result<String>> call(ReportDraftEntity draft) =>
      _repository.submit(draft);
}
