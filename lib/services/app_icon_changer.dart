// import 'package:flutter/services.dart';

// class AppIconChanger {
//   static const _channel = MethodChannel('com.stakeplot.pfa/app_icon');

//   static Future<bool> changeIcon(String alias) async {
//     try {
//       final ok = await _channel.invokeMethod('changeIcon', {
//         "alias": alias,
//       });
//       return ok == true;
//     } catch (e) {
//       return false;
//     }
//   }
// }


import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIconChanger {
  static const MethodChannel _channel = MethodChannel('com.stakeplot.pfa/app_icon');

  static Future<bool> changeIcon(String alias) async {
    // alias must be: IconDefault, Icon1, Icon2, Icon3
    try {
      final bool success = await _channel.invokeMethod('changeIcon', {'alias': alias});
      return success;
    } catch (e) {
      
      return false;
    }
  }

  // Run once on every app start
  static Future<void> setupDefaultIcon() async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool('icon_setup_done') ?? false;

    if (!initialized) {
      await changeIcon('IconDefault');
      await prefs.setBool('icon_setup_done', true);
    }
  }
}



