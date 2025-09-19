import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/two_factor_email_verification.dart';
import 'package:get/get.dart';
import '../auth_service/get_otp.dart';

class UserLoginedAlready extends StatelessWidget {
  var data;
  TextEditingController email;
  TextEditingController userpassword;

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
          getContainer(
              context,
              body['loggedInDevice'] != ""
                  ? body['loggedInDevice']['device'] ?? ""
                  : ""),
          getContainer(
              context,
              body['loggedInDevice'] != ""
                  ? body['loggedInDevice']['brand'] ?? ""
                  : ""),
          InkWell(
              onTap: () {
                isLoading.value = true;

              OtpService.getOTPForTwoFactorAuth(context, body['user']['name'], email.text.toString());

                // Navigate to the OTP verification screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TwoFactorEmailVerification(
                      data: {
                        'email': email.text.toString(),
                        'password': userpassword.text.toString(),
                        'response': body,
                        'isForcedLogin': true
                      },
                      // Pass the base URL
                    ),
                  ),
                );
              },
              child: Obx(() => isLoading.value
                  ? getspinner(context, 30)
                  : getButton(context, "Logout User")))
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
