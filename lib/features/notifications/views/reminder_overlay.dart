// النافذة العائمة للتذكيرات: حبّة صغيرة تنزلق من أعلى الشاشة فوق التطبيقات
// الأخرى — والتطبيق مغلق — بذكر أو حديث أو آية، ثم تنزلق خارجةً وحدها بعد
// ثوانٍ أو بلمسة.
//
// هيئتها «حبّة» (pill) تتقولب على نصّها لا شريطًا يملأ العرض: التذكير
// مقاطعةٌ لما بيد المستخدم، وأقلّ ما يحجبه من الشاشة أفضل — وهي هيئة
// تطبيق «أذكار» المرجعي الذي طُلبت محاكاته.
//
// تعمل في عزلة (isolate) مستقلة تمامًا عن التطبيق: نقطة الدخول
// [overlayMain] في main.dart. لا تشارك مزوّدي الحالة ولا التنقّل، فكل ما
// تحتاجه يصل عبر [FlutterOverlayWindow.overlayListener].
//
// الحمولة الواصلة سلسلة JSON فيها `title` و`body` — انظر
// `OverlayScheduler.encodePayload`. صارت الترويسة جزءًا منها حين توسّعت
// النافذة من الأذكار وحدها إلى الأنواع الثلاثة: نافذة بترويسة «ذكر» فوق نص
// حديث كانت ستكذب على المستخدم. تُرسم الآن شارةً صغيرة في صدر السطر لا
// سطرًا مستقلًا فوقه، حتى تبقى الحبّة سطرًا واحدًا في الغالب. النص الخام
// (بلا JSON) ما زال مقبولًا حتى لا تنكسر نافذةٌ أطلقها منبّه سلّحته نسخة
// سابقة.

import 'dart:async';
import 'dart:convert';

import 'package:azkark/features/notifications/logic/overlay_palette.dart';
import 'package:azkark/features/notifications/views/reminder_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// كم تبقى الحبّة ظاهرة قبل أن تخرج وحدها — لا تشمل زمن الانزلاق.
const Duration kZikrOverlayLifetime = Duration(seconds: 3);

/// زمن انزلاق الحبّة دخولًا وخروجًا.
const Duration kZikrOverlaySlideDuration = Duration(milliseconds: 320);

class ReminderOverlay extends StatefulWidget {
  const ReminderOverlay({super.key});

  @override
  State<ReminderOverlay> createState() => _ReminderOverlayState();
}

class _ReminderOverlayState extends State<ReminderOverlay>
    with SingleTickerProviderStateMixin {
  /// نص افتراضي حتى تصل الرسالة من العزلة المُرسِلة.
  String _text = 'اللَّهُمَّ صلِّ وسلِّم وبارك على سَيِّدِنا محمد';

  /// ترويسة النوع (ذكر / حديث / آية). تُخفى ما لم تصل.
  String _title = '';

  /// لون الحدّ والنصّ — يصل مع الحمولة، وحتى وصولها الافتراضي.
  OverlayPillColor _color = kDefaultOverlayPillColor;
  StreamSubscription<dynamic>? _sub;
  Timer? _autoClose;
  late final AnimationController _slide;

  /// حارس: النقر أثناء الخروج يجب ألا يبدأ إغلاقًا ثانيًا.
  bool _closing = false;

  @override
  void initState() {
    super.initState();

    _slide = AnimationController(
      vsync: this,
      duration: kZikrOverlaySlideDuration,
    );

    // الجدولة تُرسل الحمولة عبر shareData بعد إظهار النافذة
    _sub = FlutterOverlayWindow.overlayListener.listen(_onPayload);

    _slide.forward();
    _autoClose = Timer(kZikrOverlayLifetime, _close);
  }

  /// يقبل حمولة JSON، ويتراجع إلى النص الخام حين لا تكون كذلك.
  void _onPayload(dynamic event) {
    final raw = event is String ? event : event?.toString();
    if (raw == null || raw.trim().isEmpty || !mounted) return;

    String body = raw;
    String title = '';
    var color = kDefaultOverlayPillColor;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        body = (decoded['body'] ?? '').toString();
        title = (decoded['title'] ?? '').toString();
        color = OverlayPillColor.fromValue(decoded['color']);
      }
    } on FormatException {
      // نص خام من نسخة سابقة — يُعرض كما هو بلا ترويسة
    }
    if (body.trim().isEmpty) return;

    setState(() {
      _text = body;
      _title = title;
      _color = color;
    });

    // النصّ يصل بعد الإظهار بلحظة، والعمر ثلاث ثوانٍ فقط: لو بقي العدّ
    // بادئًا من initState لأكل زمنُ الوصول جزءًا منها. نعيد ضبطه ليكون
    // العمر عمرَ النص المقروء لا عمر النافذة الفارغة.
    _autoClose?.cancel();
    _autoClose = Timer(kZikrOverlayLifetime, _close);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _autoClose?.cancel();
    _slide.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _autoClose?.cancel();
    // الخروج إلى أعلى أولًا، ثم إغلاق النافذة فعليًا
    await _slide.reverse();
    await FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _slide,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // MaterialApp وليس Directionality وحدها: العزلة بلا شجرة تطبيق،
    // والنصوص تحتاج Directionality + Material لرسم الظل والنقر.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.transparent,
          child: Align(
            // Align يمرّر قيودًا مرتخية، فتتقولب الحبّة على نصّها بدل أن
            // تمتدّ عرض الشاشة — وهي كل الفكرة.
            alignment: Alignment.topCenter,
            child: SlideTransition(
              // من خارج الحافة العليا إلى موضعها، والعكس عند الإخفاء.
              // بلا textDirection حتى لا تُقلب الإزاحة مع الـ RTL.
              position: Tween<Offset>(
                begin: const Offset(0, -1.6),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: curved,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: ReminderPill(
                    text: _text,
                    title: _title,
                    color: _color,
                    // اللمس يُخفيها فورًا — لا انتظار للثواني الثلاث
                    onTap: _close,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
