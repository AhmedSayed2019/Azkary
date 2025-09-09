import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


@immutable
final class AppAlert {
  static Future<T?> showLoading<T>(BuildContext context) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CupertinoActivityIndicator(color: Theme.of(context).colorScheme.primary, radius: 16),
            ),
          ),
          content: Text(tr('pleaseWait'), style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
        );
      },
    );
  }

  static void showErrorDialog(
    BuildContext context, {
    required String errorText,
    Widget? title,
    void Function()? onPressed,
    TextStyle? textStyle,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(tr('error')),
          content: Text(errorText, style: textStyle),
          actions: <Widget>[
            CupertinoButton(
              onPressed: onPressed ?? () => context.popRoute(),
              child: Text(tr('cancel, style: textStyle')),
            ),
          ],
        );
      },
    );
  }

  static void showRestartDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(tr('restartApp')),
          content: Text(tr('restartForDevMode')),
          actions: <Widget>[CupertinoButton(onPressed: () => exit(0), child: Text(tr('restart')))],
        );
      },
    );
  }

  static void showUpdateLocation({
    required BuildContext context,
    required String newLocation,
    required void Function(BuildContext ctx) onConfirm,
    required void Function(BuildContext ctx) onCancel,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: Text(tr('newLocationDetected'), textAlign: TextAlign.center),
          content: Column(
            children: [
              Text(newLocation, textAlign: TextAlign.center),
              Text(tr('doYouWantToChange'), textAlign: TextAlign.center),
            ],
          ),
          actions: <Widget>[
            CupertinoButton(onPressed: () => onCancel(ctx), child: Text(tr('cancel'))),
            CupertinoButton(onPressed: () => onConfirm(ctx), child: Text(tr('yes') )),
          ],
        );
      },
    );
  }
}
