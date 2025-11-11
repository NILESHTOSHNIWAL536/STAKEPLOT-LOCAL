import 'dart:convert';
import 'package:flutter/services.dart';

class WidgetBridge {
  static const _channel = MethodChannel('com.stakeplot.pfa/navigation');

  /// Returns the raw JSON string of last widget selection (e.g. '["Alice","Bob"]')
  static Future<String?> getLastWidgetSelection() async {
    try {
      final res = await _channel.invokeMethod('getLastWidgetSelection');
      if (res == null) return null;
      return res as String;
    } on PlatformException {
      return null;
    }
  }

  /// Convenience: returns parsed List<String> of selected names (or empty list)
  static Future<List<String>> getLastWidgetSelectionList() async {
    try {
      final jsonStr = await getLastWidgetSelection();
      if (jsonStr == null) return <String>[];
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
      return <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  /// Send up to first 4 friend names to the Android widget.
  /// Accepts a List<String> (we truncate to 4).
  static Future<bool> setWidgetFriends(List<String> names) async {
    try {
      final truncated = names.take(4).toList();
      // We pass a List to Android; MainActivity handles converting to JSON.
      final res = await _channel.invokeMethod('setWidgetFriends', truncated);
      return res == true;
    } on PlatformException {
      return false;
    }
  }

  /// Keep your existing handler wiring for incoming calls from Android
  static void setMethodCallHandler(void Function(Map<dynamic, dynamic>) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'navigateToTab' || call.method == 'widgetClicked' || call.method == 'navigateToFinance') {
        final args = call.arguments;
        if (args is Map) handler(args);
        else handler({'value': args});
      }
      return null;
    });
  }
}
