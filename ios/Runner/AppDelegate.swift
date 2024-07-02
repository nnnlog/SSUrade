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

    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    WorkmanagerPlugin.registerTask(withIdentifier: "ssurade")

//    GeneratedPluginRegistrant.register(with: self)

    AppDelegate.registerPlugins(with: self)
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in AppDelegate.registerPlugins(with: registry) }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
