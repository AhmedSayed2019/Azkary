import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';

/// رأس الشيت: مقبض السحب، ثم أيقونة الإغلاق والعنوان في سطر واحد.
///
/// منقول عن `base/presentation/sheet` في مشروع جملة ومكيّف على موارد
/// أذكاري: أيقونة Material بدل SVG، وألوان [AppColor] بدل باليت جملة.
class CustomSheetHeader extends StatelessWidget {
  const CustomSheetHeader({
    super.key,
    this.title,
    this.titleWidget,
    required this.onCancelPress,
    this.actionLabel,
    this.onActionPress,
    this.endWidget,
  });

  final String? title;
  final Widget? titleWidget;
  final VoidCallback onCancelPress;
  final String? actionLabel;
  final VoidCallback? onActionPress;
  final Widget? endWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        kFormPaddingAllLarge.w,
        kFormPaddingAllNormal.h,
        kFormPaddingAllLarge.w,
        kFormPaddingAllNormal.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColor.hintColor.themeColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: kFormPaddingAllLarge.h),
          Row(
            children: [
              // زر الإغلاق — مساحة لمس ٤٠ لا حجم الأيقونة وحده
              InkWell(
                onTap: onCancelPress,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(kFormPaddingAllNormal.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: AppColor.textColor.themeColor,
                  ),
                ),
              ),
              SizedBox(width: kFormPaddingAllNormal.w),
              Expanded(
                child: titleWidget ??
                    Text(
                      title ?? '',
                      style: const TextStyle()
                          .semiBoldStyle(fontSize: 16)
                          .primaryTextColor(),
                    ),
              ),
              if (endWidget != null) endWidget!,
              if (actionLabel != null)
                TextButton(
                  onPressed: onActionPress,
                  child: Text(
                    actionLabel!,
                    style: const TextStyle()
                        .semiBoldStyle(fontSize: 13)
                        .customColor(AppColor.primaryColor.themeColor),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
