import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/auth_service/force_logout.dart';
import 'package:flutter_application_code_stakeplot/auth_service/get_otp.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/loginservices/two_factor_email_verification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/snackBar.dart';
import '../Home_Screen/Home/init_Api_Calls.dart';
import '../backed_connections/apiConnect/signInAndOut.dart';

class LoginService {
  static Future<void> loginUser(TextEditingController emailController,
      TextEditingController passwordController, BuildContext context,
      [bool flag = false]) async {
    try {
      var response =
          await postDataApiCallwithOutSharedPref('${url}/user/login', {
        'email': emailController.text.toString(),
        'userpassword': passwordController.text.toString(),
        'deviceInfo': deviceData,
      });
       if (getFlagOfResponse(response)) {
        Navigator.pushReplacementNamed(context, '/home');
        loginCalledData(response, context);
        await screenDataLocalStorage();
      }
     else  if (response.statusCode == 409) 
      {
        ForceLogout.forceLoginShowModal(context, response, emailController, passwordController);
      } else if (response.statusCode == 500) {
        snackBarCalledfail(context, SnackbarData().serverError, Colors.red);
      } else if (getFlagOfResponse(response)) {
      } else if (response.statusCode == 400) {
        snackBarCalledfail(context,SnackbarData().invalidInfo , Colors.red);
      }  else {
        acceptReset.value = false;
        snackBarCalledfail(context, SnackbarData().invalidCredentials);
      }
    } catch (e) {
      acceptReset.value = false;
      snackBarCalledfail(context, SnackbarData().loginFailedTryAgain);
    }
  }

  static Future<void> userVerification(TextEditingController emailController,
      TextEditingController passwordController, BuildContext context,
      [bool flag = false]) async {
    try {
      var response =
          await postDataApiCallwithOutSharedPref('${url}/user/verify', {
        'email': emailController.text.toString(),
        'userpassword': passwordController.text.toString(),
      });

      var decodedResponse = json.decode(response.body);

      if (response.statusCode == 409) {
        ForceLogout.forceLoginShowModal(context, response, emailController, passwordController);
      } else if (response.statusCode == 500) {
        snackBarCalledfail(context, decodedResponse['message'], Colors.red);
      } else if (getFlagOfResponse(response)) {
        // adding this for two factor auth
        OtpService.getOTPForTwoFactorAuth(context,
            decodedResponse['user']['name'], emailController.text.toString());

        // Navigate to the OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TwoFactorEmailVerification(
              data: {
                'email': emailController.text.toString(),
                'name': emailController.text.toString(),
                'password': passwordController.text.toString(),
                'response': response,
                'isForcedLogin': false
              },
              // Pass the base URL
            ),
          ),
        );
      } else {
        acceptReset.value = false;
        snackBarCalledfail(context, (decodedResponse['message']!=null || decodedResponse['message']!="")? decodedResponse['message']:SnackbarData().invalidCredentials);
      }
    } catch (e)
    {
      acceptReset.value = false;
      snackBarCalledfail(context, SnackbarData().loginFailedTryAgain);
    }
  }

  static void loginCalledData(response, context,{bool flag=false}) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final body = !flag ? json.decode(response.body):response;
    String accessToken = body['data']['accessToken'];
    initGetControllers();
    pref.setString("accessToken", "Bearer " + accessToken);
    await initializeOneSignal(context);
    userController.userId.value = body['data']['_id'];
    isBankAccountLink.value = body['data']['isBankAccountLinked'];
    acceptReset.value = false;
    getPhoneNo(body);
    callApi(context);
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }


  static void getPhoneNo(body) {
    List<dynamic> phoneList = body['data']['phone'] ?? [];
    String phone = "0";
    if (phoneList.isNotEmpty) {
      if (phoneList[0] != "0") {
        phone = phoneList[0];
      } else if (phoneList.length > 1 && phoneList[1] != "0") {
        phone = phoneList[1];
      }
    }
    ControllerManagement.userController.phone.value = phone;
    number.value = phone;
  }
}