import 'package:flutter/material.dart';

import '../../util/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String _title;
  final  GestureTapCallback? _onTap;

  /// عند false يُرسم حقل البحث بدون الشريط الأخضر الخلفي (للاستخدام وسط الصفحة
  /// بدلًا من أسفل شريط التطبيق مباشرة).
  final bool showBackground;

  const CustomSearchBar({super.key,
    required String title,
    required GestureTapCallback? onTap,
    this.showBackground = true,
  })  : _title = title,
        _onTap = onTap;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: _onTap,
      child: Container(
        width: size.width,
        padding: const EdgeInsets.all(10),
        decoration: showBackground
            ? BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              )
            : null,
        child: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          height: size.height * 0.055,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: showBackground ? null : Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.search, color: Theme.of(context).primaryColor),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  _title,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
