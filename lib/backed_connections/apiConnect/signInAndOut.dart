import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/animated/userLoginedAlready.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/opt_email.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/signInOut/confirm.dart';
import 'package:flutter_application_code_stakeplot/signInOut/resetPas.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signin.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/create_new_password.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/forgot.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/signin.dart';
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
      snackBarCalled(context, SnackbarData().serverError, Colors.red);
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
          data: response.body ?? "",
          email: emailController.text ?? "",
          userpassword: passwordController.text ?? "");
    },
  );
}

void loginCalledData(response, context) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  print(response);
  final body = json.decode(response.body);
  String accessToken = body['data']['accessToken'];
  pref.setString("accessToken", "Bearer " + accessToken);
  await getBankAccounts();
  await initializeOneSignal(context);
  currentId.value = body['data']['_id'];
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
  Phone.value = phone;
  number.value = phone;
}

void getOTP(context, String name, String email) async {
  var response = await postDataApiCallwithOutSharedPref('${url}/otp/send',
      {'email': email, 'name': name, 'deviceInfo': deviceData});
  if (getFlagOfResponse(response)) {
    snackBarCalled(context, SnackbarData().sentOtpToEmail, Colors.black);
  } else {
    snackBarCalled(context, SnackbarData().cantSendOtp, Colors.red);
  }
}

Future<bool> getOTPDeleteCall(
    BuildContext context, String name, String email) async {
  try {
    var response = await postDataApiCallwithOutSharedPref('${url}/otp/resend-otp',
        {'email': email, 'name': name, 'type': "deleteAccount"});
        print("response for otp :${response.body}");
    if (getFlagOfResponse(response)) {
      
      snackBarCalled(context, SnackbarData().sentOtpToEmail, Colors.black);
      return true;
    } else {
      snackBarCalled(context, SnackbarData().cantSendOtp, Colors.red);
      return false;
    }
  } catch (e) {
    snackBarCalled(context, 'Failed to send OTP: $e', Colors.red);
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
      snackBarCalled(
          context, 'Invalid OTP', Colors.red); // Adjusted message for clarity
      return false;
    }
  } catch (e) {
    snackBarCalled(context, 'Failed to verify OTP: $e', Colors.red);
    return false;
  }
}

void forceLogoutUser(
    sessionId, email, userpassword, context, id, deviceName) async {
  try {
    var response =
        await postDataApiCallwithOutSharedPref('${url}/user/force-login', {
      "sessionId": sessionId,
      "email": email,
      "userpassword": userpassword,
      "deviceInfo": deviceData
    });
    if (getFlagOfResponse(response)) {
      final body = json.decode(response.body);
      loginCalledData(response, context);
      sendNotificationsToDevice(body['data']['_id'], context,
          "You have been logged out from StakePlot!");
    } else {
      snackBarCalled(context, SnackbarData().cantLogoutUser, Colors.red);
    }
  } catch (e) {}
}

void getforgotPassword(context, String name, String email) async {
  var responce =
      await postDataApiCallwithOutSharedPref('${url}/user/forgotPassword', {
    'email': email,
    "name": name,
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
    snackBarCalled(context, SnackbarData().emailIdNotValid, Colors.red);
  }
}

void addThisDeviceToBackendDevice(SharedPreferences pref, context) async {
  await addThisDeviceToBackend(
      jsonDecode(pref.getString("deviceInfo") ?? "{}"), context);
}

Future<void> addThisDeviceToBackend(deviceData, context) async {
  try {
    var response =
        await postDataApiCall('${url}/notify/addDeviceToNotify/', deviceData);
    printData(response);
    if (getFlagOfResponse(response)) {
      print("object");
    }
  } catch (e) {
    print(e);
    print("error");
  }
}

Future<Widget> checkAuthAndNavigate() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  final bool isLoggedIn = _pref.containsKey("accessToken");
  return isLoggedIn ? HomePage() : LoginScreen();
}
