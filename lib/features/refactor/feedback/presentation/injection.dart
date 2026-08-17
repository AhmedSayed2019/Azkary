import 'package:azkark/features/refactor/feedback/data/datasource/local/feedback_form_local_datasource.dart';
import 'package:azkark/features/refactor/feedback/data/repository/feedback_repository_imp.dart';
import 'package:azkark/features/refactor/feedback/domain/repository/feedback_repository.dart';
import 'package:azkark/features/refactor/feedback/domain/usecase/get_feedback_form_use_case.dart';
import 'package:azkark/features/refactor/feedback/presentation/modules/feedback_webview/feedback_webview_view_model.dart';
import 'package:azkark/providers.dart';

/// Registers the feedback (bug/feature/adhan/dua-error report webview)
/// refactor slice with GetIt. Called once from `lib/injection.dart`
/// alongside the app's other init calls.
Future<void> initFeedbackRefactorFeatures() async {
  if (!getIt.isRegistered<FeedbackFormLocalDataSource>()) {
    getIt.registerLazySingleton<FeedbackFormLocalDataSource>(
      () => const FeedbackFormLocalDataSource(),
    );
  }

  if (!getIt.isRegistered<FeedbackRepository>()) {
    getIt.registerLazySingleton<FeedbackRepository>(
      () => FeedbackRepositoryImp(getIt<FeedbackFormLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetFeedbackFormUseCase>()) {
    getIt.registerLazySingleton<GetFeedbackFormUseCase>(
      () => GetFeedbackFormUseCase(getIt<FeedbackRepository>()),
    );
  }

  if (!getIt.isRegistered<FeedbackWebviewViewModel>()) {
    getIt.registerFactory<FeedbackWebviewViewModel>(
      () => FeedbackWebviewViewModel(
        getFeedbackForm: getIt<GetFeedbackFormUseCase>(),
      ),
    );
  }
}
