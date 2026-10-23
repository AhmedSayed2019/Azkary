import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveService {
  // static const Size _designSize = Size(375, 812);
  static const Size _designSize = Size(360, 716);
  static const bool _splitScreenMode = false;
  // كانت `static final` تُقرأ مرة واحدة عند أول استخدام لـ .sp/.h/.w. إن
  // حدث ذلك قبل أن يستلم المحرّك أبعاد النافذة (حجم صفر) تجمّدت كل
  // المقاييس على صفر طوال الجلسة: نصوص بحجم صفر وارتفاعات منهارة. الآن
  // تُقرأ من النافذة الحية وتُخزَّن ما دام حجمها لم يتغيّر.
  static MediaQueryData? _cached;
  static Size? _cachedPhysicalSize;

  static MediaQueryData get _mediaQueryData {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final view = dispatcher.implicitView ?? dispatcher.views.first;
    if (_cached == null || _cachedPhysicalSize != view.physicalSize) {
      _cached = MediaQueryData.fromView(view);
      _cachedPhysicalSize = view.physicalSize;
    }
    return _cached!;
  }

  /// قبل أن تُعرف أبعاد النافذة نعيد مقياس ١ بدل صفر
  static double _safe(double scale) =>
      (scale.isFinite && scale > 0) ? scale : 1.0;

  static Size _switchableDesignSize() {return _mediaQueryData.orientation == Orientation.portrait ? _designSize : const Size(716, 360);}

  static double fullScreenHeight({double ratio = 1}) => _mediaQueryData.size.height * ratio;

  static double fullScreenWidth({double ratio = 1}) => _mediaQueryData.size.width * ratio;

  static double availableScreenHeight({double ratio = 1}) => (_mediaQueryData.size.height - _mediaQueryData.viewPadding.vertical) * ratio;

  static double availableScreenWidth({double ratio = 1}) => (_mediaQueryData.size.width - _mediaQueryData.viewPadding.horizontal) * ratio;

  static Orientation orientation() => _mediaQueryData.orientation;

  static double deviceTopPadding() => _mediaQueryData.padding.top;

  static double deviceBottomPadding() => _mediaQueryData.padding.bottom;

  static double deviceBottomViewPadding() => _mediaQueryData.viewPadding.bottom;

  // لوحة المفاتيح لا تغيّر physicalSize، فتُقرأ حية دائمًا
  static double deviceKeyboardHeight() {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final view = dispatcher.implicitView ?? dispatcher.views.first;
    return view.viewInsets.bottom / view.devicePixelRatio;
  }

  static double textScaleFactor() => _mediaQueryData.textScaleFactor;

  static double devicePixelRatio() => _mediaQueryData.devicePixelRatio;

  static double scaleWidth() => _safe(availableScreenWidth() / _switchableDesignSize().width);

  static double scaleHeight() => _safe((_splitScreenMode ? max(availableScreenHeight(), 700) : availableScreenHeight()) / _switchableDesignSize().height);

  static double scaleRadius() => min(scaleWidth(), scaleHeight());

  static double scaleText() => min(scaleWidth(), scaleHeight());
}
