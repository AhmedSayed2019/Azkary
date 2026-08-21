import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/widgets/sheet/custom_sheet_divider.dart';
import 'package:azkark/widgets/sheet/custom_sheet_header.dart';
import 'package:flutter/material.dart';

/// هيكل الشيت: رأس ثابت، فاصل، ثم جسم قابل للتمرير.
///
/// [maxHeightFactor] مع [Flexible] حول الجسم هو ما يمنع الطفح: الشيت
/// لا يتجاوز هذه النسبة من الشاشة، وما زاد عن ذلك يُمرَّر بدل أن يفيض.
class BaseSheetShell extends StatelessWidget {
  const BaseSheetShell({
    super.key,
    required this.title,
    required this.body,
    this.onCancel,
    this.maxHeightFactor = 0.75,
    this.actionLabel,
    this.onActionPress,
    this.footer,
    this.scrollable = true,
  });

  final String title;
  final Widget body;
  final VoidCallback? onCancel;
  final double maxHeightFactor;
  final String? actionLabel;
  final VoidCallback? onActionPress;
  final Widget? footer;

  /// اجعلها false إذا كان [body] يدير تمريره بنفسه.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * maxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: AppColor.primaryBackgroundColor.themeColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(kCartRadius.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSheetHeader(
              title: title,
              onCancelPress: onCancel ?? () => Navigator.of(context).pop(),
              actionLabel: actionLabel,
              onActionPress: onActionPress,
            ),
            const CustomSheetDivider(),
            Flexible(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        kFormPaddingAllLarge.w,
                        kFormPaddingAllLarge.h,
                        kFormPaddingAllLarge.w,
                        kFormPaddingAllLarge.h,
                      ),
                      child: body,
                    )
                  : body,
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
