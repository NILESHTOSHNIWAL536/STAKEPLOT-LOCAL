import 'dart:ui';
import 'package:flutter/material.dart';

/// Semantic color tokens for Stakeplot's design system.
/// Access via: `Theme.of(context).extension<AppThemeColors>()!`
/// Or the shorthand: `context.appColors` (from theme_helper.dart)
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  final Color background;       // Scaffold / page background
  final Color surface;          // Slightly elevated surface (cards, tiles)
  final Color surfaceVariant;   // Input fields, icon containers
  final Color appBarBackground;
  final Color bottomBarBackground;
  final Color dialogBackground;

  // ── Text ─────────────────────────────────────────────────────────────────
  final Color onBackground;     // Primary text
  final Color onSurface;        // Text on cards / surface
  final Color secondaryText;    // Muted / secondary text
  final Color hintText;         // Placeholder / hint text
  final Color labelText;        // Small labels, section headers

  // ── Borders & Dividers ───────────────────────────────────────────────────
  final Color border;
  final Color divider;

  // ── Interactive elements ─────────────────────────────────────────────────
  final Color inputBackground;
  final Color iconBackground;   // Rounded icon container background
  final Color selectedChip;     // Chip / tab selected bg
  final Color unselectedChip;   // Chip / tab unselected bg

  // ── Status (unchanged across themes) ────────────────────────────────────
  final Color primary;          // Brand purple-indigo
  final Color primaryLight;     // Lighter primary for dark backgrounds
  final Color debit;            // Expense / debit
  final Color credit;           // Income / credit
  final Color error;            // Error / danger

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.appBarBackground,
    required this.bottomBarBackground,
    required this.dialogBackground,
    required this.onBackground,
    required this.onSurface,
    required this.secondaryText,
    required this.hintText,
    required this.labelText,
    required this.border,
    required this.divider,
    required this.inputBackground,
    required this.iconBackground,
    required this.selectedChip,
    required this.unselectedChip,
    required this.primary,
    required this.primaryLight,
    required this.debit,
    required this.credit,
    required this.error,
  });

  // ── Light theme tokens ───────────────────────────────────────────────────
  static const light = AppThemeColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F4F4),
    surfaceVariant: Color(0xFFF0F0F0),
    appBarBackground: Color(0xFFFFFFFF),
    bottomBarBackground: Color(0xFFFFFFFF),
    dialogBackground: Color(0xFFFFFFFF),

    onBackground: Color(0xFF2A2A2A),
    onSurface: Color(0xFF2A2A2A),
    secondaryText: Color(0xFF6B6B6B),
    hintText: Color(0xFFACACAC),
    labelText: Color(0xFF48484A),

    border: Color(0xFFEBEBEB),
    divider: Color(0xFFEBEBEB),

    inputBackground: Color(0xFFE6EAEB),
    iconBackground: Color(0xFFE6EAEB),
    selectedChip: Color(0xFF4B4D73),
    unselectedChip: Color(0xFFE4E4E4),

    primary: Color(0xFF4B4D73),
    primaryLight: Color(0xFF6E70A8),
    debit: Color(0xFFCF7671),
    credit: Color(0xFF2E7D32),
    error: Color(0xFFEF4444),
  );

  // ── Dark theme tokens ────────────────────────────────────────────────────
  static const dark = AppThemeColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF252525),
    appBarBackground: Color(0xFF161616),
    bottomBarBackground: Color(0xFF161616),
    dialogBackground: Color(0xFF1F1F1F),

    onBackground: Color(0xFFF0F0F0),
    onSurface: Color(0xFFE8E8E8),
    secondaryText: Color(0xFF9E9E9E),
    hintText: Color(0xFF6B6B6B),
    labelText: Color(0xFFB0B0B0),

    border: Color(0xFF2C2C2C),
    divider: Color(0xFF2C2C2C),

    inputBackground: Color(0xFF2A2A2A),
    iconBackground: Color(0xFF2C2C2C),
    selectedChip: Color(0xFF8E91D9),
    unselectedChip: Color(0xFF2C2C2C),

    primary: Color(0xFF8E91D9),
    primaryLight: Color(0xFFB0B3E8),
    debit: Color(0xFFEF8E8A),
    credit: Color(0xFF4CAF50),
    error: Color(0xFFEF5350),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? appBarBackground,
    Color? bottomBarBackground,
    Color? dialogBackground,
    Color? onBackground,
    Color? onSurface,
    Color? secondaryText,
    Color? hintText,
    Color? labelText,
    Color? border,
    Color? divider,
    Color? inputBackground,
    Color? iconBackground,
    Color? selectedChip,
    Color? unselectedChip,
    Color? primary,
    Color? primaryLight,
    Color? debit,
    Color? credit,
    Color? error,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      bottomBarBackground: bottomBarBackground ?? this.bottomBarBackground,
      dialogBackground: dialogBackground ?? this.dialogBackground,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      secondaryText: secondaryText ?? this.secondaryText,
      hintText: hintText ?? this.hintText,
      labelText: labelText ?? this.labelText,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      inputBackground: inputBackground ?? this.inputBackground,
      iconBackground: iconBackground ?? this.iconBackground,
      selectedChip: selectedChip ?? this.selectedChip,
      unselectedChip: unselectedChip ?? this.unselectedChip,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      error: error ?? this.error,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      appBarBackground: Color.lerp(appBarBackground, other.appBarBackground, t)!,
      bottomBarBackground: Color.lerp(bottomBarBackground, other.bottomBarBackground, t)!,
      dialogBackground: Color.lerp(dialogBackground, other.dialogBackground, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      labelText: Color.lerp(labelText, other.labelText, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      iconBackground: Color.lerp(iconBackground, other.iconBackground, t)!,
      selectedChip: Color.lerp(selectedChip, other.selectedChip, t)!,
      unselectedChip: Color.lerp(unselectedChip, other.unselectedChip, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      debit: Color.lerp(debit, other.debit, t)!,
      credit: Color.lerp(credit, other.credit, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
