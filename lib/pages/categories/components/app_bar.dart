import 'package:flutter/material.dart';

import '../../../pages/search/search_azkar.dart';
import '../../../util/colors.dart';
import '../../../util/navigate_between_pages/fade_route.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AnimationController? _animationController;
  final String _title;
  final VoidCallback?  _onTap;
  const CustomAppBar({
     AnimationController? animationController,
    required String title,
     VoidCallback? onTap,
  })  : _animationController = animationController,
        _title = title,
        _onTap = onTap;
  @override
  Size get preferredSize =>
      Size.fromHeight(AppBar().preferredSize.height); //50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: Text(
        _title,
        style: new TextStyle(
          color: teal[50],
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.all(4.0),
          child: IconButton(
              color: teal[50],
              highlightColor: teal[700],
              splashColor: teal[700],
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(context, FadeRoute(page: SearchForZekr()));
              }),
        ),
        if (_animationController != null) _buildMenuButton(),
      ],
    );
  }

  Widget _buildMenuButton() {
    return Padding(
      padding: EdgeInsets.only(left: 5.0),
      child: IconButton(
        highlightColor: teal[700],
        splashColor: teal[700],
        onPressed: _onTap,
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animationController!,
          color: teal[50],
        ),
      ),
    );
  }


}
