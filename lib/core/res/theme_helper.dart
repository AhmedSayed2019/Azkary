import 'package:azkark/core/res/theme/theme.dart';
import 'package:azkark/data/local/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeHelper extends ChangeNotifier {
  final SharedPreferences _sharedPreferences;

  ThemeHelper({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  late ThemeData _themeData;
  late bool _isDarkMode;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;

  getCurrentTheme() {
    _isDarkMode = (_sharedPreferences.get(StorageKeys.kIsDarkMode) ?? false) as bool;
    _themeData = _isDarkMode ? darkTheme : lightTheme;
    // notifyListeners();
  }

  void changeTheme(isDarkMode,{bool reload =false}) {
    print('changeTheme isDarkMode==$isDarkMode');
    _isDarkMode = isDarkMode;
    _themeData = isDarkMode ? darkTheme : lightTheme;
    if(reload)notifyListeners();

    _sharedPreferences.setBool(StorageKeys.kIsDarkMode, themeData == darkTheme);
  }
}
