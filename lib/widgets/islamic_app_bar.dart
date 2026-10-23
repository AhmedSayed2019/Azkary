// شريط تطبيق موحّد بنسيج النجوم الإسلامي.
//
// كان كل شاشة تبني AppBar بلونها وارتفاعها، فاختلف الهيدر بين شاشة
// وأخرى. هذا يجمعها على شكل واحد: أرضية خضراء + نقش النجوم + أيقونات
// ونص فاتح، وشريط حالة بأيقونات فاتحة تناسب الأخضر.

import 'package:azkark/core/res/resources.dart';
import 'package:azkark/widgets/islamic_header_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IslamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IslamicAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.bottom,
    this.toolbarHeight,
    this.automaticallyImplyLeading = true,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) +
            (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColor.primaryColor.themeColor,
      // النقش يُرسم في flexibleSpace خلف العنوان والأيقونات
      flexibleSpace: const IslamicHeaderBackground(child: SizedBox.expand()),
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      title: titleWidget ??
          Text(
            title ?? '',
            style: const TextStyle()
                .semiBoldStyle(fontSize: 17)
                .customColor(Colors.white),
          ),
    );
  }
}
