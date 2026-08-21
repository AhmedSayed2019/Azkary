// واجهة موحّدة لأذونات التنبيهات (الأذان + تذكيرات الأذكار).
//
// كانت الأذونات موزّعة على أماكن متفرقة: `permission.dart` يطلب إذن
// الإشعارات فقط، و«المنبهات الدقيقة» داخل [AzanScheduler]، وإذن العرض فوق
// التطبيقات داخل شاشة الإشعارات، ولا شيء يتعامل مع تحسين البطارية — وهو
// السبب الأشهر لتوقف التنبيهات على أجهزة Xiaomi/Huawei/Samsung بعد إغلاق
// التطبيق. هذا الملف يجمعها في مكان واحد ليعرضها المستخدم ويعالجها.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionKind {
  /// POST_NOTIFICATIONS على أندرويد ١٣+، وتفويض UNUserNotificationCenter على iOS.
  /// بدونه لا يظهر أي إشعار مهما صحّت الجدولة.
  notifications,

  /// SCHEDULE_EXACT_ALARM — أندرويد ١٢+ يرفضه افتراضيًا مع targetSdk 31+،
  /// وبدونه تتأخر التنبيهات داخل نافذة تقارب الساعة.
  exactAlarm,

  /// استثناء من تحسين البطارية — يمنع النظام من تأجيل/إسقاط المنبهات
  /// أثناء وضع السكون العميق.
  batteryOptimization,

  /// الموقع — مطلوب لحساب مواقيت الصلاة (والأذان مبني عليها).
  location,
}

/// حالة إذن واحد كما تُعرض في الشاشة.
class AppPermissionState {
  const AppPermissionState({
    required this.kind,
    required this.granted,
    required this.applicable,
  });

  final AppPermissionKind kind;
  final bool granted;

  /// هل الإذن ذو معنى على هذه المنصة/الإصدار أصلًا؟ غير المنطبق لا يُعرض.
  final bool applicable;

  bool get needsAttention => applicable && !granted;
}

class AppPermissions {
  AppPermissions._();

  static AndroidFlutterLocalNotificationsPlugin? get _android {
    if (!Platform.isAndroid) return null;
    return FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
  }

  static IOSFlutterLocalNotificationsPlugin? get _ios {
    if (!Platform.isIOS) return null;
    return FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
  }

  // ---------------------------------------------------------------- الاستعلام

  static bool isApplicable(AppPermissionKind kind) {
    switch (kind) {
      case AppPermissionKind.notifications:
      case AppPermissionKind.location:
        return Platform.isAndroid || Platform.isIOS;
      case AppPermissionKind.exactAlarm:
      case AppPermissionKind.batteryOptimization:
        // كلها مفاهيم أندرويد بحتة — iOS يدير الجدولة والطاقة بنفسه
        return Platform.isAndroid;
    }
  }

  static Future<bool> isGranted(AppPermissionKind kind) async {
    if (!isApplicable(kind)) return true;
    try {
      switch (kind) {
        case AppPermissionKind.notifications:
          if (Platform.isIOS) {
            // iOS لا يكشف الحالة عبر permission_handler بدقة قبل الطلب،
            // لكن Permission.notification يقرأ إعدادات الإشعارات الفعلية
            return await Permission.notification.isGranted;
          }
          return await _android?.areNotificationsEnabled() ??
              await Permission.notification.isGranted;

        case AppPermissionKind.exactAlarm:
          return await _android?.canScheduleExactNotifications() ?? true;

        case AppPermissionKind.batteryOptimization:
          return await Permission.ignoreBatteryOptimizations.isGranted;

        case AppPermissionKind.location:
          return await Permission.locationWhenInUse.isGranted;
      }
    } catch (e) {
      debugPrint('AppPermissions.isGranted($kind) failed: $e');
      return false;
    }
  }

  /// لقطة كاملة لكل الأذونات — تُستدعى عند فتح الشاشة وعند العودة إليها.
  static Future<List<AppPermissionState>> audit() async {
    final states = <AppPermissionState>[];
    for (final kind in AppPermissionKind.values) {
      final applicable = isApplicable(kind);
      states.add(AppPermissionState(
        kind: kind,
        applicable: applicable,
        granted: applicable ? await isGranted(kind) : true,
      ));
    }
    return states;
  }

  // ----------------------------------------------------------------- الطلب

  /// يطلب الإذن ويعيد حالته النهائية. الأذونات التي لا تُمنح عبر حوار
  /// (المنبهات الدقيقة، البطارية) تفتح شاشة الإعدادات المناسبة، فيلزم
  /// إعادة الفحص عند عودة التطبيق للمقدمة.
  static Future<bool> request(AppPermissionKind kind) async {
    if (!isApplicable(kind)) return true;

    // الفحص قبل الطلب ليس تحسينًا للأداء بل شرط صحة: أذونات «المنبهات
    // الدقيقة» و«البطارية» تفتح شاشة إعدادات خارجية عند كل نداء حتى لو كان
    // الإذن ممنوحًا، فتقذف المستخدم خارج التطبيق بلا سبب.
    if (await isGranted(kind)) return true;

    try {
      switch (kind) {
        case AppPermissionKind.notifications:
          if (Platform.isIOS) {
            await _ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
          } else {
            await _android?.requestNotificationsPermission();
          }
          final status = await Permission.notification.request();
          if (status.isPermanentlyDenied) await openAppSettings();
          return await isGranted(kind);

        case AppPermissionKind.exactAlarm:
          await _android?.requestExactAlarmsPermission();
          return await isGranted(kind);

        case AppPermissionKind.batteryOptimization:
          await Permission.ignoreBatteryOptimizations.request();
          return await isGranted(kind);

        case AppPermissionKind.location:
          final status = await Permission.locationWhenInUse.request();
          if (status.isPermanentlyDenied) await openAppSettings();
          return status.isGranted;
      }
    } catch (e) {
      debugPrint('AppPermissions.request($kind) failed: $e');
      return false;
    }
  }

  /// يضمن إذن الإشعارات قبل تفعيل أي تذكير — الحارس الوحيد الذي بدونه
  /// تُجدول الإشعارات بنجاح ولا يراها المستخدم أبدًا.
  static Future<bool> ensureNotifications() async {
    if (await isGranted(AppPermissionKind.notifications)) return true;
    return request(AppPermissionKind.notifications);
  }
}
