import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';

import 'core/app_padding_sizes.dart';

class DecoratedContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  //final double elevation;
  //final BoxShadow? boxShadow;
  final double minWidth;
  final double minHeight;

  const DecoratedContainer({
    Key? key,
    required this.child, // The content inside the container
    this.backgroundColor = AppColors.button,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(AppSizes.p8),
    //this.elevation = 2.0,
    //this.boxShadow,
    this.minWidth = 10.0, // Default minimum width
    this.minHeight = 10.0, // Optional height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(borderRadius),
      color: backgroundColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          minHeight: minHeight,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
