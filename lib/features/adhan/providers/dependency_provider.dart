import 'package:azkark/core/utils/helpers/extensions.dart';
import 'package:azkark/data/models/preference.dart';
import 'package:flutter/cupertino.dart';

abstract class DependencyProvider with ChangeNotifier {
  @inline
  void updateDataByRunning(Future Function() clbk) {
    clbk().then((value) => notifyListeners());
  }

  @inline
  void updateDataWithPreference<T extends Object>(Preference<T> pref, T value) {
    pref.updateValue(value).then((value) => notifyListeners());
  }
}
