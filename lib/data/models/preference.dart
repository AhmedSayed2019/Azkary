import 'package:azkark/providers.dart';
import 'package:mq_storage/mq_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

PreferencesStorage _preferences =getIt<PreferencesStorage>();

Future<void> initPreferences() async {
  // _preferences = await SharedPreferences.getInstance();
}

abstract class Preference<T extends Object?> {
  final String key;
  final T defaultValue;

  const Preference(this.key, this.defaultValue);

  T get value => _rawValue as T? ?? defaultValue;

  Object? get _rawValue;

  Future _setVal(T v);

  Future updateValue(T val) async {
    if (val == null) {
      await _preferences.delete(key: key);
    } else {
      await _setVal(val);
    }
  }
}

class IntPreference<R extends int?> extends Preference<R> {
  const IntPreference(String key, R defaultValue) : super(key, defaultValue);

  @override
  Object? get _rawValue => _preferences.readInt(key: key);

  @override
  Future _setVal(R v) => _preferences.writeInt(key: key,value:  v!);
}

class BoolPreference<R extends bool> extends Preference<R> {
  const BoolPreference(String key, R defaultValue) : super(key, defaultValue);

  @override
  Object? get _rawValue => _preferences.readBool(key: key);

  @override
  Future _setVal(R v) => _preferences.writeBool(key: key, value: v);
}

class DoublePreference<R extends double?> extends Preference<R> {
  const DoublePreference(String key, R defaultValue) : super(key, defaultValue);

  @override
  Object? get _rawValue => _preferences.readDouble(key: key);

  @override
  Future _setVal(R v) => _preferences.writeDouble(key: key,value:  v!);
}

class StringPreference<R extends String?> extends Preference<R> {
  const StringPreference(String key, R defaultValue) : super(key, defaultValue);

  @override
  Object? get _rawValue => _preferences.readString(key: key);

  @override
  Future _setVal(R v) => _preferences.writeString(key: key, value: v!);
}
