import '../models/zekr_model.dart';
import '../database/database_helper.dart';
import 'package:flutter/foundation.dart';

class AzkarProvider with ChangeNotifier {
  List<ZekrModel> _azkar = [];
  DatabaseHelper databaseHelper = new DatabaseHelper();

  String get table => 'azkar';

  int get length => _azkar.length;

  ZekrModel getZekr(int index) {
    return _azkar[index];
  }

  Future<bool> initialAllAzkar(String azkarIndex) async {
    try {
      _azkar.clear();
      List<Map<String, dynamic>> tempAzkar = await databaseHelper.getData(table, azkarIndex);
      // print('1111 tempAzkar.length : ${tempAzkar.length } -- ${azkarIndex}');

      for (int i = 0; i < tempAzkar.length; i++)
        _azkar.add(ZekrModel.fromMap(tempAzkar[i]));
      _sort(azkarIndex);
      // print('initialAllAzkar _azkar : ${_azkar.map((e) => e.id).toList()}');

      // print('initialAllAzkar length : ${_azkar.length}');
      notifyListeners();
      return true;
    } catch (e) {
      print('Faild initialAllAzkar');
      print('e : $e');
      return false;
    }
  }
  _sort(String azkarIndex){
    List<String> sortedIds = azkarIndex.trim().split(','); // Ensure ids are separated correctly
    // String placeholders = List.filled(sortedIds.length, '?').join(','); // Creates "?, ?, ?"
    // print('_sort placeholders: ${placeholders}');
    print('_sort sortedIds: ${sortedIds}');

    print('_sort _azkar before: ${_azkar.map((e) => e.id).toList()}');
    print('_sort _azkar before: ${_azkar.map((e) => e.id).toList()}');
    print('_sort _azkar 96: ${_azkar[22].id}');

    // Create a new sorted list based on idList order
    List<ZekrModel> sortedList = [];
    for (String id in sortedIds) {
      var zekr = _azkar.firstWhere((element) => element.id.toString() == id);
      // print('_sort id:$id zekr id:${zekr.id}');

      if(zekr!=null){
        sortedList.add(zekr);
      }
    }
      // for (var zekr in _azkar) {
      //   print('_sort id:$id zekr == id:${zekr.id}');
      //   if(zekr.id.toString() == id){
      //     sortedList.add(zekr);
      //     break;
      //   }
      // }
    // }
/*    try{
      var zekr = _azkar.firstWhere((element) => element.id.toString() == id);
      print('_sort id:$id zekr id:${zekr.id}');

      sortedList.add(zekr);
    }catch(e){
      print('_sort Error ${id} $e');
    }
    }*/

    // Replace the original list with sorted one
    _azkar = sortedList;
    
    // print('_sort _azkar after: ${_azkar.map((e) => e.id).toList()}');
  }
}
