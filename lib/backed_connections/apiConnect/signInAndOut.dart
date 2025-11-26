import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/loginservices/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apiAutomations/secure_storage.dart';


Future<void> screenDataLocalStorage() async {
  final pref = await SharedPreferences.getInstance();
  String userId =await  SecureStorageService().read("accessToken").toString();
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




void addThisDeviceToBackendDevice(SharedPreferences pref, context) async 
{
  await _addThisDeviceToBackend(jsonDecode(pref.getString("deviceInfo") ?? "{}"), context);
}

Future<void> _addThisDeviceToBackend(deviceData, context) async {
   try {
     await postDataApiCall('${url}/notify/addDeviceToNotify/', deviceData);
   } catch (e) {}
}

Future<Widget> checkAuthAndNavigate() async {
  final bool isLoggedIn = await SecureStorageService().containsKey("accessToken");
  return isLoggedIn ? HomePage() : LoginScreen();
}


