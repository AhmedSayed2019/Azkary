
import 'package:azkark/core/res/theme_helper.dart';
import 'package:azkark/features/home/get_data/get_data.dart';
import 'package:azkark/features/home/widgets/pray_time/provider/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mq_prayer_time/mq_prayer_time.dart';
import 'package:mq_storage/mq_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/asmaallah_provider.dart';
import 'providers/azkar_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/sebha_provider.dart';
import 'providers/sections_provider.dart';
import 'providers/settings_provider.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class GenerateMultiProvider extends StatefulWidget {
  final Widget child;

  @override
  State<GenerateMultiProvider> createState() => _GenerateMultiProviderState();

  const GenerateMultiProvider({super.key,
    required this.child,
  });
}

class _GenerateMultiProviderState extends State<GenerateMultiProvider> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        RepositoryProvider<PreferencesStorage>(create: (context) => getIt<PreferencesStorage>()),



        ChangeNotifierProvider<SectionsProvider>(create: (context) =>  getIt<SectionsProvider>()),
        ChangeNotifierProvider<SettingsProvider>(create: (context) =>  getIt<SettingsProvider>()),
        ChangeNotifierProvider<CategoriesProvider>(create: (context) =>  getIt<CategoriesProvider>()),
        ChangeNotifierProvider<SebhaProvider>(create: (context) =>  getIt<SebhaProvider>()),
        ChangeNotifierProvider<AzkarProvider>(create: (context) =>  getIt<AzkarProvider>()),
        ChangeNotifierProvider<FavoritesProvider>(create: (context) =>  getIt<FavoritesProvider>()),
        ChangeNotifierProvider<PrayerProvider>(create: (context) =>  getIt<PrayerProvider>()),
        ChangeNotifierProvider<AsmaAllahProvider>(create: (context) =>  getIt<AsmaAllahProvider>()),
        ChangeNotifierProvider<GetDataProvider>(create: (context) =>  getIt<GetDataProvider>()),

        ChangeNotifierProvider<ThemeHelper>(create: (context) => getIt<ThemeHelper>()),



        // RepositoryProvider<MqLocationClient>(
        //   create: (context) => getIt<MqLocationClient(
        //     locationService:  const MqLocationServiceImpl(),
        //     locationStorage: MqLocationStorageImpl(context.read<PreferencesStorage>()),
        //   ),
        // ),
        ChangeNotifierProvider<LocationProvider>(create: (context) => LocationProvider( getIt<MqLocationClient>() )),


      ],
      child: widget.child,
    );
  }
}
