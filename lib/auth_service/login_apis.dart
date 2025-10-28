import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/auth_service/force_logout.dart';
import 'package:flutter_application_code_stakeplot/auth_service/otp_service.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/loginservices/two_factor_email_verification.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/snackBar.dart';
import '../Home_Screen/Home/init_Api_Calls.dart';
import '../backed_connections/apiConnect/signInAndOut.dart';
import '../backed_connections/googlesignin/credentials.dart';
import '../routers_api.dart';
import '../signInOut/userName.dart';

class LoginService {

  static  Future<void> signUp(
      context, Map<String, dynamic> data, String avatarUrl) async {
    String name = data['name'];
    String email = data['email'];
      updateDeviceData(deviceData);
      final response= await postDataApiCall(RouterApi.signUp, {
         'name': name,
         'email': email,
         'authorizationKey':Credentials.Sign_Up_Key,
         'deviceInfo':deviceData
       });

    try {
      var data2 = jsonDecode(response.body);
      bool boolvar = data2['success'];

      acceptReset.value = false;
      if (!boolvar) {
        snackBarCalledfail(
            context, data2['error']['explanation'], Colors.red);
        return;
      }
      final body = jsonDecode(response.body);

      String accessToken = body['data'];
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      _pref.setString("accessToken", "Bearer " + accessToken);
      clearStack(context);
      Navigator.pushReplacementNamed(context, '/ShareAccountLogin');
    } catch (e) {
      snackBarCalledfail(context, "Server error", Colors.red);
    }
  }
  
  static Future<void> loginUser({
    required TextEditingController emailController,
    required BuildContext context,
    required String otp,
  }) async {
    try {
      updateDeviceData(deviceData);
      var response =
          await postDataApiCallwithOutSharedPref(RouterApi.login, {
        'email': emailController.text.toString(),
        'deviceInfo': deviceData,
        "otp": otp.toString(),
      });
      if (getFlagOfResponse(response)) {
        Navigator.pushReplacementNamed(context, '/home');
        loginCalledData(response, context);
        await screenDataLocalStorage();
      }
      else if (response.statusCode == 500) {
        snackBarCalledfail(context, SnackbarData().serverError, Colors.red);
      } else if (response.statusCode == 400) {
        snackBarCalledfail(context, SnackbarData().invalidInfo, Colors.red);
      } else {
        snackBarCalledfail(context, SnackbarData().invalidCredentials);
      }
    } catch (e) {
      snackBarCalledfail(context, SnackbarData().loginFailedTryAgain);
    }
    acceptReset.value = false;
  }

  static Future<void> userVerification(
    TextEditingController emailController,
    BuildContext context,
  ) async {
    try {
      var response =
          await postDataApiCallwithOutSharedPref(RouterApi.verify, {
        'email': emailController.text.toString(),
        // 'userpassword': emailController.text.toString(),
      });

      var decodedResponse = json.decode(response.body);
      print(decodedResponse);
      if (response.statusCode == 409) {
        ForceLogout.forceLoginShowModal(
            context, decodedResponse, emailController);
      } else if (response.statusCode == 400) {
        snackBarCalledfail(context, decodedResponse['error'], Colors.red);
        acceptReset.value = false;
        OtpService.getOTPForTwoFactorAuth(
            context, "MoneyMosaic", emailController.text.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TwoFactorEmailVerification(
              data: {
                'email': emailController.text.toString(),
                'name': emailController.text.toString(),
                'response': response,
                'isForcedLogin': false,
                'newUser': true
              },
            ),
          ),
        );
      } else if (getFlagOfResponse(response)) {
        // adding this for two factor auth
        acceptReset.value = false;
        OtpService.getOTPForTwoFactorAuth(context,
            decodedResponse['data']['name'], emailController.text.toString());

        // Navigate to the OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TwoFactorEmailVerification(
              data: {
                'email': emailController.text.toString(),
                'name': emailController.text.toString(),
                'response': response,
                'isForcedLogin': false,
                'newUser': false
              },
            ),
          ),
        );
      } else {
        snackBarCalledfail(
            context,
            (decodedResponse['message'] != null ||
                    decodedResponse['message'] != "")
                ? decodedResponse['message']
                : SnackbarData().invalidCredentials);
      }
    } catch (e) {
      snackBarCalledfail(context, SnackbarData().loginFailedTryAgain);
    }
    acceptReset.value = false;
  }

  static void pushToRegister(context, email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => UserDetailsPage(data: {
                "data": {"name": "", "dob": "",'email':email}
              })),
    );
  }

  static void loginCalledData(response, context, {bool flag = false}) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final body = !flag ? json.decode(response.body) : response;
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

void updateDeviceData(RxMap deviceData) {
  deviceData['deviceId'] =
      (deviceData['deviceId']?.toString().trim().isNotEmpty ?? false)
          ? deviceData['deviceId'].toString()
          : 'UNKNOWN_DEVICE_ID';

  deviceData['brand'] =
      (deviceData['brand']?.toString().trim().isNotEmpty ?? false)
          ? deviceData['brand'].toString()
          : 'UNKNOWN_BRAND';

  deviceData['device'] =
      (deviceData['device']?.toString().trim().isNotEmpty ?? false)
          ? deviceData['device'].toString()
          : 'UNKNOWN_DEVICE';

  deviceData['model'] =
      (deviceData['model']?.toString().trim().isNotEmpty ?? false)
          ? deviceData['model'].toString()
          : 'UNKNOWN_MODEL';

  deviceData['os'] = (deviceData['os']?.toString().trim().isNotEmpty ?? false)
      ? deviceData['os'].toString()
      : 'UNKNOWN_OS';
}
