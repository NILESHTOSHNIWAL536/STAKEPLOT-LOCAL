import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/navigateTo.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';

import 'budget/create_budget_screen.dart';

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

  void _handle(
      Uri uri, Function(String token) onReferral, BuildContext context) {
    consolelog("🌐 Full URL: ${uri.toString()}");

    final segments = uri.pathSegments;

    appLog("📂 Segments: $segments");

    // ❌ no segments
    if (segments.isEmpty) {
      appLog("❌ No path found");
      return;
    }

    // 🎯 FIRST SEGMENT (route)
    String route = segments[0];

    // 🎯 LAST SEGMENT (token)
    String token = segments.last;

    appLog("🧭 Route: $route");
    appLog("🎯 Token: $token");

    // 🚀 NAVIGATION HANDLING
    switch (route) {
      case "budget":
        AppNavigator.push(context, CreateBudgetScreen());
        break;

      case "ref":
        onReferral(token);
        break;

      default:
        appLog("⚠️ Unknown route");
    }

    // 🔥 EXTRA DEBUG
    appLog("🔗 Scheme: ${uri.scheme}");
    appLog("🌍 Host: ${uri.host}");
    appLog("📍 Path: ${uri.path}");
    appLog("❓ Query Params: ${uri.queryParameters}");
  }

  void dispose() {
    _sub?.cancel();
  }
}


  void handleDeepLink(contextp) {
    appLog("🚀 DeepLink init called");
    DeepLinkService().init((token) {
      appLog("🚀 Token: $token");
    },contextp);
  }