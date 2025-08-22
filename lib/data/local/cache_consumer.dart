import 'package:shared_preferences/shared_preferences.dart';

class CacheConsumer {
  static late final SharedPreferences _sharedPreferences;

  static final CacheConsumer _singleton = CacheConsumer._internal();



  static init()async{
     _sharedPreferences = await SharedPreferences.getInstance();
     CacheConsumer();
  }

  factory CacheConsumer() {
    // _sharedPreferences = await SharedPreferences.getInstance();
    return _singleton;
  }

  CacheConsumer._internal();
  /// shared prefs

  static dynamic get(String key) => _sharedPreferences.get(key);

  static Future<bool> save(String key, var value) async {
    if (value is String) {
      return await _sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await _sharedPreferences.setInt(key, value);
    } else if (value is bool) {
      return await _sharedPreferences.setBool(key, value);
    } else if (value is double) {
      return await _sharedPreferences.setDouble(key, value);
    } else {
      return await _sharedPreferences.setStringList(key, value);
    }
  }

  /// Secure storage

  Future<bool> delete(String key) async => await _sharedPreferences.remove(key);


}
