// النافذة العائمة للأذكار: فقاعة تظهر فوق التطبيقات الأخرى — والتطبيق
// مغلق — بذكر قصير، ثم تختفي وحدها أو بلمسة.
//
// تعمل في عزلة (isolate) مستقلة تمامًا عن التطبيق: نقطة الدخول
// [overlayMain] في main.dart. لا تشارك مزوّدي الحالة ولا التنقّل، فكل ما
// تحتاجه يصل عبر [FlutterOverlayWindow.overlayListener].

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// أبعاد الفقاعة بالبكسل الفيزيائي — الإضافة تتعامل بالبكسل لا بالـ dp.
const int kZikrOverlayWidth = WindowSize.matchParent;
const int kZikrOverlayHeight = 320;

/// كم تبقى الفقاعة قبل أن تُغلق نفسها.
const Duration kZikrOverlayLifetime = Duration(seconds: 12);

class ZikrOverlay extends StatefulWidget {
  const ZikrOverlay({super.key});

  @override
  State<ZikrOverlay> createState() => _ZikrOverlayState();
}

class _ZikrOverlayState extends State<ZikrOverlay> {
  /// نص افتراضي حتى تصل الرسالة من العزلة المُرسِلة.
  String _text = 'اللَّهُمَّ صلِّ وسلِّم وبارك على سَيِّدِنا محمد';
  StreamSubscription<dynamic>? _sub;
  Timer? _autoClose;

  @override
  void initState() {
    super.initState();

    // الجدولة تُرسل نص الذكر عبر shareData بعد إظهار النافذة
    _sub = FlutterOverlayWindow.overlayListener.listen((event) {
      final text = event is String ? event : event?.toString();
      if (text != null && text.trim().isNotEmpty && mounted) {
        setState(() => _text = text);
      }
    });

    _autoClose = Timer(kZikrOverlayLifetime, _close);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _autoClose?.cancel();
    super.dispose();
  }

  Future<void> _close() async {
    _autoClose?.cancel();
    await FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp وليس Directionality وحدها: العزلة بلا شجرة تطبيق،
    // والنصوص تحتاج Directionality + Material لرسم الظل والنقر.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: _close,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D4429),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9C46A), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
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
