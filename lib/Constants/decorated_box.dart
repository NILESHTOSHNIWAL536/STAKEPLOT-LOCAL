import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

class DecoratedContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  //final double elevation;
  //final BoxShadow? boxShadow;
  final double? width;
  final double? height;

  const DecoratedContainer({
    Key? key,
    required this.child, // The content inside the container
    this.backgroundColor = AppColors.bg,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(8.0),
    //this.elevation = 2.0,
    //this.boxShadow,
    this.width, // Optional width
    this.height, // Optional height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      //elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      color: backgroundColor,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          // boxShadow: boxShadow != null
          //     ? [boxShadow!]
          //     : [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 4.0,
          //           offset: const Offset(0, 2),
          //         ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
