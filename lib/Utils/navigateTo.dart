import 'package:flutter/material.dart';

class AppNavigator {
  /// 🔹 Push (normal navigation)
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// 🔹 Push Replacement (remove current screen)
  static Future<T?> pushReplacement<T>(BuildContext context, Widget screen) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// 🔹 Push and Remove Until (clear stack)
  static Future<T?> pushAndRemoveUntil<T>(
      BuildContext context, Widget screen) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  /// 🔹 Named Push
  static Future<T?> pushNamed<T>(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// 🔹 Named Replacement
  static Future<T?> pushReplacementNamed<T>(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// 🔹 Pop (go back)
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  /// 🔹 Pop Until (go back to specific route)
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// 🔹 Maybe Pop (safe pop)
  static Future<bool> maybePop(BuildContext context) {
    return Navigator.maybePop(context);
  }
}