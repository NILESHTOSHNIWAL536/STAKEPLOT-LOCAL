import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleLightDarkTheme() {
    changeTheme(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  void changeTheme(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', mode.toString());
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('themeMode');
    if (savedMode != null) {
      switch (savedMode) {
        case 'ThemeMode.dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'ThemeMode.light':
          themeMode.value = ThemeMode.light;
          break;
        default:
          themeMode.value = ThemeMode.system;
      }
    }
  }
}
