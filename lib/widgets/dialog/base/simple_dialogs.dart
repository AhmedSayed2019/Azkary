import 'package:azkark/core/res/resources.dart';
import 'package:azkark/widgets/dialog/base/awesome/awesome_dialog.dart';
import 'package:flutter/material.dart';


void showErrorDialog(
  BuildContext context,
  String title,
  String description,
) {
  AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      headerAnimationLoop: false,
      title: 'Error',
      useRootNavigator: true,
      desc: 'Dialog description here.............................',
      btnOkOnPress: () {},
      btnOkIcon: Icons.cancel,
      btnOkColor: Colors.red)
    .show();
}

Future<dynamic> showQuestionDialog(
  BuildContext context, {
  String? question,
  String? desc,
  String? btnTextPositive,
  String? btnTextNegative,

  VoidCallback? onPositiveClick,
  VoidCallback? onNegativeClick,
}) {
  final dialog = AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: question,
    desc: desc,
    // customHeader: Container(
    //   width: deviceWidth,
    //   height:deviceHeight,
    //
    //   padding: EdgeInsets.all(kFormPaddingAllSmall.w),
    //   decoration: BoxDecoration(
    //     color: Theme.of(context).primaryColor,
    //     shape: BoxShape.circle
    //   ),
    //   child: Image.asset(
    //     Assets.imagesLogo,
    //     // color: Theme.of(context).primaryColor,
    //     height: 63.h,
    //     width: 61.w,
    //   ),
    // ),
    btnOkColor: Colors.green,
    btnCancelColor: Theme.of(context).colorScheme.error,
    descTextStyle: const TextStyle().descriptionStyle(),
    alignment: AlignmentDirectional.centerStart,
    showCloseIcon: true,
    btnCancelOnPress: onNegativeClick,
    btnOkOnPress: onPositiveClick,
    btnOkText: btnTextPositive,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    btnCancelText: btnTextNegative,
  );

  return dialog.show(); // returning result
}

void showSuccessDialog(
  BuildContext context,
  String title,
  String desc,
) {
  AwesomeDialog(
      context: context,
      animType: AnimType. leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      useRootNavigator: true,
      title: 'Succes',
      desc: 'Dialog description here......................',
      btnOkOnPress: () {
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (t) {
        debugPrint('Dialog Dismiss from callback');
      })
    .show();
}

// will be used for simple custom dialogs like signing out loading indicator
Future showCustomDialog(BuildContext context, Widget body, {Color? backgroundColor,String? backgroundImage,Widget? closeIcon,Widget? header,required Function onDismissCallback, bool isCancellable = false})async {
 return AwesomeDialog(
    dialogBackgroundColor:backgroundColor??Theme.of(context).cardColor,
      dialogBackgroundImage:backgroundImage,

      context: context,
      animType: AnimType. bottomSlide,
      headerAnimationLoop: false,
      dismissOnTouchOutside: false,

      dialogType: DialogType.noHeader,
      dismissOnBackKeyPress: isCancellable,
      closeIcon: closeIcon,
      customHeader: header,
      showCloseIcon: closeIcon!=null,
      useRootNavigator: true,
      onDismissCallback:(t)=> onDismissCallback() ,
      body: body)
    .show();
}

// will be used for simple custom dialogs like signing out loading indicator
void showAutoHideCustomDialog(BuildContext context, Widget body,
    {required Function onDismiss}) async {
  AwesomeDialog(
      context: context,
      dialogBackgroundColor: Colors.white,
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      autoHide: const Duration(seconds: 3),
      onDismissCallback:(t)=> {onDismiss()},
      dismissOnTouchOutside: false,
      dialogType: DialogType.noHeader,
      dismissOnBackKeyPress: false,
      useRootNavigator: true,
      body: body)
    .show();
}

void showAutoHideDialog(BuildContext context, Widget body) async {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    animType: AnimType.scale,
    title: 'Auto Hide Dialog',
    desc: 'AutoHide after 2 seconds',
    autoHide: const Duration(seconds: 2),
  ).show();
}
