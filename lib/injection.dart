import 'package:azkark/core/res/theme_helper.dart';
import 'package:azkark/features/home/get_data/get_data.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/providers/asmaallah_provider.dart';
import 'package:azkark/providers/azkar_provider.dart';
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
  getIt.registerLazySingleton(() => AzkarProvider());
  getIt.registerLazySingleton(() => FavoritesProvider());
  getIt.registerLazySingleton(() => PrayerProvider());
  getIt.registerLazySingleton(() => AsmaAllahProvider());
  getIt.registerLazySingleton(() => GetDataProvider());







}
