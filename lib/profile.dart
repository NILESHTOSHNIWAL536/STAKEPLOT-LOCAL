import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/route_user_login.dart';
import 'signInOut/userName.dart';

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

class TrasactionIconImage extends StatelessWidget {
  String url;
  bool flag;
  TrasactionIconImage(
      {Key? key, this.url = "assets/images2/user.svg", this.flag = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
        height: height / 12,
        width: width / 12,
        child: SvgPicture.asset(
          url,
          color: Colorcodes.textColor,
        ));
  }
}

int val = 19;
int val2 = 15;

Color flagdata(bool flag) {
  Color color = flag ? Colorcodes.white : Colorcodes.dropdown;
  return color;
}

Widget upvoteLiked(context, [bool flag = true]) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  return Container(
      width: width / val,
      height: height / val,
      child:
          SvgPicture.asset("assets/svgs/up-voted.svg", color: flagdata(flag)));
}

Widget upvoteLike(context, [bool flag = true]) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return Container(
      width: width / val,
      height: height / val,
      child:
          SvgPicture.asset("assets/svgs/up-vote.svg", color: flagdata(flag)));
}

Widget downvoteLiked(context, [bool flag = true]) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  return Container(
      width: width / val,
      height: height / val,
      child: SvgPicture.asset("assets/svgs/down-voted.svg",
          color: flagdata(flag)));
}

Widget downvoteLike(context, [bool flag = true]) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return Container(
      width: width / val,
      height: height / val,
      child:
          SvgPicture.asset("assets/svgs/down-vote.svg", color: flagdata(flag)));
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
    // ✅ Store your existing valid access token or fetch dynamically if needed
    String accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4Nzg5MTk5YmFmZmIyZDJhZjhiZTE5MyIsImlhdCI6MTc2MTI4NzkwOSwiZXhwIjoxNzY2NDcxOTA5fQ.ZJY6Dvu_3TwaEj1FwUaXJk08GCWiJQMg_ozygssVHKA";
    await pref.setString("accessToken", "Bearer $accessToken");
    return pref.getString("accessToken") ?? "";
 }