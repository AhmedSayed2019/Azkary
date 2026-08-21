import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // مطلوب من flutter_local_notifications على iOS 10+: بدونه لا تُعرض
    // الإشعارات والتطبيق في المقدمة، ولا يصل نقر المستخدم إلى Dart.
    // FlutterAppDelegate يطبّق UNUserNotificationCenterDelegate بالفعل.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
