import 'package:azkark/core/localization/db_translations.dart';
import 'dart:ui' as ui;

import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/refactor/azkar/domain/entity/zekr_entity.dart';
import 'package:azkark/util/helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `Zekr` card (`lib/widgets/azkar_widget/zekr_card.dart`).
/// Driven entirely by [ZekrEntity] + callbacks — it reads no provider and
/// holds no state of its own.
class ZekrCard extends StatelessWidget {
  const ZekrCard({
    super.key,
    required this.zekr,
    required this.number,
    required this.total,
    required this.counter,
    required this.counterEnabled,
    required this.diacriticsEnabled,
    required this.showSanad,
    required this.fontSize,
    required this.fontFamily,
    required this.onTap,
    required this.onRefresh,
    required this.onToggleSanad,
  });

  final ZekrEntity zekr;
  final int number;
  final int total;
  final int counter;
  final bool counterEnabled;
  final bool diacriticsEnabled;
  final bool showSanad;
  final double fontSize;
  final String fontFamily;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  final VoidCallback onToggleSanad;

  bool get _isFinished => counter == zekr.counterNumber;

  String get _text =>
      diacriticsEnabled ? zekr.textWithDiacritics : zekr.textWithoutDiacritics;

  /// ما يُنسخ إلى الحافظة: الذكر ثم سنده — بفاصل بصري كما في النسخة القديمة.
  String get _copyText =>
      '$_text\n***********\n${tr('sanad_label')}\n${zekr.sanad}';

  @override
  Widget build(BuildContext context) {
    // حالة «تم»: تُقرأ من الخلفية المخضرّة + الإطار الأخضر معًا، لا من
    // تعتيم النص. الاعتماد على لون الخلفية وحده كان يجعل البطاقة
    // المنتهية شبه مطابقة للعادية، والاعتماد على تفتيح النص كان يجعلها
    // غير مقروءة — فجمعنا إشارتين واضحتين وأبقينا النص بكامل تباينه.
    final primary = AppColor.primaryColor.themeColor;
    final surface = AppColor.backgroundColor.themeColor;

    return Material(
      color: _isFinished
          ? Color.alphaBlend(primary.withValues(alpha: 0.14), surface)
          : surface,
      borderRadius: BorderRadius.circular(kFormRadius),
      child: Container(
        decoration: const BoxDecoration().radius(radius: kFormRadius).borderAll(
              border: Border.all(
                color: _isFinished ? primary : Colors.transparent,
                width: 1.6,
              ),
            ),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(kFormRadius),
          onTap: counterEnabled ? onTap : null,
          onLongPress: () => copyText(context, _copyText),
          child: Padding(
            padding: const EdgeInsets.all(kScreenPaddingNormal),
            child: Column(
              children: <Widget>[
                _RefreshSlot(visible: _isFinished, onRefresh: onRefresh),
                _ZekrText(
                  text: _text,
                  meaning: zekr.meaning,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                ),
                _RepetitionsLabel(
                  counterText: zekr.counterText,
                  fontFamily: fontFamily,
                ),
                _BottomRow(
                  number: number,
                  total: total,
                  counter: counter,
                  counterNumber: zekr.counterNumber,
                  isFinished: _isFinished,
                  showSanad: showSanad,
                  fontFamily: fontFamily,
                  onCopy: () => copyText(context, _copyText),
                  onToggleSanad: onToggleSanad,
                ),
                if (showSanad)
                  _SanadBlock(
                    sanad: zekr.sanad,
                    fontSize: fontSize,
                    fontFamily: fontFamily,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// يحجز ارتفاع زر الإرجاع دائمًا حتى لا تقفز البطاقة عند اكتمال العدّ.
class _RefreshSlot extends StatelessWidget {
  const _RefreshSlot({required this.visible, required this.onRefresh});

  final bool visible;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(height: 24);

    return Align(
      alignment: Alignment.topLeft,
      child: InkWell(
        onTap: onRefresh,
        child: Icon(Icons.refresh, color: AppColor.primaryColor.themeColor),
      ),
    );
  }
}

class _ZekrText extends StatelessWidget {
  const _ZekrText({
    required this.text,
    required this.meaning,
    required this.fontSize,
    required this.fontFamily,
  });

  final String text;
  final String? meaning;
  final double fontSize;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    // العربية دائمًا — هي ما يُتلى. الترجمة سطر معنى تحتها لا بديل عنها.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.rtl,
          // خط وحجم يختارهما المستخدم من الإعدادات، فلا يمرّان بأنماط النص
          // الجاهزة التي تثبّت العائلة والقياس.
          style: const TextStyle()
              .customFontFamily(fontFamily)
              .primaryTextColor()
              .copyWith(fontSize: fontSize),
        ),
        if (meaning != null) ...[
          const SizedBox(height: kFormPaddingAllLarge),
          Container(
            height: 1,
            width: 60,
            color: AppColor.borderColor.themeColor,
          ),
          const SizedBox(height: kFormPaddingAllLarge),
          Text(
            meaning!,
            textAlign: TextAlign.center,
            textDirection: ui.TextDirection.ltr,
            style: const TextStyle()
                .customColor(AppColor.textSecondaryDark.themeColor)
                .heightStyle(height: 1.5)
                .copyWith(fontSize: fontSize * 0.72),
          ),
        ],
      ],
    );
  }
}

class _RepetitionsLabel extends StatelessWidget {
  const _RepetitionsLabel({
    required this.counterText,
    required this.fontFamily,
  });

  final String counterText;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: kScreenPaddingNormal,
        bottom: kFormPaddingAllSmall,
      ),
      child: Text(
        counterText.isEmpty
            ? tr('zekr_repeated_once')
            : DbTranslations.counterText(counterText),
        style: const TextStyle()
            .customFontFamily(fontFamily)
            .customColor(AppColor.textSecondaryDark.themeColor)
            .copyWith(fontSize: 12),
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.number,
    required this.total,
    required this.counter,
    required this.counterNumber,
    required this.isFinished,
    required this.showSanad,
    required this.fontFamily,
    required this.onCopy,
    required this.onToggleSanad,
  });

  final int number;
  final int total;
  final int counter;
  final int counterNumber;
  final bool isFinished;
  final bool showSanad;
  final String fontFamily;
  final VoidCallback onCopy;
  final VoidCallback onToggleSanad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kScreenPaddingNormal),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'zikr_n_of_m'.tr(namedArgs: {'n': '$number', 'total': '$total'}),
              textAlign: TextAlign.center,
              style: const TextStyle()
                  .customFontFamily(fontFamily)
                  .customColor(AppColor.textSecondaryDark.themeColor)
                  .copyWith(fontSize: 14),
            ),
          ),
          if (counter != 0)
            Align(
              alignment: Alignment.center,
              child: _CounterChip(
                counter: counter,
                counterNumber: counterNumber,
                isFinished: isFinished,
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CardIconButton(icon: Icons.content_copy, onTap: onCopy),
                _CardIconButton(
                  icon: showSanad ? Icons.info : Icons.info_outline,
                  onTap: onToggleSanad,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardIconButton extends StatelessWidget {
  const _CardIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: kFormPaddingAllNormal),
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, color: AppColor.primaryColor.themeColor),
      ),
    );
  }
}

