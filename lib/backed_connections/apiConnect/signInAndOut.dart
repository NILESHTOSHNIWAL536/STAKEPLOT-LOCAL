import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/animated/userLoginedAlready.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/signInOut/resetPas.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/signin.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/two_factor_email_verification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/snackBar.dart';

Future<void> loginUser(TextEditingController emailController,
    TextEditingController passwordController, BuildContext context,
    [bool flag = false]) async {
  try {
    var response = await postDataApiCallwithOutSharedPref('${url}/user/login', {
      'email': emailController.text.toString(),
      'userpassword': passwordController.text.toString(),
      'deviceInfo': deviceData,
    });
    if (response.statusCode == 409) {
      forceLoginShowModal(
          context, response, emailController, passwordController);
    } else if (response.statusCode == 500) {
      snackBarCalledfail(context, SnackbarData().serverError, Colors.red);
    } else if (getFlagOfResponse(response)) {
      loginCalledData(response, context);
      await screenDataLocalStorage();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      acceptReset.value = false;
      snackBarCalledfail(context, SnackbarData().invalidCredentials);
    }
  } catch (e, stackTrace) {
    acceptReset.value = false;
    snackBarCalledfail(context, SnackbarData().loginFailedTryAgain);
  }
}

Future<void> userVerification(TextEditingController emailController,
    TextEditingController passwordController, BuildContext context,
    [bool flag = false]) async {
  try {
    var response = await postDataApiCallwithOutSharedPref('${url}/user/verify', {
      'email': emailController.text.toString(),
      'userpassword': passwordController.text.toString(),
    });

    var decodedResponse = json.decode(response.body);
    

    if (response.statusCode == 409) {
      forceLoginShowModal(
          context, response, emailController, passwordController);
    } else if (response.statusCode == 500) {
      snackBarCalledfail(context, decodedResponse['message'], Colors.red);
    } else if (getFlagOfResponse(response)) {
      // adding this for two factor auth
      getOTPForTwoFactorAuth(context, decodedResponse['user']['name'],
          emailController.text.toString());

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
      snackBarCalledfail(context, SnackbarData().invalidCredentials);
    }
  } catch (e) {
    acceptReset.value = false;
    snackBarCalledfail(context, SnackbarData().loginFailedTryAgain);
  }
}

void verifyOTPForLogin2(context, email, otp, name) async {
  var response =
      await postDataApiCallwithOutSharedPref('${url}/otp/verify-otp', {
    'email': email,
    "otp": otp.toString(),
  });

  if (getFlagOfResponse(response)) {
    snackBarCalled(context, SnackbarData().otpAccepted, Colors.black);
    acceptReset.value = false;
  } else {
    acceptReset.value = false;
    snackBarCalledfail(context, SnackbarData().otpInvalid, Colors.red);
  }
}

Future<void> screenDataLocalStorage() async {
  final pref = await SharedPreferences.getInstance();
  String userId = pref.getString('accessToken').toString();
  final todayKey =
      'login_count_${DateTime.now().toIso8601String().substring(0, 10)}_$userId';
  int dailyLoginCount = pref.getInt(todayKey) ?? 0;
  dailyLoginCount++;
  await pref.setInt(todayKey, dailyLoginCount);

  final List<String> loginHistory =
      pref.getStringList('login_history_$userId') ?? [];
  final todayEntry = '$todayKey:$dailyLoginCount';
  if (loginHistory.any((entry) => entry.startsWith(todayKey))) {
    loginHistory.removeWhere((entry) => entry.startsWith(todayKey));
  }
  loginHistory.add(todayEntry);
  await pref.setStringList('login_history_$userId', loginHistory);

  await ScreenTimeTracker().setUser(userId);
  ScreenTimeTracker().startSession();
  ScreenTimeTracker().switchTab('Home');
}

void forceLoginShowModal(
    context, response, emailController, passwordController) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return UserLoginedAlready(
          data: response.body,
          email: emailController,
          userpassword: passwordController);
    },
  );
}

