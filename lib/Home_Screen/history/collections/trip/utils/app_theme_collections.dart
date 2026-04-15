// ─── utils/app_theme.dart ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AppColorsForCollection {
  static const Color background = Color(0xFFF5F0E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF8F5EF);
  static const Color primaryDark = Color(0xFF2D3142);
  static const Color primaryBlue = Color(0xFF3D4F7C);
  static const Color accentGold = Color(0xFFB8860B);
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFE65100);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B7B);
  static const Color textLight = Color(0xFF9E9EB0);
  static const Color divider = Color(0xFFE8E4DC);
  static const Color tagBg = Color(0xFFEEEBE3);
  static const Color paidBadge = Color(0xFFE8F5E9);
  static const Color pendingBadge = Color(0xFFFFF3E0);
  static const Color splitHighlight = Color(0xFFFFF8E1);
  static const Color leftoverWarning = Color(0xFFFFF3CD);

  static const List<Color> avatarColors = [
    Color(0xFF3D4F7C),
    Color(0xFF7B4F9E),
    Color(0xFF2E7D32),
    Color(0xFF00838F),
    Color(0xFF6D4C41),
    Color(0xFF455A64),
  ];
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColorsForCollection.textPrimary,
    letterSpacing: -0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColorsForCollection.textPrimary,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColorsForCollection.textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColorsForCollection.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColorsForCollection.textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColorsForCollection.textLight,
  );
  static const TextStyle amountLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColorsForCollection.textPrimary,
    letterSpacing: -1,
  );
  static const TextStyle amountMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColorsForCollection.textPrimary,
  );
  static const TextStyle labelBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColorsForCollection.textPrimary,
  );
}

class AppThemeInCollection {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColorsForCollection.background,
        colorScheme: const ColorScheme.light(
          primary: AppColorsForCollection.primaryDark,
          secondary: AppColorsForCollection.primaryBlue,
          surface: AppColorsForCollection.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsForCollection.background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.heading3,
          iconTheme: IconThemeData(color: AppColorsForCollection.textPrimary),
        ),
        cardTheme: CardTheme(
          color: AppColorsForCollection.surface,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColorsForCollection.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColorsForCollection.divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColorsForCollection.primaryBlue, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: AppTextStyles.bodyMedium,
        ),
      );
}
