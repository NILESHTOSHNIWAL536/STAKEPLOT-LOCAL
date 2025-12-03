import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backed_connections/apiAutomations/secure_storage.dart';
import '../routes/route_user_login.dart';
import '../signInOut/userName.dart';

class ProfileImage extends StatelessWidget {
  String url;
  bool flag;
  ProfileImage(
      {Key? key, this.url = "assets/images2/user.svg", this.flag = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return flag
        ? SvgPicture.asset(
            url,
            color: Colorcodes.textColor,
          )
        : SvgPicture.asset(url);
  }
}

Widget SvgImage(
    {required BuildContext context,
    required String url,
    required double height,
    required double width}) {
  double h = MediaQuery.of(context).size.height;
  double w = MediaQuery.of(context).size.width;
  return Container(
      width: w / width,
      height: h / height,
      child: Center(child: Image.network(url)));
}

void checkIsUserNameValid(String val) async {
  try {
    if (val.length < 5)
      isValidUser.value = false;
    else {
      var response =
          await postDataApiCall("${AuthApiRoutes.validateName}", {"name": val});
      if (getFlagOfResponse(response)) {
        isValidUser.value = true;
      } else {
        isValidUser.value = false;
      }
    }
  } catch (e) {}
}


Future<String> generateAccessToken(String email) async
 {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return SecureStorageService().read("accessToken").toString();
 }