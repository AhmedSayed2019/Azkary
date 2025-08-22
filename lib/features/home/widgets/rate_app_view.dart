// import 'package:azkark/core/utils/hive_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:in_app_review/in_app_review.dart';
//
// class RateAppView extends StatefulWidget {
//   const RateAppView({Key? key}) : super(key: key);
//
//   @override
//   State<RateAppView> createState() => _RateAppViewState();
// }
//
// class _RateAppViewState extends State<RateAppView> {
//   showDialogForRate() async {
//     if (getValue("timesOfAppOpen") > 2 && getValue("showedDialog") == false) {
//       if (await InAppReview.instance.isAvailable()) {
//         await InAppReview.instance.requestReview();
//         updateValue("showedDialog", true);
//       }
//     }
//   }
//   @override
//   void initState() {
//     showDialogForRate();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
