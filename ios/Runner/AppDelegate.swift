import Flutter
import UIKit

enum SystemKeyboardConstraintLogPolicy {
  static func apply(to defaults: UserDefaults = .standard) {
    #if DEBUG
      defaults.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    #endif
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // iOS 26's TextInputUI logs contradictory constraints while laying out
    // CJK prediction cells. This suppresses that system-only noise in debug.
    SystemKeyboardConstraintLogPolicy.apply()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
