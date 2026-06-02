import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'Home_Screen/Home/init_Api_Calls.dart';

import 'main.dart';

class DeepLinkService {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  Future<void> init(
      Function(String token) onReferral, BuildContext context) async {
    _appLinks = AppLinks();

    // ✅ OLD VERSION METHOD
    final Uri? initialUri = await _appLinks.getInitialLink();

    if (initialUri != null) {
      appLog("🔥 Initial Link: $initialUri");
      _handle(initialUri, onReferral, context);
    }

    _sub = _appLinks.uriLinkStream.listen((uri) {
      appLog("🔥 Stream Link: $uri");
      _handle(uri, onReferral, context);
    });
  }

  // void _handle(
  //     Uri uri, Function(String token) onReferral, BuildContext context) {
  //   consolelog("🌐 Full URL: ${uri.toString()}");

  //   final segments = uri.pathSegments;

  //   appLog("📂 Segments: $segments");

  //   // ❌ no segments
  //   if (segments.isEmpty) {
  //     appLog("❌ No path found");
  //     return;
  //   }

  //   // 🎯 FIRST SEGMENT (route)
  //   String route = segments[0];

  //   // 🎯 LAST SEGMENT (token)
  //   String token = segments.last;

  //   appLog("🧭 Route: $route");
  //   appLog("🎯 Token: $token");

  //   // 🚀 NAVIGATION HANDLING
  //   switch (route) {
  //     case "home":
  //       AppNavigator.pushReplacementNamed("/home");
  //       break;

  //     case "ref":
  //       onReferral(token);
  //       break;

  //     default:
  //       appLog("⚠️ Unknown route");
  //   }

  //   // 🔥 EXTRA DEBUG
  //   appLog("🔗 Scheme: ${uri.scheme}");
  //   appLog("🌍 Host: ${uri.host}");
  //   appLog("📍 Path: ${uri.path}");
  //   appLog("❓ Query Params: ${uri.queryParameters}");
  // }

  void _handle(
    Uri uri,
    Function(String token) onReferral,
    BuildContext context,
  ) async {
    consolelog("🌐 Full URL: ${uri.toString()}");

    appLog("🔗 Scheme: ${uri.scheme}");
    appLog("🌍 Host: ${uri.host}");
    appLog("📍 Path: ${uri.path}");
    appLog("❓ Query Params: ${uri.queryParameters}");

    // ✅ Extract from query params
    final refCode =
        uri.queryParameters['ref'] ?? uri.queryParameters['deep_link_sub1'];

    final screen = uri.queryParameters['path'] ??
        uri.queryParameters['deep_link_value'] ??
        "signup";

    appLog("🎯 RefCode: $refCode");
    appLog("🧭 Screen: $screen");

    // if (refCode != null && refCode.trim().isNotEmpty) {
    //   await AppsflyerService.handleReferralNavigation(
    //     refCode: refCode,
    //     screen: screen,
    //     source: 'app_link',
    //   );
      // callApi(context);
    // } else {
    //   appLog("❌ No referral found");
    // }
  }

  void _handle2(
      Uri uri, Function(String token) onReferral, BuildContext context) {
    consolelog("🌐 Full URL: ${uri.toString()}");
    callApi(context);
    final segments = uri.pathSegments;

    appLog("📂 Segments: $segments");

    if (segments.length < 2) {
      appLog("❌ Invalid path");
      return;
    }

    // 🔥 FIXED
    String route = segments[1];
    String token = segments.length > 2 ? segments[2] : "";

    appLog("🧭 Route: $route");
    appLog("🎯 Token: $token");

    // switch (route) {
    //   case "home":
    //     AppNavigator.pushReplacementNamed("/home");
    //     break;

    //   case "ref":
    //     onReferral(token);
    //     break;

    //   default:
    //     appLog("⚠️ Unknown route");
    // }

    appLog("🔗 Scheme: ${uri.scheme}");
    appLog("🌍 Host: ${uri.host}");
    appLog("📍 Path: ${uri.path}");
    appLog("❓ Query Params: ${uri.queryParameters}");
  }

  void dispose() {
    _sub?.cancel();
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

void handleDeepLink(contextp) {
  appLog("🚀 DeepLink init called");
  DeepLinkService().init((token) {
    appLog("🚀 Token: $token");
  }, contextp);
}
