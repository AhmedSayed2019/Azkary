// تهيئة قاعدة المناطق الزمنية مرة واحدة في العزلة.
//
// AzanScheduler وReminderScheduler كان لكلٍّ منهما علَمه الخاص، فتُفكّ
// القاعدة كاملة (latest_all) مرتين على خيط الواجهة مع كل إقلاع. مستقبل
// واحد مشترك يجعل النداءات المتزامنة تنتظر التهيئة نفسها.

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

Future<void>? _timeZonesReady;

Future<void> ensureTimeZones() => _timeZonesReady ??= _init();

Future<void> _init() async {
  tzdata.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (_) {
    // نبقى على المنطقة الافتراضية — الأوقات محلية أصلًا فالفارق معدوم غالبًا
  }
}
