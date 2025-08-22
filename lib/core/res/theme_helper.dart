import 'package:azkark/core/res/theme/theme.dart';
import 'package:azkark/data/local/cache_consumer.dart';
import 'package:azkark/data/local/storage_keys.dart';
import 'package:flutter/material.dart';

class ThemeHelper extends ChangeNotifier {


  late ThemeData _themeData;
  late bool _isDarkMode;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;

  getCurrentTheme() {
    _isDarkMode = (CacheConsumer.get(StorageKeys.kIsDarkMode) ?? false) as bool;
    _themeData = _isDarkMode ? darkTheme : lightTheme;
    // notifyListeners();
  }

  Future<bool> changeTheme(String theme,{bool reload =false}) {
    _isDarkMode = isDarkMode;
    _themeData = isDarkMode ? darkTheme : lightTheme;
    if(reload)notifyListeners();

   return CacheConsumer.save(StorageKeys.kThemeMode, theme);
  }
}
