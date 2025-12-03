import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/finanace_dashboard/pending_users.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/credentials.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/auth_service/login_apis.dart';

Future<void> initializeOneSignal(BuildContext context) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  String key = "deviceInfo";
  var json;
  if (pref.containsKey(key)) {
    json = jsonDecode(pref.getString("deviceInfo") ?? "{}");
  }
   if(!pref.containsKey(key) ||
      json["deviceId"] == "deviceData.value" ||
      json["deviceId"] == "") {
    await oneSignalInit();
    await Future.delayed(Duration(seconds: 3)); // Small delay
    String userDeviceId = await OneSignal.User.pushSubscription.id ?? "deviceData.value";
    getDeviceLocalDetails(userDeviceId, context);
    var deviceDataLocal = {
      ...deviceData,
      'deviceId': userDeviceId,
    };
    deviceData.clear();
    deviceData.addAll(deviceDataLocal);
    pref.setString(key, jsonEncode(deviceData));
  } 
  else {
    deviceData['deviceId'] = json["deviceId"];
  }
  addThisDeviceToBackendDevice(pref, context);
}

void _handleNotificationClick(
    OSNotificationClickEvent event, BuildContext context, bool flag) {
  try {
    String screen = event.notification.additionalData?['screen'];
    navigateScreens(context, screen, flag);
  } catch (e) {}
}

void navigateScreens(context, screen, bool flag) {
  if (screen.toString().contains("chat")) {
    Navigator.pushNamed(context, '/TribeChats');
  } else if (screen.toString().contains("friends")) {
    Navigator.pushNamed(context, '/Friends');
  } else if (screen.toString().contains("post")) {
    Navigator.pushNamed(context, '/post');
  } else if (screen.toString().contains("coupons")) {
    Navigator.pushNamed(context, '/rewardsOverview');
  } else if (screen.toString().contains("remainder") ||
      screen.toString().contains("remainders")) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 2000), // Increase duration
        curve: Curves.easeInOut, // Smooth transition
        child: UserListScreen(
          isPayable: true,
        ),
        isIos: true,
      ),
    );
  } else {
    Navigator.pushNamed(context, "/Notifications");
  }
}

Future<void> oneSignalInit() async {
  try {
    String appId = Credentials.oneSignal;
    OneSignal.Debug.setLogLevel(OSLogLevel.none);
    OneSignal.initialize(appId);
  } catch (e) {}
}

Future<void>  getDeviceInfo(
    String playerId,
    context,
    TextEditingController emailController,
    ) async {
  deviceData.value = {};
  final SharedPreferences pref = await SharedPreferences.getInstance();
  String key = "deviceInfo";

  if (!pref.containsKey(key))
  {
    getDeviceLocalDetails(playerId, context);
  }
  deviceData.value = jsonDecode(pref.getString(key) ?? "{}");
  LoginService.userVerification(emailController, context);
}

void getDeviceLocalDetails(String playerId, context) async {
  try {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData.value = {
        'deviceId': playerId,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'model': androidInfo.model,
        'os': 'Android',
      };
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData.value = {
        'deviceId': playerId,
        'device': iosInfo.name,
        'brand': iosInfo.model ?? 'Apple',
        'model': iosInfo.model ?? 'iPhone',
        'os': 'iOS',
      };
    } else {
      deviceData.value = {
        'deviceId': (playerId == "") ? "" : playerId,
        'device': 'Unknown',
        'os': 'Unknown',
        'brand': '',
        'model': '',
      };
    }
  } catch (e) {
    deviceData.value = {
      'deviceId': (playerId == "") ? "" : playerId,
      'device': 'Unknown',
      'os': 'Unknown',
      'brand': 'Unknown',
      'osVersion': 'Unknown',
    };
  }
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString('deviceInfo', jsonEncode(deviceData));
}

void oneSignalAddClickListener(context) {
  try {
    OneSignal.Notifications.addClickListener((event) {
      _handleNotificationClick(event, Get.context ?? context,false);

    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      String s = event.notification.body.toString().toLowerCase().trim();
      if (s == "you have been logged out from stakeplot!") {
        return;
      }
      if (s.contains("problem") ||
          s.contains("try again later") ||
          s.contains("successfully fetched"))
      {
        isFected.value = false;
        getBankAccounts();
      }
    });
  } catch (e) {}
}

Future<void> requestNotificationPermissionOncePerDay() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String today = DateTime.now().toIso8601String().substring(0, 10);
  String key = "onesignal_permission_asked_date";
  bool isPermissionAsked = prefs.containsKey(key);
  String? lastAskedDate = prefs.getString(key);
  if (!isPermissionAsked || lastAskedDate != today) {
    OneSignal.Notifications.requestPermission(true);
    await prefs.setString(key, today);
  }
}
