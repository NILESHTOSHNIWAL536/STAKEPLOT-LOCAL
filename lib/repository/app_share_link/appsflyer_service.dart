import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/repository/auth_service/login_apis.dart';
import 'package:flutter_application_code_stakeplot/repository/referral_repository.dart';
import 'package:flutter_application_code_stakeplot/services/secure_storage.dart';

import '../../Home_Screen/Home/init_Api_Calls.dart';
import '../../Home_Screen/history/transactionHistoryScreen.dart';
import '../../Home_Screen/home_screen_state/home_page.dart';
import '../../finance_screen/Budgets/Budget.dart';
import '../../finance_screen/Calculators/veg_nonveg.dart';
import '../../main.dart';
import '../../signInOut/referral_code_screen.dart';

class AppsflyerService {
  static late AppsflyerSdk _appsflyerSdk;

  static Future<void> init() async {
    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "aweZpvW8Js8ax3agtaTTvD",
      appId: "",
      showDebug: true,
      timeToWaitForATTUserAuthorization: 10,
    );

    _appsflyerSdk = AppsflyerSdk(options);

    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _appsflyerSdk.startSDK(
      onSuccess: () {
        appLog("AppsFlyer SDK started");
      },
    );

    final uid = await _appsflyerSdk.getAppsFlyerUID();
    appLog("AppsFlyer UID: $uid");

    _listenToCallbacks();
  }

  static String generateReferralLink(String refCode) {
    return "https://stagingstakeplot.onelink.me/vf5p/8m41djpj"
        "?pid=User_invite"
        "&c=referral"
        "&deep_link_value=signup"
        "&deep_link_sub1=$refCode";
  }

  static void _listenToCallbacks() {
    _appsflyerSdk.onInstallConversionData((data) async {
      appLog("Install data: $data");

      final payload = data["payload"] ?? data;

      final status = payload["af_status"];
      appLog("Install status: $status");

      // Direct values
      final directReferralCode = payload["deep_link_sub1"]?.toString();
      final directScreen = payload["deep_link_value"]?.toString();

      // Fallback values
      final fallbackReferralCode = payload["ref"]?.toString();
      final fallbackScreen = payload["path"]?.toString();

      // Link parsing (same as deep link)
      final link = payload["link"];

      String? queryReferralCode;
      String? queryScreen;

      if (link is String && link.isNotEmpty) {
        final uri = Uri.tryParse(link);

        queryReferralCode = uri?.queryParameters['deep_link_sub1'] ??
            uri?.queryParameters['ref'];

        queryScreen = uri?.queryParameters['deep_link_value'] ??
            uri?.queryParameters['path'];
      }

      // Final resolved values (priority order)
      final referralCode =
          queryReferralCode ?? directReferralCode ?? fallbackReferralCode;

      final screen = queryScreen ?? directScreen ?? fallbackScreen ?? "signup";

      // Navigate if valid
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        await handleReferralNavigation(
          refCode: referralCode,
          screen: screen,
          source: 'install',
        );
      }
    });

    // _appsflyerSdk.onInstallConversionData((data) async {
    //   appLog("Install data: $data");

    //   final payload = data["payload"] ?? data;
    //   final refCode = data["deep_link_sub1"]?.toString();
    //   final screen = data["deep_link_value"]?.toString();
    //   final status = payload["af_status"];

    //   appLog("Install status: $status");

    //   await handleReferralNavigation(
    //     refCode: refCode ?? "Stakeplot",
    //     screen: screen ?? "signup",
    //     source: 'install',
    //   );
    // });

    _appsflyerSdk.onAppOpenAttribution((data) {
      appLog("App open data: $data");
    });

    _appsflyerSdk.onDeepLinking((deepLinkResult) async {
      final deepLink = deepLinkResult.deepLink;
      final clickEvent = deepLink?.clickEvent ?? <String, dynamic>{};

      appLog("Deep link data: $clickEvent");

      final directReferralCode = clickEvent["deep_link_sub1"]?.toString();
      final directScreen = clickEvent["deep_link_value"]?.toString();
      final fallbackReferralCode = clickEvent["ref"]?.toString();
      final fallbackScreen = clickEvent["path"]?.toString();
      final link = clickEvent["link"];

      String? queryReferralCode;
      String? queryScreen;

      if (link is String && link.isNotEmpty) {
        final uri = Uri.tryParse(link);
        queryReferralCode = uri?.queryParameters['deep_link_sub1'] ??
            uri?.queryParameters['ref'];
        queryScreen = uri?.queryParameters['deep_link_value'] ??
            uri?.queryParameters['path'];
      }

      final referralCode =
          queryReferralCode ?? directReferralCode ?? fallbackReferralCode;
      final screen = queryScreen ?? directScreen ?? fallbackScreen ?? "signup";

      if (referralCode != null && referralCode.trim().isNotEmpty) {
        await handleReferralNavigation(
          refCode: referralCode,
          screen: screen,
          source: 'deep_link',
        );
      }
    });
  }

  static Future<void> handleReferralNavigation({
    required String refCode,
    required String screen,
    required String source,
  }) async {
    final normalizedCode = ReferralRepository.normalizeCode(refCode);
    final bool isLoggedIn =
        await SecureStorageService().containsKey("accessToken");
    final bool isOwnCode =
        await ReferralRepository.isMyOwnReferralCode(normalizedCode);

    appLog(
        "Referral navigation source=$source screen=$screen code=$normalizedCode loggedIn=$isLoggedIn isOwnCode=$isOwnCode");

    // if (isOwnCode && isLoggedIn) {
    //   _showOwnReferralCodeDialog(normalizedCode);
    //   return;
    // }

    await ReferralRepository.saveIncomingReferralCode(normalizedCode);
    print(await SecureStorageService().read("incoming_referral_code"));

    if (isLoggedIn) {
      try {
        callApi(navigatorKey.currentState!.context);
      } catch (e) {}

      AppNavigator.pushReplacementNamed("/home");
      AppNavigator.push(navigatePath(screen));
      return;
    }
  }

  static Widget navigatePath(String navigate) {
    if (navigate == "home")
      return VegNonVegCalculator();
    else if (navigate == "budget")
      return Budget();
    else if (navigate == "code")
      return ReferralCodeScreen();
    else if (navigate == "coll") {
      selectedTab.value == "Alla";
      return TransactionHistoryScreen();
    }
    return HomePage();
  }

  static void _showOwnReferralCodeDialog(String refCode) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (_) => _OwnReferralCodeDialog(refCode: refCode),
    );
  }

  static void showSelfReferralDialogIfNeeded(String refCode) {
    _showOwnReferralCodeDialog(refCode);
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

  static Future push(Widget page) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pop() {
    navigatorKey.currentState!.pop();
  }
}

class _OwnReferralCodeDialog extends StatelessWidget {
  final String refCode;

  const _OwnReferralCodeDialog({required this.refCode});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFF8F3EA), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF4B4D73).withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.link_off_rounded,
                size: 30,
                color: Color(0xFF4B4D73),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'This is your own referral link',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2230),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You opened the app using your own code $refCode. Share it with a friend to unlock rewards, but it cannot be applied on your own account.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF63697A),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B4D73),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
