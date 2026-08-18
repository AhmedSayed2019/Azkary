// خلفية الهيدر بنسيج SVG مبلّط مسبقاً.
// ملاحظة: flutter_svg لا يدعم <pattern>، لذلك الملف يحتوي على
// النجوم كمسارات صريحة ولا يعتمد على التبليط داخل SVG.

import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String kIslamicHeaderPatternAsset = 'assets/images/background/home_header_bacground.svg';

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
