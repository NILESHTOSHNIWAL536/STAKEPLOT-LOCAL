import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';

import '../Constants/core/app_padding_sizes.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bp = Platform.isIOS ? 14 : 14;

    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60, // slightly taller for curve
        padding: EdgeInsets.only(bottom: bp),
        color: AppColors.button,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              FinvuStrings().poweredByRbi,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: 9,
                color: AppColors.bottomBarColor,
              ),
            ),
            SizedBox(width: AppSizes.w6),
            SizedBox(
              width: 70,
              child: AvatarProfileImage(
                url: Sign.finvu,
                width: 10,
                height: 10,
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
    Path path = Path();

    // start from bottom-left
    path.lineTo(0, 20);

    // curve
    path.quadraticBezierTo(
      size.width / 2,
      -20, // height of curve (adjust this)
      size.width,
      20,
    );

    // right side down
    path.lineTo(size.width, size.height);

    // bottom line
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
