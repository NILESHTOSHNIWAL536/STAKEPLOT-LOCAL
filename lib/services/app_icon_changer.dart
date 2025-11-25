import 'package:flutter/services.dart';

class AppIconChanger {
  static const _channel = MethodChannel('com.stakeplot.pfa/app_icon');

  static Future<bool> changeIcon(String alias) async {
    try {
      final ok = await _channel.invokeMethod('changeIcon', {
        "alias": alias,
      });
      return ok == true;
    } catch (e) {
      print("Error changing icon: $e");
      return false;
    }
  }
}
