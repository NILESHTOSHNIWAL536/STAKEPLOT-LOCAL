import 'dart:convert';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/repository/auth_service/login_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/credentials.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:test/test.dart'; // NOT flutter_test


void main() async {
  await dotenv.load(fileName: ".env");
  updateDeviceData(deviceData);

  group('Full Login-Signup Integration Flow', () {
    final String email = "testuser2@gmail.com";
    final String name = "testuser2";
    final String otp = "123456";

    test('User Login / OTP / ForceLogin / Signup Flow', () async {
      // STEP 1: Verify User
      final verification = await verifyUser(email);
      bool isNewUser = verification['isNewUser'];
      bool isForceLogin = verification['isForceLogin'];
      var loginResponse = verification['loginResponse'];

      // STEP 2: Send OTP
      await sendOtp(email, name);

      // STEP 3–4: Based on user type
      if (isNewUser) {
        await registerNewUser(email, name, otp);
      } else if (isForceLogin) {
        await forceLogoutUser(email, otp, loginResponse);
      } else {
        await normalLogin(email, otp);
      }

      appLog('--- Flow Completed --- ✅');
    });
  });
}


Future<Map<String, dynamic>> verifyUser(String email) async {
  appLog('--- Step 1: Verify User ---');
  appLog(AuthApiRoutes.verify);
  final response = await postDataApiCallwithOutSharedPref(AuthApiRoutes.verify, {
    'email': email,
  });

  appLog('Verify Response Status: ${response.statusCode}');
  appLog('Verify Response Body: ${response.body}');

  bool isNewUser = false;
  bool isForceLogin = false;
  var loginResponse = {};

  try {
    loginResponse = jsonDecode(response.body);
  } catch (e) {
    appLog('Error decoding verify response: $e');
  }

  if (response.statusCode == 409) {
    appLog('User has existing session, will force logout if needed.');
    isForceLogin = true;
  } else if (response.statusCode == 400) {
    appLog('New user detected. Will proceed to OTP and then registration.');
    isNewUser = true;
  } else if (getFlagOfResponse(response)) {
    appLog('Existing user, proceed to OTP verification.');
  } else {
    appLog('Invalid response.');
  }

  return {
    'isNewUser': isNewUser,
    'isForceLogin': isForceLogin,
    'loginResponse': loginResponse
  };
}

Future<void> sendOtp(String email, String name) async {
  appLog('--- Step 2: Send OTP ---');

  var response = await postDataApiCallwithOutSharedPref(
    otpRoutes.sendOtp,
    {
      'email': email,
      'name': name,
      'isTwoFactor': true,
      "type": 'twoFactor'
    },
  );

  appLog('OTP sent to $email');
  appLog('OTP Response Status: ${response.statusCode}');
  appLog('OTP Response Body: ${response.body}');
}

Future<void> registerNewUser(String email, String name, String otp) async {
  appLog('--- Step 3: Verify OTP for New User ---');
  var response3 = await postDataApiCallwithOutSharedPref(
      otpRoutes.verifyOtp, {'email': email, 'otp': otp});

  if (getFlagOfResponse(response3)) {
    appLog('--- Step 4: Register New User ---');
    final response = await postDataApiCallwithOutSharedPref(AuthApiRoutes.signUp, {
      'name': name,
      'email': email,
      'authorizationKey': Credentials.Sign_Up_Key,
      'deviceInfo': deviceData
    });

    if (getFlagOfResponse(response)) {
      appLog('Signup completed for new user: $email');
    } else {
      printData(response);
    }
  } else {
    appLog('OTP Verification failed for new user.');
    printData(response3);
  }
}

Future<void> forceLogoutUser(
    String email, String otp, Map<String, dynamic> loginResponse) async {
  appLog('--- Step 4: Force Logout Existing Session ---');

  var response = await postDataApiCallwithOutSharedPref(AuthApiRoutes.forceLogin, {
    "sessionId": loginResponse["error"]?['existingSessionId'],
    "email": email,
    "otp": otp,
    "deviceInfo": deviceData,
  });

  if (getFlagOfResponse(response)) {
    appLog('Existing session logged out for user: $email');
  } else {
    printData(response);
  }
}

Future<void> normalLogin(String email, String otp) async {
  appLog('--- Step 4: Normal Login ---');
  var response = await postDataApiCallwithOutSharedPref(AuthApiRoutes.login, {
    'email': email,
    'deviceInfo': deviceData,
    'otp': otp,
  });

  if (getFlagOfResponse(response)) {
    appLog("Login successfully....");
  } else {
    printData(response);
  }
}

