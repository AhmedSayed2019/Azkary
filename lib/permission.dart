import 'package:permission_handler/permission_handler.dart';

checkNotificationPermission() async {
  PermissionStatus status = await Permission.notification.request();
  //PermissionStatus status1 = await Permission.accessMediaLocation.request();
  // PermissionStatus status2 =
  //     await Permission.locationWhenInUse.request();
  print('status $status ');
  if (status.isGranted) {
    print(true);
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
  } else if (status.isDenied) {
    print('Permission Denied');
  }
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