void loginCalledData(response, context) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final body = json.decode(response.body);
  String accessToken = body['data']['accessToken'];
  initGetControllers();
  pref.setString("accessToken", "Bearer " + accessToken);
  await getBankAccounts();
  await initializeOneSignal(context);
  userController.userId.value = body['data']['_id'];
  isBankAccountLink.value = body['data']['isBankAccountLinked'];
  acceptReset.value = false;
  getPhoneNo(body);
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
}

void loginCalledDataForApple(response, context) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final body = response;
  String accessToken = body['data']['accessToken'];
  initGetControllers();
  pref.setString("accessToken", "Bearer " + accessToken);
  await getBankAccounts();
  await initializeOneSignal(context);
  userController.userId.value = body['data']['_id'];
  isBankAccountLink.value = body['data']['isBankAccountLinked'];
  acceptReset.value = false;
  getPhoneNo(body);
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
}

void getPhoneNo(body) {
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

void getOTP(context, String name, String email) async {
  var response = await postDataApiCallwithOutSharedPref('${url}/otp/send', {
    'email': email,
    'name': name,
  });
  if (getFlagOfResponse(response)) {
    snackBarCalled(context, SnackbarData().sentOtpToEmail, Colors.black);
  } else {
    snackBarCalledfail(context, SnackbarData().cantSendOtp, Colors.red);
  }
}

// this is for two factor auth in login
void getOTPForTwoFactorAuth(
  context,
  String name,
  String email,
) async {
  var response = await postDataApiCallwithOutSharedPref(
    '$url/otp/send',
    {'email': email, 'name': name, 'isTwoFactor': true, "type": 'twoFactor'},
  );

  // Try decoding JSON safely
  dynamic decodedResponse;
  try {
    decodedResponse = jsonDecode(response.body);
  } catch (e) {
    decodedResponse = null;
  }

  if (getFlagOfResponse(response)) {
    snackBarCalled(context, decodedResponse['data'], Colors.black);
  } else if (response.statusCode == 429) {
    if (decodedResponse != null &&
        decodedResponse is Map &&
        decodedResponse['message'] != null) {
      snackBarCalledfail(context, decodedResponse['message'], Colors.red);
    } else {
      snackBarCalledfail(context,
          "Too many OTP requests. Please try again later.", Colors.red);
    }
  } else {
    snackBarCalledfail(context, decodedResponse['message'], Colors.red);
  }
}

Future<bool> getOTPDeleteCall(
    BuildContext context, String name, String email) async {
  try {
    var response = await postDataApiCallwithOutSharedPref(
        '${url}/otp/resend-otp',
        {'email': email, 'name': name, 'type': "deleteAccount"});
    if (getFlagOfResponse(response)) {
      snackBarCalled(context, SnackbarData().sentOtpToEmail, Colors.black);
      return true;
    } else {
      snackBarCalledfail(context, SnackbarData().cantSendOtp, Colors.red);
      return false;
    }
  } catch (e) {
    snackBarCalledfail(context, 'Failed to send OTP: $e', Colors.red);
    return false;
  }
}

Future<bool> verifyDeleteOTP(
    BuildContext context, String email, String deleteOtp) async {
  try {
    var response = await postDataApiCallwithOutSharedPref(
        '${url}/otp/verify-otp', {'email': email, 'otp': deleteOtp});
    if (getFlagOfResponse(response)) {
      snackBarCalled(context, 'OTP verified successfully',
          Colors.black); // Adjusted message for clarity
      return true;
    } else {
      snackBarCalledfail(
          context, 'Invalid OTP', Colors.red); // Adjusted message for clarity
      return false;
    }
  } catch (e) {
    snackBarCalledfail(context, 'Failed to verify OTP: $e', Colors.red);
    return false;
  }
}

// void forceLogoutUser(
//     sessionId, email, userpassword, context, id, deviceName) async {
//   try {
//     var response =
//         await postDataApiCallwithOutSharedPref('${url}/user/force-login', {
//       "sessionId": sessionId,
//       "email": email,
//       "userpassword": userpassword,
//       "deviceInfo": deviceData
//     });
//     if (getFlagOfResponse(response)) {
//       final body = json.decode(response.body);
//       loginCalledData(response, context);
//       sendNotificationsToDevice(body['data']['_id'], context,
//           "You have been logged out from StakePlot!");
//     } else {
//       snackBarCalledfail(context, SnackbarData().cantLogoutUser, Colors.red);
//     }
//   } catch (e) {}
// }

Future<void> forceLogoutUser(
    String sessionId,
    String email,
    String userpassword,
    BuildContext context,
    String existingDeviceId,
    String existingDeviceName) async {
  try {
    var response =
        await postDataApiCallwithOutSharedPref('${url}/user/force-login', {
      "sessionId": sessionId,
      "email": email,
      "userpassword": userpassword,
      "deviceInfo": deviceData.value,
    });
    if (getFlagOfResponse(response)) {
      final body = jsonDecode(response.body);
      // Notify the logged-out device (if applicable)
      if (body['data']?['_id'] != null) {
        sendNotificationsToDevice(
          body['data']['_id'],
          context,
          "You have been logged out from StakePlot!",
        );
      }
      loginCalledData(response, context);
      await screenDataLocalStorage();
      // Send OTP for the new login

      snackBarCalled(context, 'Existing session logged out.', Colors.green);
    } else {
      snackBarCalledfail(
          context, 'Failed to log out existing session.', Colors.red);
    }
  } catch (e) {
    snackBarCalledfail(
        context, 'Error during forced logout. Please try again.', Colors.red);
  }
}

void getforgotPassword(context, String name, String email) async {
  var responce =
      await postDataApiCallwithOutSharedPref('${url}/user/forgotPassword', {
    'email': email,
  });

  if (getFlagOfResponse(responce)) {
    snackBarCalled(context, SnackbarData().sentOtpToEmailAlt, Colors.black);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResetOtp(
          email: email,
          name: name,
        ),
      ),
    );
  } else {
    snackBarCalledfail(context, SnackbarData().emailIdNotValid, Colors.red);
  }
}

