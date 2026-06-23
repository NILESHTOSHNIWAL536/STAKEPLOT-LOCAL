import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_assets.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_padding_sizes.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';






class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final bottomPadding = Platform.isIOS ? 14.0 : 14.0;

    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        width: double.infinity,
        height: 42 + bottomPadding,
        padding: EdgeInsets.only(
            left: AppSizes.p16,
            right: AppSizes.p16,
            bottom: bottomPadding,
            top: 8),
        decoration: BoxDecoration(
          color: colors.whiteColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                FinvuStrings().poweredByRbi,
                textAlign: TextAlign.center,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 10,
                  color: colors.blackColor,
                ),
              ),
            ),
            SizedBox(width: AppSizes.w8),
            SizedBox(
              width: 70,
              height: 20,
              child: ResponsiveSvg(
                asset: Sign.finvu,
                widthFactor: 16,
                heightFactor: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top-left
    path.moveTo(0, 20);

    // Create curved top edge
    path.quadraticBezierTo(
      size.width / 2,
      -20,
      size.width,
      20,
    );

    // Complete the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
