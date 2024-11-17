import 'package:flutter/material.dart';

class FadeRoute extends PageRouteBuilder {
  final Widget _page;

  FadeRoute({
    required Widget page,
  })  : _page = page,
        super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
