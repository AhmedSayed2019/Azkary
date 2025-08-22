import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class QuranDatabaseHelper {
  Future<Database> get database async {
    // your existing db init
    throw UnimplementedError();
  }

  /// idsCsv: e.g. "5,2,10"
  Future<List<Map<String, dynamic>>> getData(String table, String idsCsv) async {
    final db = await database;

    if (idsCsv == '-1') {
      final res = await db.rawQuery('SELECT * FROM $table');
      if (kDebugMode) {
        print('getData $table done : ${res.length}');
      }
      return res;
    }

    final rawIds = idsCsv.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (rawIds.isEmpty) return [];

    // ORDER BY CASE to preserve the exact order you passed
    final caseParts = <String>[];
    for (var i = 0; i < rawIds.length; i++) {
      caseParts.add('WHEN ${rawIds[i]} THEN $i');
    }
    final orderCase = caseParts.join(' ');

    final sql = '''
      SELECT * FROM $table 
      WHERE id IN (${rawIds.join(',')})
      ORDER BY CASE id $orderCase END
    ''';

    final res = await db.rawQuery(sql);
    if (kDebugMode) {
      print('getData $table done : ${res.length}');
    }
    return res;
  }
}
