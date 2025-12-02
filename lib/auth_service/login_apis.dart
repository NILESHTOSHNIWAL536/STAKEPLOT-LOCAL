import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/auth_service/force_logout.dart';
import 'package:flutter_application_code_stakeplot/auth_service/otp_service.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/loginservices/two_factor_email_verification.dart';
import 'package:get/get.dart';
import '../../Utils/snackBar.dart';
import '../Home_Screen/Home/init_Api_Calls.dart';
import '../backed_connections/apiAutomations/secure_storage.dart';
import '../backed_connections/apiConnect/signInAndOut.dart';
import '../backed_connections/googlesignin/credentials.dart';
import '../routes/route_user_login.dart';
import '../signInOut/userName.dart';

class LoginService {
  static Future<void> signUp(
      context, Map<String, dynamic> data, String avatarUrl) async {
    String name = data['name'];
    String email = data['email'];
    updateDeviceData(deviceData);
    final response = await postDataApiCall(AuthApiRoutes.signUp, {
      'name': name,
      'email': email,
      'authorizationKey': Credentials.Sign_Up_Key,
      'deviceInfo': deviceData
    });

    try {
      var data2 = jsonDecode(response.body);
      bool boolvar = data2['success'];

      acceptReset.value = false;
      if (!boolvar) {
        snackBarCalledfail(
          context,
          data2['error']['explanation'],
        );
        return;
      }
      final body = jsonDecode(response.body);

      String accessToken = body['data'];
      await SecureStorageService()
          .setString("accessToken", "Bearer " + accessToken);
      clearStack(context);
      Navigator.pushReplacementNamed(context, '/ShareAccountLogin');
    } catch (e) {
      snackBarCalledfail(
        context,
        "Server error",
      );
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
          await postDataApiCallwithOutSharedPref(AuthApiRoutes.login, {
        'email': emailController.text.toString(),
        'deviceInfo': deviceData,
        "otp": otp.toString(),
      });
      if (getFlagOfResponse(response)) {
        loginCalledData(response, context);
        await screenDataLocalStorage();
      } else if (response.statusCode == 500) {
        snackBarCalledfail(
          context,
          SnackbarData().serverError,
        );
      } else if (response.statusCode == 400) {
        snackBarCalledfail(context, SnackbarData().invalidInfo);
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
          await postDataApiCallwithOutSharedPref(AuthApiRoutes.verify, {
        'email': emailController.text.toString(),
      });

      appLog("response: ${response.body}");
      appLog("Verification Response: ${AuthApiRoutes.verify}");
      var decodedResponse = json.decode(response.body);
      if (response.statusCode == 409) {
        ForceLogout.forceLoginShowModal(
            context, decodedResponse, emailController);
      } else if (response.statusCode == 400) {
        snackBarCalledfail(context, decodedResponse['error']);
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
      // snackBarCalledfail(context, SnackbarData().loginFailedTryAgain);
      if (!context.mounted) return;
      String message = "Something went wrong. Please try again.";
      if (e is TimeoutException) {
        message = "Request timed out. Check your network or server.";
      } else if (e.toString().contains("No route to host")) {
        message = "Cannot reach server. Check WiFi/mobile network.";
      } else if (e.toString().contains("SocketException")) {
        message = "Network error. Please check your connection.";
      }
      snackBarCalledfail(context, message);
    }
    acceptReset.value = false;
  }

  static void pushToRegister(context, email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => UserDetailsPage(data: {
                "data": {"name": "", "dob": "", 'email': email}
              })),
    );
  }

  static Future<void> loginCalledData(response, context,
      {bool flag = false}) async {
    final body = !flag ? json.decode(response.body) : response;

    // 1️⃣ Save token (must await)
    String accessToken = body['data']['accessToken'];
    await SecureStorageService()
        .setString("accessToken", "Bearer $accessToken");

    // 2️⃣ Init controllers
    initGetControllers();

    // 3️⃣ Initialize OneSignal in background (slow → don't block)
    unawaited(initializeOneSignal(context));

    // 4️⃣ Update values instantly
    userController.userId.value = body['data']['_id'];
    isBankAccountLink.value = body['data']['isBankAccountLinked'];
    acceptReset.value = false;
    unawaited(getPhoneNo(body));

    // 5️⃣ Fetch minimal required data (DO NOT WAIT)
    (userController.fetchUserInfo());
    getBankAccounts(); // ← removed await
    unawaited(callApi(context)); // ← removed await

    // 6️⃣ Navigate instantly
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (_) => false,
    );
  }

  static Future<void> loginCalledData2(response, context,
      {bool flag = false}) async {
    final body = !flag ? json.decode(response.body) : response;
    String accessToken = body['data']['accessToken'];
    initGetControllers();
    await SecureStorageService()
        .setString("accessToken", "Bearer " + accessToken);
    await initializeOneSignal(context);
    userController.userId.value = body['data']['_id'];
    isBankAccountLink.value = body['data']['isBankAccountLinked'];
    acceptReset.value = false;
    getPhoneNo(body);
    userController.fetchUserInfo();
    await getBankAccounts();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    await callApi(context);
  }

  static Future<void> getPhoneNo(body) async {
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
