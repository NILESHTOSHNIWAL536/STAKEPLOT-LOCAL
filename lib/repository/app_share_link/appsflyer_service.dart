import 'dart:convert';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/repository/auth_service/login_apis.dart';
import 'package:flutter_application_code_stakeplot/repository/referral_repository.dart';
import 'package:flutter_application_code_stakeplot/services/secure_storage.dart';

import '../../Home_Screen/Home/init_Api_Calls.dart';
import '../../Home_Screen/history/transactionHistoryScreen.dart';
import '../../Home_Screen/home_screen_state/home_page.dart';
import '../../backed_connections/apiAutomations/install_apk_api.dart';
import '../../finance_screen/Budgets/Budget.dart';
import '../../finance_screen/Calculators/veg_nonveg.dart';
import '../../main.dart';
import '../../signInOut/referral_code_screen.dart';

class AppsflyerService {
  static late AppsflyerSdk _appsflyerSdk;

  /// True once a cold-start deep link has stored the target screen.
  /// `checkAuthAndNavigate` (splash) reads this flag to know it should
  /// skip its own default navigation.
  static bool coldStartHandled = false;

  // ─── Init ────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "aweZpvW8Js8ax3agtaTTvD",
      appId: Platform.isIOS ? "1234567890" : "",
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
      onSuccess: () => appLog("AppsFlyer SDK started"),
    );

    appLog("AppsFlyer UID: ${await _appsflyerSdk.getAppsFlyerUID()}");
    _listenToCallbacks();
  }

  // ─── Link generator ──────────────────────────────────────────────────────

  static String generateReferralLink(String refCode) =>
      "https://stagingstakeplot.onelink.me/vf5p/8m41djpj"
      "?pid=User_invite&c=referral&deep_link_value=signup&deep_link_sub1=$refCode";

  // ─── Payload extractor (shared logic) ───────────────────────────────────

  static _DeepLinkPayload _extractPayload(Map<dynamic, dynamic> raw) {
    String? queryCode, queryScreen;
    final link = raw["link"];
    if (link is String && link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      queryCode =
          uri?.queryParameters['deep_link_sub1'] ?? uri?.queryParameters['ref'];
      queryScreen = uri?.queryParameters['deep_link_value'] ??
          uri?.queryParameters['path'];
    }

    return _DeepLinkPayload(
      referralCode: queryCode ??
          raw["deep_link_sub1"]?.toString() ??
          raw["ref"]?.toString(),
      screen: queryScreen ??
          raw["deep_link_value"]?.toString() ??
          raw["path"]?.toString() ??
          "signup",
    );
  }

  // ─── Callbacks ───────────────────────────────────────────────────────────

  static Future<void> handleInstallAttribution(
    Map<dynamic, dynamic> data,
  ) async {
    try {
      final payload = (data["payload"] ?? data) as Map<dynamic, dynamic>;

      final isOrganic = payload["af_status"] == "Organic";
      final mediaSource = payload["media_source"];
      final campaign = payload["campaign"];

      final installData = {
        "installType": isOrganic ? "organic" : "non-organic",
        "mediaSource": mediaSource ?? "unknown",
        "campaign": campaign ?? "unknown",
        "appsFlyerId": await _appsflyerSdk.getAppsFlyerUID(),
        "raw": payload, // optional
      };

      appLog("📦 Install Attribution → $installData");

      // ✅ store locally (safe)
      await SecureStorageService()
          .setString("installData", jsonEncode(installData));

      // ✅ send if logged in
      final isLoggedIn =
          await SecureStorageService().containsKey("accessToken");

       await sendPendingInstallData();
  
    } catch (e) {
      appLog("❌ Attribution error: $e");
    }
  }

  static void _listenToCallbacks() {
    _appsflyerSdk.onInstallConversionData((data) async {
      appLog("onInstallConversionData: $data");

      try {
        // ✅ NEW METHOD (plugged in)
        await handleInstallAttribution(data);
      } catch (e) {
        appLog(e);
      }

      final p =
          _extractPayload((data["payload"] ?? data) as Map<dynamic, dynamic>);
      appLog("Install → code=${p.referralCode} screen=${p.screen}");

      if (p.referralCode?.trim().isNotEmpty == true) {
        await handleReferralNavigation(
            refCode: p.referralCode!, screen: p.screen, source: 'install');
      }
    });

    _appsflyerSdk.onAppOpenAttribution((data) {
      appLog("onAppOpenAttribution: $data");
    });

    _appsflyerSdk.onDeepLinking((result) async {
      final click = result.deepLink?.clickEvent ?? <String, dynamic>{};
      appLog("onDeepLinking: $click");
      final p = _extractPayload(click);
      appLog("DeepLink → code=${p.referralCode} screen=${p.screen}");

      if (p.referralCode?.trim().isNotEmpty == true) {
        await handleReferralNavigation(
            refCode: p.referralCode!, screen: p.screen, source: 'deep_link');
      }
    });
  }

  // ─── Core navigation handler ─────────────────────────────────────────────
  //
  // Two scenarios:
  //   • Cold start  – navigator not mounted yet.
  //                   Write "Screen" to storage; let checkAuthAndNavigate (splash)
  //                   read it. This kills the race condition that caused the
  //                   login-page redirect.
  //   • Warm start  – app already running; navigate directly and fire callApi
  //                   in the background so it never blocks the transition.

  static Future<void> handleReferralNavigation({
    required String refCode,
    required String screen,
    required String source,
  }) async {
    final normalizedCode = ReferralRepository.normalizeCode(refCode);
    final bool isLoggedIn =
        await SecureStorageService().containsKey("accessToken");

    appLog("handleReferral source=$source screen=$screen "
        "code=$normalizedCode loggedIn=$isLoggedIn");

    // Persist incoming code regardless of auth state.
    await ReferralRepository.saveIncomingReferralCode(normalizedCode);

    if (!isLoggedIn) {
      // Save screen so checkAuthAndNavigate can route after login.
      await SecureStorageService().setString("Screen", screen);
      return;
    }

    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      // ── Cold start ──────────────────────────────────────────────────────
      // The widget tree is not mounted yet. Write the target screen into
      // storage; checkAuthAndNavigate (splash screenFunction) will pick it up
      // and navigate correctly — no race condition, no login redirect.
      await SecureStorageService().setString("Screen", screen);
      coldStartHandled = true;
      return;
    }

    // ── Warm start ──────────────────────────────────────────────────────────
    // App is already running. Navigate immediately.
    navigator.pushReplacementNamed("/home");

    final target = navigatePath(screen);
    if (target is! HomePage) {
      await Future.delayed(const Duration(milliseconds: 200));
      AppNavigator.push(target);
    }

    // ⚡ callApi fires in background — never blocks navigation.
    Future(() {
      try {
        callApi(navigatorKey.currentState!.context);
      } catch (e) {
        appLog("callApi background error: $e");
      }
    });
  }

  // ─── Route helper ────────────────────────────────────────────────────────

  static Widget navigatePath(String navigate) {
    switch (navigate) {
      case "home":
      case "signup":
        return HomePage();
      case "budget":
        return Budget();
      case "calculator":
      case "veg_nonveg":
        return VegNonVegCalculator();
      case "code":
        return ReferralCodeScreen();
      case "coll":
        selectedTab.value = "Collections";
        return TransactionHistoryScreen();
      default:
        return HomePage();
    }
  }

  // ─── Own-code dialog ─────────────────────────────────────────────────────

  static void showSelfReferralDialogIfNeeded(String refCode) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    showDialog(
      context: context,
      builder: (_) => _OwnReferralCodeDialog(refCode: refCode),
    );
  }
}

// ─── Internal payload model ───────────────────────────────────────────────

class _DeepLinkPayload {
  final String? referralCode;
  final String screen;
  const _DeepLinkPayload({required this.referralCode, required this.screen});
}

// ─── Navigator helper ──────────────────────────────────────────────────────

class AppNavigator {
  static Future pushNamed(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);

  static Future pushReplacementNamed(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!
          .pushReplacementNamed(routeName, arguments: arguments);

  static Future push(Widget page) =>
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => page));

  static void pop() => navigatorKey.currentState!.pop();
}

// ─── Own-referral dialog ───────────────────────────────────────────────────

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
              child: const Icon(Icons.link_off_rounded,
                  size: 30, color: Color(0xFF4B4D73)),
            ),
            const SizedBox(height: 18),
            const Text(
              'This is your own referral link',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2230)),
            ),
            const SizedBox(height: 10),
            Text(
              'You opened the app using your own code $refCode. '
              'Share it with a friend to unlock rewards, but it '
              'cannot be applied on your own account.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: Color(0xFF63697A)),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B4D73),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Continue',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
