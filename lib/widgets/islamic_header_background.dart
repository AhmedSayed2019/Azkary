// خلفية الهيدر بنسيج SVG مبلّط مسبقاً.
// ملاحظة: flutter_svg لا يدعم <pattern>، لذلك الملف يحتوي على
// النجوم كمسارات صريحة ولا يعتمد على التبليط داخل SVG.

import 'dart:ui' as ui;

import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String kIslamicHeaderPatternAsset =
    'assets/images/background/home_header_bacground.svg';

class IslamicHeaderBackground extends StatelessWidget {
  const IslamicHeaderBackground({
    super.key,
    required this.child,
    this.height,
    this.color,
    this.patternColor,
    this.patternOpacity = 0.10,
    this.borderRadius,
    this.asset = kIslamicHeaderPatternAsset,
  });

  final Widget child;

  /// ارتفاع اختياري لأرضية النسيج — عند تركه فارغًا يتمدد مع الأب.
  final double? height;

  /// لون أرضية الهيدر — الافتراضي أخضر الهوية.
  final Color? color;

  /// لون النقش — الافتراضي الذهبي.
  final Color? patternColor;
  final double patternOpacity;
  final BorderRadiusGeometry? borderRadius;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        color: color ?? AppColor.primaryColor.themeColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: patternOpacity,
                    child: SvgPicture.asset(
                      asset,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      colorFilter: ColorFilter.mode(
                        patternColor ?? AppColor.rateColor.themeColor,
                        BlendMode.srcIn,
                      ),
                      // يمنع ومضة الفراغ أثناء أول فك ترميز للملف
                      placeholderBuilder: (_) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// نادِ هذه مرة واحدة في main() قبل runApp لتفادي ومضة الخلفية
/// عند أول بناء للهيدر.
Future<void> precacheIslamicPattern() async {
  const loader = SvgAssetLoader(kIslamicHeaderPatternAsset);
  await svg.cache.putIfAbsent(
    loader.cacheKey(null),
    () => loader.loadBytes(null),
  );
}

const String kHomeHeaderImageAsset =
    'assets/images/background/home_header_image.png';

/// ارتفاع الشريط المثبت في الرئيسية — يشاركه [HomeHeaderImage] ليحسب
/// إزاحة الشريحة، فأي تغيير هنا يجب أن يرافقه تغيير `toolbarHeight`.
const double kHomeToolbarHeight = 72;

/// ارتفاع صورة هيدر الرئيسية مقيسًا من أعلى الشاشة، شريط الحالة ضمنه.
///
/// كسر من ارتفاع الشاشة عمدًا، لا مجموع (شريط الحالة + الشريط + ارتفاع
/// قسم الأذان): ذلك المجموع كان يقصُر عن الهيدر الفعلي فيظهر شريط أخضر
/// مصمت أسفل الصورة. سببان — `MediaQuery.paddingOf` تُصفَّر داخل
/// Scaffold فيضيع ارتفاع شريط الحالة، و`.h` تعتمد على MediaQuery
/// مُلتقطة مرة واحدة عند إقلاع التطبيق فتعطي قيمًا أصغر من المتوقّع.
///
/// الزيادة عن حاجة الهيدر غير ضارّة — أسفل الصورة يُقصّ فحسب — بينما
/// النقص يكشف اللون المصمت خلفها. المهم أن ترجع المنطقتان القيمة نفسها.
double homeHeaderImageHeight(BuildContext context) =>
    MediaQuery.sizeOf(context).height * 0.42;

/// خلفية هيدر الرئيسية بصورة المسجد.
///
/// الشريط المثبت وقسم الأذان منطقتان منفصلتان في شجرة الـ slivers، فلا
/// يمكن أن تشتركا في عنصر واحد. الحيلة أن ترسم كل منطقة *الصورة كاملة*
/// بالارتفاع نفسه ([homeHeaderImageHeight]) ثم تزيحها لأعلى بمقدار بعد
/// المنطقة عن رأس الشاشة ([topOffset])، فتقتطع كل واحدة شريحتها وتبدوان
/// صورة واحدة متصلة. القص يتكفّل به الـ Stack.
class HomeHeaderImage extends StatelessWidget {
  const HomeHeaderImage({
    super.key,
    required this.child,
    this.topOffset = 0,
    this.borderRadius,
    this.asset = kHomeHeaderImageAsset,
    this.blurSigma = 2,
    this.fillRegion = false,
  });

  final Widget child;

  /// بُعد أعلى هذه المنطقة عن أعلى الشاشة — يحدّد أي شريحة تظهر.
  final double topOffset;

  final BorderRadiusGeometry? borderRadius;
  final String asset;

  /// شدّة ضبابية الخلفية — ترفع وضوح النص فوق تفاصيل المسجد.
  /// صفر يعطّلها.
  final double blurSigma;

  /// هيدر قائم بذاته لا يتقاسم الصورة مع جار (شاشة المواقيت مثلًا):
  /// تملأ الصورة المنطقة نفسها بـ cover، فيستحيل أن تقصُر عنها مهما
  /// كان ارتفاعها. عندها يُتجاهل [topOffset].
  final bool fillRegion;

  /// clamp يمدّ حواف الصورة بدل أن يمزجها بالشفاف، وإلا ظهر إطار
  /// باهت حول الهيدر بعرض قدر الضبابية.
  Widget _blurred(Widget image) {
    if (blurSigma <= 0) return image;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        tileMode: ui.TileMode.clamp,
      ),
      child: image,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        // يملأ ما قد يفيض عن الصورة أسفلها بدل أن يظهر فراغ
        color: AppColor.primaryColor.themeColor,
        child: Stack(
          children: [
            Positioned(
              top: fillRegion ? 0 : -topOffset,
              left: 0,
              right: 0,
              bottom: fillRegion ? 0 : null,
              height: fillRegion ? null : homeHeaderImageHeight(context),
              child: IgnorePointer(
                child: RepaintBoundary(
                  // بلا Column: هي تمنح الصورة ارتفاعًا غير محدود فيسقط
                  // BoxFit.cover وتأخذ الصورة نسبتها الأصلية (عرض الشاشة
                  // ÷ ٢٫١٥٧ ≈ ١٨٢dp) فتقصُر عن الصندوق ويظهر الأخضر تحتها.
                  child: _blurred(
                    Image.asset(
                      asset,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// نادِها مرة عند أول بناء لتفادي ومضة الفراغ قبل فك ترميز الصورة.
Future<void> precacheHomeHeaderImage(BuildContext context) =>
    precacheImage(const AssetImage(kHomeHeaderImageAsset), context);
