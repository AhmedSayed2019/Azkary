import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/report/data/model/report_model.dart';

/// يكتب البلاغات في مجموعة `reports` بمشروع Firebase الخاص بالتطبيق.
///
/// الكتابة مباشرة من العميل بلا مصادقة، فقواعد الأمان هي الحارس الوحيد:
/// يجب أن تسمح بـ `create` فقط على `reports` وتمنع `read`/`update`/`delete`،
/// وإلا صارت المجموعة مقروءة للجميع. انظر `firestore.rules`.
class ReportRemoteDataSource {
  const ReportRemoteDataSource();

  static const String collectionPath = 'reports';

  /// مهلة صريحة: بلا اتصال يبقى `add` معلّقًا في طابور Firestore دون أن
  /// يفشل ولا ينجح، فتظل الشاشة تدور إلى الأبد. المهلة تُحوّل ذلك إلى خطأ
  /// يراه المستخدم ويعيد المحاولة بعده.
  static const Duration _timeout = Duration(seconds: 20);

  Future<Result<String>> submit(ReportModel report) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collectionPath)
          .add(report.toFirestore())
          .timeout(_timeout);
      return Ok(doc.id);
    } on FirebaseException catch (e) {
      debugPrint('ReportRemoteDataSource.submit failed: ${e.code} ${e.message}');
      return Err(e.code);
    } catch (e) {
      debugPrint('ReportRemoteDataSource.submit failed: $e');
      return const Err('unknown');
    }
  }
}
