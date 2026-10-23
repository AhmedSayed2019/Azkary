import 'package:easy_localization/easy_localization.dart';

import 'package:azkark/features/refactor/report/data/datasource/remote/report_remote_datasource.dart';
import 'package:azkark/features/refactor/report/data/repository/report_repository_imp.dart';
import 'package:azkark/features/refactor/report/domain/repository/report_repository.dart';
import 'package:azkark/features/refactor/report/domain/usecase/submit_report_use_case.dart';
import 'package:azkark/features/refactor/report/presentation/modules/report_form/report_form_view_model.dart';
import 'package:azkark/providers.dart';

/// يسجّل شريحة البلاغات (نموذج داخل التطبيق يكتب في Firestore) مع GetIt.
/// تُستدعى مرة واحدة من `lib/injection.dart`. حلّت محل
/// `initFeedbackRefactorFeatures` بعد إزالة نماذج Google Forms.
Future<void> initReportRefactorFeatures() async {
  if (!getIt.isRegistered<ReportRemoteDataSource>()) {
    getIt.registerLazySingleton<ReportRemoteDataSource>(
      () => const ReportRemoteDataSource(),
    );
  }

  if (!getIt.isRegistered<ReportRepository>()) {
    getIt.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImp(
        getIt<ReportRemoteDataSource>(),
        // `Intl.getCurrentLocale()` لا `context.locale`: التسجيل يحدث قبل
        // بناء أي شجرة واجهة، ولا سياق متاحًا هنا. EasyLocalization تضبط
        // لغة Intl عند كل تبديل، فالقيمة تبقى مواكِبة.
        localeOf: () => Intl.getCurrentLocale(),
      ),
    );
  }

  if (!getIt.isRegistered<SubmitReportUseCase>()) {
    getIt.registerLazySingleton<SubmitReportUseCase>(
      () => SubmitReportUseCase(getIt<ReportRepository>()),
    );
  }

  if (!getIt.isRegistered<ReportFormViewModel>()) {
    getIt.registerFactory<ReportFormViewModel>(
      () => ReportFormViewModel(submitReport: getIt<SubmitReportUseCase>()),
    );
  }
}
