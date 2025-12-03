import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bp = Platform.isIOS ? 14 : 14;
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: bp ),
      color: AppColors.button,
      height: 30,
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
          // const SizedBox(width: 10,),
          Container(
              width: 70,
              // height: 50,
              child:
                  AvatarProfileImage(url: Sign.finvu, width: 10, height: 10)),
        ],
      ),
    );
  }
}
