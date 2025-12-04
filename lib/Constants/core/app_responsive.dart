// lib/core/utils/app_responsive.dart

import 'package:flutter/widgets.dart';

class AppResponsive {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Responsive font sizes
  static double fontSize(BuildContext context, double size) {
    double width = screenWidth(context);

    if (width < 400) return size * 0.85; // Small phones
    if (width < 600) return size;        // Regular phones
    if (width < 900) return size * 1.15; // Tablets
    return size * 1.3;                   // Desktop
  }
}
