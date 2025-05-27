import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

class UserLoginedAlready extends StatelessWidget {
  var data;
  var email;
  var userpassword;
  var isLoading = false.obs;
  UserLoginedAlready(
      {Key? key,
      required this.data,
      required this.email,
      required this.userpassword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var body = jsonDecode(data);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: Column(
        children: [
          Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 4.5,
              child: AvatarProfileImage(
                  url: "assets/icons/lock.svg", width: 10, height: 10)),
          getContainer(context, body['message']),
          getContainer(context, "Device Limit Exceeded"),
          getContainer(context, body['loggedInDevice']!=""? body['loggedInDevice']['device']??"" :""),
          getContainer(context, body['loggedInDevice']!=""? body['loggedInDevice']['brand']??"": ""),

          InkWell(
              onTap: () {
                isLoading.value = true;
              var loggedInDevice = body['loggedInDevice'];
if (loggedInDevice != null && loggedInDevice is Map<String, dynamic>) {
  forceLogoutUser(
    body['existingSessionId'],
    email,
    userpassword,
    context,
    loggedInDevice['deviceId'] ?? "", // Check if deviceId exists and use it
    (loggedInDevice['brand'] ?? "").toString() + " " + (loggedInDevice['device'] ?? "").toString()
  );
} else {
  forceLogoutUser(
    body['existingSessionId'],
    email,
    userpassword,
    context,
    "", // Empty string if loggedInDevice is not a Map or is null
    ""
  );
}
               
               },
              child: Obx(() =>isLoading.value? getspinner(context,30): getButton(context, "Logout User")))
        ],
      ),
    );
  }

  Widget getContainer(context, text) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: MediaQuery.of(context).size.width / 1.1,
        child: textStyle(context: context, text: text, fontsize: 14));
  }
}
