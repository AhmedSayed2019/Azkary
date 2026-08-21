import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';

/// صف اختيار مفرد داخل الشيت — إطار ملوّن عند التحديد بدل [Radio]،
/// تفاديًا لواجهة groupValue/onChanged المهجورة.
class CustomSheetRadioItem<T> extends StatelessWidget {
  const CustomSheetRadioItem({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final T value;
  final T? groupValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    final primary = AppColor.primaryColor.themeColor;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: kFormPaddingAllSmall.h),
      child: Material(
        color: isSelected
            ? AppColor.primaryColorLight.themeColor
            : AppColor.cardColor.themeColor,
        borderRadius: BorderRadius.circular(kFormRadius.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(kFormRadius.r),
          onTap: () => onChanged(value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kFormRadius.r),
              border: Border.all(
                color: isSelected ? primary : AppColor.borderColor.themeColor,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: kFormPaddingAllLarge.w,
              vertical: kFormPaddingAllLarge.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle()
                            .mediumStyle(fontSize: 14)
                            .primaryTextColor(),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: const TextStyle()
                              .mediumStyle(fontSize: 11)
                              .customColor(AppColor.hintColor.themeColor),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: kFormPaddingAllNormal.w),
                _RadioIndicator(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor.themeColor;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? primary : AppColor.borderColor.themeColor,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
            )
          : null,
    );
  }
}
