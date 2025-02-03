import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double fontSize;
  final double height;
  final double width;
  final Widget? icon; // Now accepting a Widget for the icon

  const CustomButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.fontSize = 14.0,
    this.height = 2.04,
    this.width = 5.0,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: Colorcodes.paddingSize * height,
        width: Colorcodes.paddingSize * width,
        decoration: BoxDecoration(
          color: AppColors.button,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) // Only add icon if it's provided
                icon!,
              if (icon != null) // Add some space between icon and text if icon is present
                SizedBox(width: Colorcodes.paddingSize * 0.2),
              Text(
                text,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.normal,
                  fontSize: fontSize,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}