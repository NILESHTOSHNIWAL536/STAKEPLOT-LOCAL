import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/signInOut/userName.dart';
import 'package:get/get.dart';
import '../Constants/app_styles.dart';
import '../Constants/colors.dart';
import '../Constants/booleanFlag.dart';
import '../repository/auth_service/login_apis.dart';
import '../image_service/avatarProfile.dart';
import '../backed_connections/googlesignin/google.dart';
import '../Constants/loader.dart';

Widget containerIconSiginWith(IconData icon, Color color, context) {
    return InkWell(
      onTap: () async {
        if (googleSignInBool.value) return; // Prevent multiple clicks
        googleSignInBool.value = true; // Set loading state
        try {
          final userdata = await AuthService().signInWithGoogle(context);
          if (userdata != null && userdata['data']['accessToken'] != null) {
            LoginService.loginCalledData(userdata, context, flag: true);
          } else if (userdata != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserDetailsPage(data: userdata)),
            );
          } else {}
        } finally {
          googleSignInBool.value = false; // Reset loading state
        }
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width / 5,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Obx(
          () => googleSignInBool.value
              ? Spinner(size: 30) // Show spinner when loading
              : AvatarProfileImage(
                  url: Sign.googleIcon,
                  width: 40,
                  height: 30,
                ), // Show icon when not loading
        ),
      ),
    );
  }