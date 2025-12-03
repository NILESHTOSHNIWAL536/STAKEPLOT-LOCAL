import 'package:flutter/material.dart';
import '../Constants/colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme:const AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      iconTheme:  IconThemeData(color: Color.fromARGB(255, 125, 45, 45)),
      titleTextStyle:  TextStyle(color: AppColors.accentColor, fontSize: 18),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.accentColor),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.accentColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      iconTheme: IconThemeData(color: AppColors.backgroundColor),
      titleTextStyle: TextStyle(color: AppColors.backgroundColor, fontSize: 18),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.backgroundColor),
    ),
  );
}
