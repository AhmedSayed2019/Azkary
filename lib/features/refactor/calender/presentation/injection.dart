import 'package:azkark/features/refactor/calender/data/datasource/local/calendar_local_datasource.dart';
import 'package:azkark/features/refactor/calender/data/repository/calendar_repository_imp.dart';
import 'package:azkark/features/refactor/calender/domain/repository/calendar_repository.dart';
import 'package:azkark/features/refactor/calender/domain/usecase/convert_to_hijri_use_case.dart';
import 'package:azkark/features/refactor/calender/presentation/modules/calendar/calendar_view_model.dart';
import 'package:azkark/providers.dart';

/// Registers the calendar refactor slice with GetIt. Called once from
/// `lib/injection.dart` alongside the app's other init calls.
Future<void> initCalenderRefactorFeatures() async {
  if (!getIt.isRegistered<CalendarLocalDataSource>()) {
    getIt.registerLazySingleton<CalendarLocalDataSource>(
      () => CalendarLocalDataSource(),
    );
  }

  if (!getIt.isRegistered<CalendarRepository>()) {
    getIt.registerLazySingleton<CalendarRepository>(
      () => CalendarRepositoryImp(getIt<CalendarLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<ConvertToHijriUseCase>()) {
    getIt.registerLazySingleton<ConvertToHijriUseCase>(
      () => ConvertToHijriUseCase(getIt<CalendarRepository>()),
    );
  }

  if (!getIt.isRegistered<CalendarViewModel>()) {
    getIt.registerFactory<CalendarViewModel>(
      () => CalendarViewModel(convertToHijri: getIt<ConvertToHijriUseCase>()),
    );
  }
}
