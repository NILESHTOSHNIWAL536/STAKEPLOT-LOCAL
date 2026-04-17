import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:get/get.dart';

import '../../main.dart';

class AppsflyerService {
  static late AppsflyerSdk _appsflyerSdk;

  /// 🔥 INIT SDK
  static Future<void> init() async {
    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "aweZpvW8Js8ax3agtaTTvD",
      appId: "", // iOS only
      showDebug: true,
      timeToWaitForATTUserAuthorization: 10,
    );

    _appsflyerSdk = AppsflyerSdk(options);

    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    /// 🔥 MUST START SDK
    _appsflyerSdk.startSDK(
      onSuccess: () {
        appLog("✅ AppsFlyer SDK Started");
      },
    );

    String? uid = await _appsflyerSdk.getAppsFlyerUID();
    appLog("📱 AppsFlyer UID: $uid");

    _listenToCallbacks();
  }

  /// 🔥 GENERATE REFERRAL LINK
  static String generateReferralLink(String refCode) {
    return "https://stagingstakeplot.onelink.me/vf5p/8m41djpj"
        "?pid=User_invite"
        "&c=referral"
        "&deep_link_value=signup"
        "&deep_link_sub1=$refCode";
  }

  /// 🔥 CALLBACKS
  static void _listenToCallbacks() {
    /// ✅ INSTALL (First time app install)
    _appsflyerSdk.onInstallConversionData((data) {
      appLog("📦 Install Data: $data");

      final payload = data["payload"] ?? data;
      final refCode = data["deep_link_sub1"];
      final screen = data["deep_link_value"];
      final status = payload["af_status"];

      //  if (status == "Non-organic") {
      //   DeepLinkManager.setData(screen, refCode);
      // }
      appLog("status----------------------------");
      appLog(status);

      if (refCode != null && status == "Organic") {
        appLog("🎯 Install Referral Code: $refCode");
        // _navigate(screen, refCode);
        // refCode
      }
    });

    /// ✅ APP OPEN (when app already installed)
    _appsflyerSdk.onAppOpenAttribution((data) {
      appLog("🔁 App Open Data: $data");
    });

    /// ✅ DEEP LINK (BEST CASE)
    _appsflyerSdk.onDeepLinking((deepLinkResult) {
      final deepLink = deepLinkResult.deepLink;
      appLog("🔗 Deep Link Data: ${deepLink?.clickEvent}");

      final refCode = deepLink?.clickEvent["ref"];
      final screen = deepLink?.clickEvent["path"];
      final link = deepLink?.clickEvent["link"];

      appLog("refCode", refCode, "screen", screen);
      appLog("link", link);

      String? refCode2;
      String screen2 = "";

      if (link != null && link is String) {
        final uri = Uri.parse(link);

        refCode2 = uri.queryParameters['ref'];
        screen2 = uri.queryParameters['path'] ?? "home";
      }

      appLog("refCode", refCode, "screen", screen);
      appLog("link", link);
      // final refCode = deepLink?.clickEvent["deep_link_sub1"];
      // final screen = deepLink?.clickEvent["deep_link_value"];

      if (refCode2 != null) {
        appLog("🎯 DeepLink Referral Code: $refCode");
        _navigate(screen2, refCode2);
      }
    });
  }

  /// 🔥 NAVIGATION HANDLER
  static void _navigate(String screen, String refCode) {
    appLog("📍 Navigating to: $screen with ref: $refCode");

    switch (screen) {
      case "signup":
        AppNavigator.pushNamed(
          "/signup",
          arguments: {"refCode": refCode},
        );
        break;

      case "home" || "/home":
        AppNavigator.pushNamed(
          "/VegNonveg",
          arguments: {"refCode": refCode},
        );
        break;

      default:
        appLog("⚠️ Unknown screen: $screen");
    }
  }

  static void _navigatew(String? screen, String? refCode) {
    appLog("📍 Navigating to: $screen with ref: $refCode");

    switch (screen) {
      case "signup":
        Get.toNamed("/signup", arguments: {"refCode": refCode});
        break;

      case "home":
        Get.toNamed("/home", arguments: {"refCode": refCode});
        break;

      default:
        appLog("⚠️ Unknown screen: $screen");
    }
  }
}

class AppNavigator {
  static Future pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future pushReplacementNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static void pop() {
    navigatorKey.currentState!.pop();
  }
}
