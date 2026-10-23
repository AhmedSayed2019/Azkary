// شاشة الأذان الكاملة — تظهر فوق شاشة القفل حين يُطلق إشعار الأذان
// (fullScreenIntent) كما في تطبيقات الأذان الأخرى، بدل أن يبقى إشعارًا
// عاديًا في الدرج.
//
// المسار: الإشعار يُطلق MainActivity بالحمولة [AzanAlarm.payload]، فيسمح
// النشاط لنفسه بالظهور فوق القفل (MainActivity.kt)، ثم يفتح هذا الملف
// [AzanAlarmPage] إما من تفاصيل الإطلاق (التطبيق كان مغلقًا) أو من
// [AzanAlarm.onResponse] (التطبيق كان في الخلفية).
//
// الصوت يعزفه الإشعار نفسه، فإيقافه = إلغاء الإشعار.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AzanAlarm {
  AzanAlarm._();

  /// حمولة إشعار الأذان — يقرأها MainActivity.kt أيضًا، فلا تُغيَّر وحدها.
  static const String payload = 'azan';

  /// معرّف زر «إيقاف» في الإشعار.
  static const String stopActionId = 'azan_stop';

  /// مفتاح ملاح التطبيق — لفتح الشاشة من خارج شجرة الواجهة.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _showing = false;

  /// يُمرَّر لكل `initialize` للإضافة: آخر تهيئة هي التي تستلم الاستجابة،
  /// فلو مرّرته تهيئة واحدة فقط لمسحته التي بعدها.
  @pragma('vm:entry-point')
  static void onResponse(NotificationResponse response) {
    if (response.payload != payload) return;
    if (response.actionId == stopActionId) return; // الإلغاء تلقائي
    _open(response.id, response.notificationResponseType);
  }

  /// التطبيق فُتح من إشعار الأذان وهو مغلق — تُستدعى بعد أول إطار.
  static Future<void> handleLaunch() async {
    try {
      final details = await FlutterLocalNotificationsPlugin()
          .getNotificationAppLaunchDetails();
      final response = details?.notificationResponse;
      if (details?.didNotificationLaunchApp != true || response == null) {
        return;
      }
      onResponse(response);
    } catch (e) {
      debugPrint('AzanAlarm.handleLaunch failed: $e');
    }
  }

  static void _open(int? id, NotificationResponseType type) {
    final nav = navigatorKey.currentState;
    if (nav == null || _showing) return;
    _showing = true;
    nav
        .push(MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => AzanAlarmPage(notificationId: id),
        ))
        .whenComplete(() => _showing = false);
  }

  /// يوقف صوت الأذان بإلغاء إشعاره.
  static Future<void> stop(int? id) async {
    if (id == null) return;
    try {
      await FlutterLocalNotificationsPlugin().cancel(id);
    } catch (_) {}
  }
}

class AzanAlarmPage extends StatelessWidget {
  const AzanAlarmPage({super.key, this.notificationId});

  final int? notificationId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = TimeOfDay.now().format(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) AzanAlarm.stop(notificationId);
      },
      child: Scaffold(
        backgroundColor: scheme.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const Spacer(),
                Icon(Icons.mosque_rounded, size: 96, color: scheme.onPrimary),
                const SizedBox(height: 24),
                Text(
                  'azan_alarm_title'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: scheme.onPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  now,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: scheme.onPrimary),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.onPrimary,
                      foregroundColor: scheme.primary,
                    ),
                    icon: const Icon(Icons.stop_rounded),
                    label: Text('azan_stop'.tr()),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
