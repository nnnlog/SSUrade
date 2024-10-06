import UIKit
import Flutter
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {

    static func registerPlugins(with registry: FlutterPluginRegistry) {
        GeneratedPluginRegistrant.register(with: registry)
    }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }

    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "ssurade.fetch", frequency: NSNumber(value: 15 * 60))

    AppDelegate.registerPlugins(with: self)
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in AppDelegate.registerPlugins(with: registry) }

    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                           willPresent notification: UNNotification,
                                           withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           completionHandler(.alert) // shows banner even if app is in foreground
       }
}
