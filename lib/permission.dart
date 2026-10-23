import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

checkNotificationPermission() async {
  PermissionStatus status = await Permission.notification.request();
  //PermissionStatus status1 = await Permission.accessMediaLocation.request();
  // PermissionStatus status2 =
  //     await Permission.locationWhenInUse.request();
  // لا نفتح إعدادات النظام تلقائيًا عند الرفض الدائم: هذه الدالة تُستدعى
  // مع كل إقلاع، فكان التطبيق يقذف المستخدم إلى الإعدادات في كل فتح.
  debugPrint('notification permission: $status');
}


// initStoragePermission() async {
//   List<Permission> permissions = [
//     Permission.storage,
//   ];
//
//   if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
//     permissions.add(Permission.photos);
//     permissions.add(Permission.audio);
//     permissions.add(Permission.location);
//
//     // permissions.add(Permission.videos);
//   }
//
//   await permissions.request();
//   MediaStore.appFolder = "Skoon";
//   initMessaging();
//   setOptimalDisplayMode();
// }