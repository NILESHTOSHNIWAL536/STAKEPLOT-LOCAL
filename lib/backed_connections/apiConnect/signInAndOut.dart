import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/signInOut/resetPas.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/snackBar.dart';


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

void addThisDeviceToBackendDevice(SharedPreferences pref, context) async 
{
  await addThisDeviceToBackend(jsonDecode(pref.getString("deviceInfo") ?? "{}"), context);
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


