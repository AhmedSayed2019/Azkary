import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:azkark/features/refactor/report/domain/entity/report_draft_entity.dart';

/// بلاغ جاهز للكتابة في Firestore: ما كتبه المستخدم + بيئة التشغيل.
class ReportModel {
  const ReportModel({
    required this.draft,
    required this.environment,
  });

  final ReportDraftEntity draft;
  final ReportEnvironment environment;

  /// الطابع الزمني من الخادم لا من الجهاز: ساعة الهاتف قد تكون مضبوطة على
  /// أي شيء، وترتيب البلاغات بها يجعل اللوحة غير قابلة للقراءة.
  Map<String, Object?> toFirestore() => {
        'type': draft.type.wireName,
        'subject': draft.subject.trim(),
        'message': draft.message.trim(),
        'contact': draft.contact.trim(),
        if (draft.reference != null && draft.reference!.trim().isNotEmpty)
          'reference': draft.reference!.trim(),
        'app_version': environment.appVersion,
        'build_number': environment.buildNumber,
        'platform': environment.platform,
        'os_version': environment.osVersion,
        'locale': environment.locale,
        'created_at': FieldValue.serverTimestamp(),
      };
}

/// بيئة التشغيل المرافقة للبلاغ.
///
/// لا `device_info_plus` هنا: `Platform.operatingSystemVersion` يعطي على
/// أندرويد سلسلة تتضمّن الإصدار ومستوى الـ API ورقم البناء — وهو ما يلزم
/// لتتبّع خطأ يخص إصدارًا بعينه. طراز الجهاز وحده لا يستحق اعتمادًا جديدًا
/// بشيفرة أصلية على المنصتين.
class ReportEnvironment {
  const ReportEnvironment({
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    required this.locale,
  });

  final String appVersion;
  final String buildNumber;
  final String platform;
  final String osVersion;
  final String locale;

  /// لا ترمي أبدًا: فشل قراءة البيئة يجب ألا يمنع وصول البلاغ. الحقل
  /// المجهول يُكتب `unknown` بدل أن يسقط الإرسال كله.
  static Future<ReportEnvironment> capture({required String locale}) async {
    var version = 'unknown';
    var build = 'unknown';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
      build = info.buildNumber;
    } catch (e) {
      debugPrint('ReportEnvironment: package info unavailable: $e');
    }

    var platform = 'unknown';
    var osVersion = 'unknown';
    try {
      platform = Platform.operatingSystem;
      osVersion = Platform.operatingSystemVersion;
    } catch (e) {
      debugPrint('ReportEnvironment: platform unavailable: $e');
    }

    return ReportEnvironment(
      appVersion: version,
      buildNumber: build,
      platform: platform,
      osVersion: osVersion,
      locale: locale,
    );
  }
}