class _CounterChip extends StatelessWidget {
  const _CounterChip({
    required this.counter,
    required this.counterNumber,
    required this.isFinished,
  });

  final int counter;
  final int counterNumber;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: kFormPaddingAllSmall,
        horizontal: kScreenPaddingNormal,
      ),
      decoration: const BoxDecoration()
          .customColor(isFinished
              ? AppColor.cardColor.themeColor
              : AppColor.primaryColor.themeColor)
          .radius(radius: kFormRadiusLarge),
      child: Text(
        '$counter / $counterNumber',
        style: const TextStyle()
            .customColor(isFinished
                ? AppColor.textColor.themeColor
                : AppColor.textColorLite.lightColor)
            .copyWith(fontSize: 14),
      ),
    );
  }
}

class _SanadBlock extends StatelessWidget {
  const _SanadBlock({
    required this.sanad,
    required this.fontSize,
    required this.fontFamily,
  });

  final String sanad;
  final double fontSize;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: kScreenPaddingLarge,
        vertical: kFormPaddingVertical,
      ),
      margin: const EdgeInsets.only(top: kFormPaddingAllLarge),
      decoration: const BoxDecoration()
          .customColor(AppColor.primaryColorLight.themeColor)
          .radius(radius: kFormRadius),
      child: Text(
        sanad,
        style: const TextStyle()
            .customFontFamily(fontFamily)
            .customColor(AppColor.textSecondaryDark.themeColor)
            .copyWith(fontSize: fontSize - 2),
      ),
    );
  }
}
