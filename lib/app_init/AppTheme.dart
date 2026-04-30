import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Constants/colors.dart';
import '../Constants/app_theme_colors.dart';

class AppTheme {
  static const _primary = AppColors.primaryColor;       // #4B4D73
  static const _primaryDark = Color(0xFF8E91D9);         // lighter for dark bg
  static const _fontFamily = 'Roboto';

  // ── Light Theme ───────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,
    fontFamily: _fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: const Color(0xFF6E70A8),
      background: AppThemeColors.light.background,
      surface: AppThemeColors.light.surface,
      onBackground: AppThemeColors.light.onBackground,
      onSurface: AppThemeColors.light.onSurface,
      error: AppThemeColors.light.error,
    ),

    scaffoldBackgroundColor: AppThemeColors.light.background,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppThemeColors.light.appBarBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppThemeColors.light.onBackground),
      actionsIconTheme: IconThemeData(color: AppThemeColors.light.onBackground),
      titleTextStyle: TextStyle(
        color: AppThemeColors.light.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    // Bottom navigation / app bar
    bottomAppBarTheme: BottomAppBarTheme(
      color: AppThemeColors.light.bottomBarBackground,
      elevation: 0,
    ),

    // Card
    cardTheme: CardTheme(
      color: AppThemeColors.light.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppThemeColors.light.border, width: 1),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppThemeColors.light.divider,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: AppThemeColors.light.dialogBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        color: AppThemeColors.light.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
      ),
      contentTextStyle: TextStyle(
        color: AppThemeColors.light.secondaryText,
        fontSize: 14,
        fontFamily: _fontFamily,
      ),
    ),

    // Text
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily),
      displayMedium: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily),
      displaySmall: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily),
      headlineLarge: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily),
      bodyMedium: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily),
      bodySmall: TextStyle(color: AppThemeColors.light.secondaryText, fontFamily: _fontFamily),
      labelLarge: TextStyle(color: AppThemeColors.light.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: AppThemeColors.light.secondaryText, fontFamily: _fontFamily),
      labelSmall: TextStyle(color: AppThemeColors.light.hintText, fontFamily: _fontFamily),
    ),

    // Icons
    iconTheme: IconThemeData(color: AppThemeColors.light.onBackground),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeColors.light.inputBackground,
      hintStyle: TextStyle(color: AppThemeColors.light.hintText, fontSize: 14),
      labelStyle: TextStyle(color: AppThemeColors.light.secondaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppThemeColors.light.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppThemeColors.light.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppThemeColors.light.error),
      ),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: _fontFamily),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: _fontFamily),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primary,
        side: BorderSide(color: _primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // List tile
    listTileTheme: ListTileThemeData(
      textColor: AppThemeColors.light.onBackground,
      iconColor: AppThemeColors.light.onBackground,
      tileColor: Colors.transparent,
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? _primary : Colors.transparent,
      ),
      side: BorderSide(color: AppThemeColors.light.border),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? _primary : Colors.grey.shade400,
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? _primary.withOpacity(0.4) : Colors.grey.shade300,
      ),
    ),

    // Bottom sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppThemeColors.light.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Snack bar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppThemeColors.light.surface,
      contentTextStyle: TextStyle(color: AppThemeColors.light.onBackground),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    // Extensions
    extensions: const [AppThemeColors.light],
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    fontFamily: _fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryDark,
      brightness: Brightness.dark,
      primary: _primaryDark,
      onPrimary: Colors.white,
      secondary: const Color(0xFFB0B3E8),
      background: AppThemeColors.dark.background,
      surface: AppThemeColors.dark.surface,
      onBackground: AppThemeColors.dark.onBackground,
      onSurface: AppThemeColors.dark.onSurface,
      error: AppThemeColors.dark.error,
    ),

    scaffoldBackgroundColor: AppThemeColors.dark.background,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppThemeColors.dark.appBarBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppThemeColors.dark.onBackground),
      actionsIconTheme: IconThemeData(color: AppThemeColors.dark.onBackground),
      titleTextStyle: TextStyle(
        color: AppThemeColors.dark.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Bottom navigation / app bar
    bottomAppBarTheme: BottomAppBarTheme(
      color: AppThemeColors.dark.bottomBarBackground,
      elevation: 0,
    ),

    // Card
    cardTheme: CardTheme(
      color: AppThemeColors.dark.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppThemeColors.dark.border, width: 1),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppThemeColors.dark.divider,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: AppThemeColors.dark.dialogBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        color: AppThemeColors.dark.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
      ),
      contentTextStyle: TextStyle(
        color: AppThemeColors.dark.secondaryText,
        fontSize: 14,
        fontFamily: _fontFamily,
      ),
    ),

    // Text
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily),
      displayMedium: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily),
      displaySmall: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily),
      headlineLarge: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily),
      bodyMedium: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily),
      bodySmall: TextStyle(color: AppThemeColors.dark.secondaryText, fontFamily: _fontFamily),
      labelLarge: TextStyle(color: AppThemeColors.dark.onBackground, fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: AppThemeColors.dark.secondaryText, fontFamily: _fontFamily),
      labelSmall: TextStyle(color: AppThemeColors.dark.hintText, fontFamily: _fontFamily),
    ),

    // Icons
    iconTheme: IconThemeData(color: AppThemeColors.dark.onBackground),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeColors.dark.inputBackground,
      hintStyle: TextStyle(color: AppThemeColors.dark.hintText, fontSize: 14),
      labelStyle: TextStyle(color: AppThemeColors.dark.secondaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppThemeColors.dark.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppThemeColors.dark.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primaryDark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppThemeColors.dark.error),
      ),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: _fontFamily),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: _fontFamily),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        side: BorderSide(color: _primaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // List tile
    listTileTheme: ListTileThemeData(
      textColor: AppThemeColors.dark.onBackground,
      iconColor: AppThemeColors.dark.onBackground,
      tileColor: Colors.transparent,
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? _primaryDark : Colors.transparent,
      ),
      side: BorderSide(color: AppThemeColors.dark.border),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? _primaryDark : Colors.grey.shade600,
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? _primaryDark.withOpacity(0.4) : const Color(0xFF3A3A3A),
      ),
    ),

    // Bottom sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppThemeColors.dark.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Snack bar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppThemeColors.dark.surfaceVariant,
      contentTextStyle: TextStyle(color: AppThemeColors.dark.onBackground),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    // Extensions
    extensions: const [AppThemeColors.dark],
  );
}
