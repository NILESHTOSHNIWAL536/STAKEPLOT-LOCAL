import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/model/app_icon_option.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIconChanger {
  static const MethodChannel _channel =
      MethodChannel('com.stakeplot.pfa/app_icon');
  static const String _selectedIconKey = 'selected_app_icon_alias';

  static Future<bool> changeIcon(String alias) async {
    if (!AppIconOptions.isAllowedAlias(alias)) return false;

    try {
      final bool success =
          await _channel.invokeMethod('changeIcon', {'alias': alias});

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_selectedIconKey, alias);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  static Future<String> selectedIconAlias() async {
    final prefs = await SharedPreferences.getInstance();
    final alias = prefs.getString(_selectedIconKey);

    if (alias != null && AppIconOptions.isAllowedAlias(alias)) {
      return alias;
    }

    return AppIconOptions.defaultAlias;
  }

  // Run once on every app start
  static Future<void> setupDefaultIcon() async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool('icon_setup_done') ?? false;

    if (!initialized) {
      await changeIcon(AppIconOptions.defaultAlias);
      await prefs.setBool('icon_setup_done', true);
    }
  }
}
