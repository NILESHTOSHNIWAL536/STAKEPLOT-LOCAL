import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 500;
    if (width > 600) return 450;
    return width * 0.85;
  }

  static double getCardHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.25;
  }

  static double getFontSize(BuildContext context, double baseSize) {
    final scale = MediaQuery.of(context).textScaler.scale(1.0);
    return baseSize * scale;
  }

  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return EdgeInsets.symmetric(
      horizontal: width > 600 ? 12.0 : 8.0,
      vertical: width > 600 ? 10.0 : 8.0,
    );
  }
}