// import Flutter
// import UIKit

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channel = "com.stakeplot.adnan.dev/navigation"
  private let appIconChannel = "com.stakeplot.pfa/app_icon"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set up MethodChannel
    let controller = window?.rootViewController as? FlutterViewController
    let methodChannel = FlutterMethodChannel(name: channel, binaryMessenger: controller!.binaryMessenger)
    let iconMethodChannel = FlutterMethodChannel(name: appIconChannel, binaryMessenger: controller!.binaryMessenger)

    methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getInitialRoute" {
        result(nil) // No initial route for iOS launch
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    iconMethodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard call.method == "changeIcon" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard let arguments = call.arguments as? [String: Any],
            let alias = arguments["alias"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing icon alias.", details: nil))
        return
      }

      self?.changeAppIcon(alias: alias, result: result)
    }

    // Handle launch options (e.g., deep link on app start)
    if let url = launchOptions?[.url] as? URL {
      handleDeepLink(url: url, methodChannel: methodChannel)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    let methodChannel = FlutterMethodChannel(name: channel, binaryMessenger: controller!.binaryMessenger)
    return handleDeepLink(url: url, methodChannel: methodChannel)
  }

  private func handleDeepLink(url: URL, methodChannel: FlutterMethodChannel) -> Bool {
    if url.scheme == "stakeplot" && url.host == "finance" {
      methodChannel.invokeMethod("navigateToFinance", arguments: nil)
      return true
    }
    return false
  }

  private func changeAppIcon(alias: String, result: @escaping FlutterResult) {
    guard UIApplication.shared.supportsAlternateIcons else {
      result(false)
      return
    }

    let iconName = alias == "IconDefault" ? nil : alias

    DispatchQueue.main.async {
      UIApplication.shared.setAlternateIconName(iconName) { error in
        if let error = error {
          NSLog("Icon change failed: \(error.localizedDescription)")
          result(false)
          return
        }

        result(true)
      }
    }
  }
}
