// شاشة البداية: خلفية المسجد وشعار التطبيق يظهر متحرّكًا في المنتصف.
//
// بُنيت كطبقة فوق شجرة التطبيق لا كصفحة مستقلة يُنتقل منها: المحتوى
// الحقيقي يُبنى خلفها منذ الإطار الأول (جلب الأقسام، الأذان، الخ)، فحين
// تنتهي الحركة يكون جاهزًا ولا ينتظره المستخدم مرتين.

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String kSplashBackgroundAsset =
    'assets/images/background/splashhome_bacground_image.png';
const String kSplashLogoAsset = 'assets/images/app/logo.png';

/// أخضر مطابق لأعلى صورة الخلفية — يملأ الشاشة قبل فك ترميز الصورة
/// فلا تومض بيضاء بين شاشة النظام وهذه.
const Color kSplashBackdrop = Color(0xFF1E3B29);

class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});

  /// محتوى التطبيق — يُبنى فورًا خلف الشاشة.
  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _underline;
  late final Animation<double> _exit;

  /// تُرفع الطبقة من الشجرة بعد التلاشي فلا تبقى تُرسم بلا داعٍ.
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.40, curve: Curves.easeOut),
    );

    // easeOutBack يعطي الشعار وثبة خفيفة عند استقراره
    _logoScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _underline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.75, curve: Curves.easeOutCubic),
    );

    _exit = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.84, 1, curve: Curves.easeIn),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _finished = true);
      }
    });

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_finished) return;
    precacheImage(const AssetImage(kSplashBackgroundAsset), context);
    precacheImage(const AssetImage(kSplashLogoAsset), context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => IgnorePointer(
              // الطبقة تتلاشى ككل في آخر الحركة كاشفةً التطبيق تحتها
              child: Opacity(
                opacity: 1 - _exit.value,
                child: _SplashLayer(
                  logoFade: _logoFade.value,
                  logoScale: _logoScale.value,
                  underline: _underline.value,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashLayer extends StatelessWidget {
  const _SplashLayer({
    required this.logoFade,
    required this.logoScale,
    required this.underline,
  });

  final double logoFade;
  final double logoScale;
  final double underline;

  @override
  Widget build(BuildContext context) {
    final Color gold = AppColor.rateColor.themeColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Material(
        color: kSplashBackdrop,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              kSplashBackgroundAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: logoFade,
                    child: Transform.scale(
                      scale: logoScale,
                      child: Container(
                        width: 148.r,
                        height: 148.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(34.r),
                          child: Image.asset(kSplashLogoAsset, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  // خط ذهبي ينمو تحت الشعار بدل مؤشّر تحميل دوّار
                  Container(
                    height: 2,
                    width: 96.w * underline,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
