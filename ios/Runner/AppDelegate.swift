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

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set up MethodChannel
    let controller = window?.rootViewController as? FlutterViewController
    let methodChannel = FlutterMethodChannel(name: channel, binaryMessenger: controller!.binaryMessenger)
    methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getInitialRoute" {
        result(nil) // No initial route for iOS launch
      } else {
        result(FlutterMethodNotImplemented)
      }
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
    print("AppDelegate: Handling deep link: \(url.absoluteString)")
    if url.scheme == "stakeplot" && url.host == "finance" {
      methodChannel.invokeMethod("navigateToFinance", arguments: nil)
      print("AppDelegate: Invoked navigateToFinance")
      return true
    }
    return false
  }
}