void addThisDeviceToBackendDevice(SharedPreferences pref, context) async {
  await addThisDeviceToBackend(
      jsonDecode(pref.getString("deviceInfo") ?? "{}"), context);
}

Future<void> addThisDeviceToBackend(deviceData, context) async {
   try {
     await postDataApiCall('${url}/notify/addDeviceToNotify/', deviceData);
   } catch (e) {}
}

Future<Widget> checkAuthAndNavigate() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  final bool isLoggedIn = _pref.containsKey("accessToken");
  return isLoggedIn ? HomePage() : LoginScreen();
}

Future<bool> verifyOTPForLogin(
    BuildContext context,
    String email,
    String password,
    String otp,
    dynamic loginResponse,
    bool isForcedLogin) async {
  try {
    var response =
        await postDataApiCallwithOutSharedPref('${url}/otp/verify-otp', {
      'email': email,
      'otp': otp,
    });
    if (getFlagOfResponse(response)) {
      if (!isForcedLogin) {
        loginUser(
          TextEditingController(text: email),
          TextEditingController(
              text:
                  password), // Password not available, adjust backend if needed
          context,
          apis_flag,
        );
      } else {
        var loggedInDevice = loginResponse['loggedInDevice'];
        if (loggedInDevice != null && loggedInDevice is Map<String, dynamic>) {
          forceLogoutUser(
              loginResponse['existingSessionId'],
              email,
              password,
              context,
              loggedInDevice['deviceId'] ??
                  "", // Check if deviceId exists and use it
              (loggedInDevice['brand'] ?? "").toString() +
                  " " +
                  (loggedInDevice['device'] ?? "").toString());
        } else {
          forceLogoutUser(
              loginResponse['existingSessionId'],
              email,
              password,
              context,
              "", // Empty string if loggedInDevice is not a Map or is null
              "");
        }
      }
      return true;
    } else {
      snackBarCalledfail(context, 'Invalid OTP. Please try again.', Colors.red);
      return false;
    }
  } catch (e) {
    snackBarCalledfail(
        context, 'OTP verification failed. Please try again.', Colors.red);
    return false;
  }
}
