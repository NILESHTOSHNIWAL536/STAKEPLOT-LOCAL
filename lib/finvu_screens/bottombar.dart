import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';


class BottomBar extends StatelessWidget {
const BottomBar({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
       width: MediaQuery.of(context).size.width,
       color:AppColors.button,
       height: 30,
       child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                Text("Powered by RBI-Regulated AA",style:  FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 9,
                                  color: AppColors.bottomBarColor,
                                ),),
                // const SizedBox(width: 10,),
                 Container(
                  width: 70,
                  // height: 50,
                  child: AvatarProfileImage(url:Sign.finvu, width: 10, height: 10)),
          ],
       ),
    );
  }
}