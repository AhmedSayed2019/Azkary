import 'package:azkark/features/QuranPages/views/screens/quran_pages/database_helper.dart';
import 'package:azkark/features/QuranPages/views/screens/quran_pages/quran_pages_ui.dart';
import 'package:flutter/material.dart';

class QuranPagesViewModel with ChangeNotifier {
  final QuranDatabaseHelper _db = QuranDatabaseHelper();
  final List<ZekrModel> _azkar = [];

  String get table => 'azkar';
  int get length => _azkar.length;
  ZekrModel getZekr(int i) => _azkar[i];
  List<ZekrModel> get items => List.unmodifiable(_azkar);

  Future<bool> initialAllAzkar(String azkarIndex) async {
    try {
      _azkar.clear();
      final rows = await _db.getData(table, azkarIndex);
      for (final r in rows) {
        _azkar.add(ZekrModel.fromMap(r));
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('Failed initialAllAzkar: $e\n$st');
      return false;
    }
  }

  /// Optional: re-sort by a custom list of IDs after loading
  void sortByIds(List<int> sortIds) {
    final order = {for (int i = 0; i < sortIds.length; i++) sortIds[i]: i};
    _azkar.sort((a, b) {
      final ia = order[a.id] ?? sortIds.length;
      final ib = order[b.id] ?? sortIds.length;
      return ia.compareTo(ib);
    });
    notifyListeners();
  }
}
