import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/zekr_model.dart';

class AzkarProvider with ChangeNotifier {
  List<ZekrModel> _azkar = [];
  DatabaseHelper databaseHelper = new DatabaseHelper();

  String get table => 'azkar';

  int get length => _azkar.length;

  ZekrModel getZekr(int index) {
    return _azkar[index];
  }

  Future<bool> initialAllAzkar(String azkarIndex) async {
    print('initialAllAzkar azkarIndex: $azkarIndex');

        try {
      _azkar.clear();
      List<Map<String, dynamic>> tempAzkar = await databaseHelper.getData(table, azkarIndex);
      print('initialAllAzkar tempAzkar.length : ${tempAzkar.length}');

      for (int i = 0; i < tempAzkar.length; i++) {
        _azkar.add(ZekrModel.fromMap(tempAzkar[i]));
      }

      print('initialAllAzkar _azkar.length : ${_azkar.length}');
      notifyListeners();
      return true;
    } catch (e) {
      print('initialAllAzkar Faild initialAllAzkar');
      print('e : $e');
      return false;
    }
  }

  /// ✅ New function to sort by custom list of IDs
  void sortByIds(List<int> sortIds) {
    final Map<int, int> idOrder = {
      for (int i = 0; i < sortIds.length; i++) sortIds[i]: i
    };

    _azkar.sort((a, b) {
      int indexA = idOrder[a.id] ?? sortIds.length;
      int indexB = idOrder[b.id] ?? sortIds.length;
      return indexA.compareTo(indexB);
    });

    notifyListeners();
  }
}

