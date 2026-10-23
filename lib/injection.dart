import 'package:azkark/core/res/theme_helper.dart';
import 'package:azkark/features/adhan/providers/adhan_dependency_provider.dart';
import 'package:azkark/features/adhan/providers/location_provider.dart';
import 'package:azkark/features/refactor/asmaallah/presentation/injection.dart' as asmaallah_refactor_di;
import 'package:azkark/features/refactor/azkar/presentation/injection.dart' as azkar_refactor_di;
import 'package:azkark/features/refactor/calender/presentation/injection.dart' as calender_refactor_di;
import 'package:azkark/features/refactor/categories/presentation/injection.dart' as categories_refactor_di;
import 'package:azkark/features/refactor/compass/presentation/injection.dart' as compass_refactor_di;
import 'package:azkark/features/refactor/report/presentation/injection.dart' as report_refactor_di;
import 'package:azkark/features/refactor/prayer/presentation/injection.dart' as prayer_refactor_di;
import 'package:azkark/features/refactor/sebha/presentation/injection.dart' as sebha_refactor_di;
import 'package:azkark/features/refactor/settings/presentation/injection.dart' as settings_refactor_di;
import 'package:azkark/providers.dart';
import 'package:azkark/providers/asmaallah_provider.dart';
import 'package:azkark/providers/categories_provider.dart';
import 'package:azkark/providers/favorites_provider.dart';
import 'package:azkark/providers/prayer_provider.dart';
import 'package:azkark/providers/sebha_provider.dart';
import 'package:azkark/providers/sections_provider.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:mq_prayer_time/mq_prayer_time.dart';
import 'package:mq_storage/mq_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> injection() async {

  final sharedPreferences = await SharedPreferences.getInstance();
  final storage = await PreferencesStorage.getInstance();
  final locationClient =  MqLocationClient(
    locationService:  const MqLocationServiceImpl(), locationStorage: MqLocationStorageImpl(storage),
  );
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => storage);

  getIt.registerLazySingleton(() => locationClient);


  getIt.registerLazySingleton(() => ThemeHelper(sharedPreferences: getIt()));


  getIt.registerLazySingleton(() => SectionsProvider());
  getIt.registerLazySingleton(() => SettingsProvider());
  getIt.registerLazySingleton(() => CategoriesProvider());
  getIt.registerLazySingleton(() => SebhaProvider());
  getIt.registerLazySingleton(() => FavoritesProvider());
  getIt.registerLazySingleton(() => PrayerProvider());
  getIt.registerLazySingleton(() => AsmaAllahProvider());

  //adan
  // getIt.registerLazySingleton(() => LocationInfo(latitude, longitude, address, mode));
  // getIt.registerLazySingleton(() => GlobalDependencyProvider.getInstance());
  getIt.registerLazySingleton(() => AdanLocationProvider.getInstance());
  getIt.registerLazySingleton(() => AdhanDependencyProvider());

  // features/refactor slices
  await sebha_refactor_di.initSebhaRefactorFeatures();
  await prayer_refactor_di.initPrayerRefactorFeatures();
  await settings_refactor_di.initSettingsRefactorFeatures();
  await asmaallah_refactor_di.initAsmaAllahRefactorFeatures();
  await categories_refactor_di.initCategoriesRefactorFeatures();
  // بعد categories و settings: نماذج عرض الأذكار تعتمد حالات استخدامهما
  await azkar_refactor_di.initAzkarRefactorFeatures();
  await calender_refactor_di.initCalenderRefactorFeatures();
  await report_refactor_di.initReportRefactorFeatures();
  await compass_refactor_di.initCompassRefactorFeatures();


  // getIt.registerLazySingleton(() => AdhanDependencyProvider());
  // getIt.registerLazySingleton(() => AdhanProvider(getIt(), locationInfo));
  // getIt.registerLazySingleton(() => AdhanNotificationProvider(getIt(), locationInfo));
  // // getIt.registerLazySingleton(() => GetDataProvider());







}
