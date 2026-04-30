import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

extension ThemeHelper on BuildContext {
  /// Shorthand for the current theme's semantic color tokens.
  /// Falls back to light tokens if the extension is somehow not registered.
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
