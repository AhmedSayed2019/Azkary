
import 'package:azkark/core/res/theme_helper.dart';
import 'package:azkark/features/home/get_data/get_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/asmaallah_provider.dart';
import 'providers/azkar_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/sebha_provider.dart';
import 'providers/sections_provider.dart';
import 'providers/settings_provider.dart';


class GenerateMultiProvider extends StatefulWidget {
  final Widget child;

  const GenerateMultiProvider({Key? key, required this.child})
      : super(key: key);

  @override
  State<GenerateMultiProvider> createState() => _GenerateMultiProviderState();
}

class _GenerateMultiProviderState extends State<GenerateMultiProvider> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SectionsProvider>(create: (context) => SectionsProvider()),
        ChangeNotifierProvider<SettingsProvider>(create: (context) => SettingsProvider()),
        ChangeNotifierProvider<CategoriesProvider>(create: (context) => CategoriesProvider()),
        ChangeNotifierProvider<SebhaProvider>(create: (context) => SebhaProvider()),
        ChangeNotifierProvider<AzkarProvider>(create: (context) => AzkarProvider()),
        ChangeNotifierProvider<FavoritesProvider>(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider<PrayerProvider>(create: (context) => PrayerProvider()),
        ChangeNotifierProvider<AsmaAllahProvider>(create: (context) => AsmaAllahProvider()),
        ChangeNotifierProvider<GetDataProvider>(create: (context) => GetDataProvider()),
        // ChangeNotifierProvider<DownloadHelper>(create: (context) => DownloadHelper()),

        ChangeNotifierProvider<ThemeHelper>(create: (context) => ThemeHelper()),
      ],
      child: widget.child,
    );
  }
}
