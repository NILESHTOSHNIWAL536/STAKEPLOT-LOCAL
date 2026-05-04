import 'package:flutter/material.dart';

import '../theme_helper.dart';

class CustomStyledContainer extends StatelessWidget {
  /// The child widget to be placed inside the container.
  final Widget child;

  /// The radius for the border corners. Defaults to 8.0.
  final double radius;

  /// The color of the shadow. Defaults to black with 6% opacity.
  final Color shadowColor;

  /// The blur radius for the box shadow. Defaults to 25.0.
  final double blurRadius;

  /// Optional padding for the content inside the container.
  final EdgeInsetsGeometry? padding;

  /// Optional width for the container.
  final double? width;

  /// Optional height for the container.
  final double? height;

  const CustomStyledContainer({
    super.key,
    required this.child,
    this.radius = 8.0, // Default radius: 8px
    this.shadowColor = const Color(
        0x0F000000), // Default shadow color: black with 0.06 opacity
    this.blurRadius = 25.0, // Default blur: 25px
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(radius), // radius: passed variable
        boxShadow: [
          BoxShadow(
            color: colors.onBackground.withOpacity(0.08),
            offset: Offset(4, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: child,
    );
  }
}
