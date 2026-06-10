import 'dart:ui';
import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color backgroundColor;
  final Color whiteColor;
  final Color secondaryText;
  final Color bottomText;
  final Color cardBackground;
  final Color blackColor;
  final Color iconFillColor;

  const AppPalette({
    required this.backgroundColor,
    required this.whiteColor,
    required this.secondaryText,
    required this.bottomText,
    required this.cardBackground,
    required this.blackColor,
    required this.iconFillColor,
  });

  // ── Light Theme ─────────────────────────────
  static const light = AppPalette(
    backgroundColor: Color(0xFFF2F9FC),
    whiteColor: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFEDF6F7),
    bottomText: Color(0xFFB8D7D6),
    cardBackground: Color(0xFFA9CDD2),
    blackColor: Color(0xFF1B2135),
    iconFillColor: Color(0xFFA9CDD2),
  );

  // ── Dark Theme ──────────────────────────────
  static const dark = AppPalette(
    backgroundColor: Color(0xFF1B2135),
    whiteColor: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFEDF6F7),
    bottomText: Color(0xFFB8D7D6),
    cardBackground: Color(0xFF2A344D),
    blackColor: Color(0xFFF2F9FC),
    iconFillColor: Color(0xFF2A344D),
  );

  @override
  AppPalette copyWith({
    Color? backgroundColor,
    Color? whiteColor,
    Color? secondaryText,
    Color? bottomText,
    Color? cardBackground,
    Color? blackColor,
    Color? iconFillColor,
  }) {
    return AppPalette(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      whiteColor: whiteColor ?? this.whiteColor,
      secondaryText: secondaryText ?? this.secondaryText,
      bottomText: bottomText ?? this.bottomText,
      cardBackground: cardBackground ?? this.cardBackground,
      blackColor: blackColor ?? this.blackColor,
      iconFillColor: iconFillColor ?? this.iconFillColor,
    );
  }

  @override
  ThemeExtension<AppPalette> lerp(
    covariant ThemeExtension<AppPalette>? other,
    double t,
  ) {
    if (other is! AppPalette) return this;

    return AppPalette(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t)!,
      whiteColor: Color.lerp(whiteColor, other.whiteColor, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      bottomText: Color.lerp(bottomText, other.bottomText, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      blackColor: Color.lerp(blackColor, other.blackColor, t)!,
      iconFillColor: Color.lerp(iconFillColor, other.iconFillColor, t)!,
    );
  }
}
