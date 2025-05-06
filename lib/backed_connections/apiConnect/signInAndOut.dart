import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/animated/userLoginedAlready.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/signInOut/resetPas.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Future<void> loginUser(TextEditingController emailController,TextEditingController passwordController, BuildContext context,[bool flag = false]) async {

//   var response = await postDataApiCallwithOutSharedPref('${url}/user/login', {
//     'email': emailController.text.toString(),
//     'userpassword': passwordController.text.toString(),
//     'deviceInfo': deviceData,
//   });

//   if (response.statusCode == 409)
//   {
//       forceLoginShowModal(context,response,emailController,passwordController); 
//   }
//   else if(response.statusCode == 500){
//     snackBarCalledSignup(context, "Server Error!", Colors.red);
//   }
//   else if (getFlagOfResponse(response))
//    {
//      loginCalledData(response,context);
//   }
//   else
//   {
//      acceptReset.value = false;
//      snackBarCalledfail(context, 'Invalid credentials');
//   }
// }

// Future<void> loginUser(
//     TextEditingController emailController,
//     TextEditingController passwordController,
//     BuildContext context,
//     [bool flag = false]) async {
//   var response = await postDataApiCallwithOutSharedPref('${url}/user/login', {
//     'email': emailController.text.toString(),
//     'userpassword': passwordController.text.toString(),
//     'deviceInfo': deviceData,
//   });

//   if (response.statusCode == 409) {
//     forceLoginShowModal(context, response, emailController, passwordController);
//   } else if (response.statusCode == 500) {
//     snackBarCalledSignup(context, "Server Error!", Colors.red);
//   } else if (getFlagOfResponse(response)) {
//     loginCalledData(response, context);

//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     final String todayKey = 'login_count_${DateTime.now().toIso8601String().substring(0, 10)}';
//     int dailyLoginCount = pref.getInt(todayKey) ?? 0;
//     dailyLoginCount++;
//     await pref.setInt(todayKey, dailyLoginCount);

//     final List<String> loginHistory = pref.getStringList('login_history') ?? [];
//     final String todayEntry = '$todayKey:$dailyLoginCount';
//     if (loginHistory.any((entry) => entry.startsWith(todayKey))) {
//       loginHistory.removeWhere((entry) => entry.startsWith(todayKey));
//     }
//     loginHistory.add(todayEntry);
//     await pref.setStringList('login_history', loginHistory);

//     await ScreenTimeTracker().initialize();
//     ScreenTimeTracker().startSession();
//   } else {
//     acceptReset.value = false;
//     snackBarCalledfail(context, 'Invalid credentials');
//   }
// }



Future<void> loginUser(
    TextEditingController emailController,
    TextEditingController passwordController,
    BuildContext context,
    [bool flag = false]) async {
  try {
    var response = await postDataApiCallwithOutSharedPref('${url}/user/login', {
      'email': emailController.text.toString(),
      'userpassword': passwordController.text.toString(),
      'deviceInfo': deviceData,
    });

    if (response.statusCode == 409) {
      forceLoginShowModal(context, response, emailController, passwordController);
    } else if (response.statusCode == 500) {
      snackBarCalledSignup(context, "Server Error!", Colors.red);
    } else if (getFlagOfResponse(response)) {
      loginCalledData(response, context);
      await screenDataLocalStorage();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      acceptReset.value = false;
      snackBarCalledfail(context, 'Invalid credentials');
    }
  } catch (e, stackTrace) {
    acceptReset.value = false;
    snackBarCalledfail(context, 'Login failed, Try again');
  }
}

Future<void> screenDataLocalStorage()async 
{
      final pref = await SharedPreferences.getInstance();
      String userId = pref.getString('accessToken').toString(); 
      final todayKey = 'login_count_${DateTime.now().toIso8601String().substring(0, 10)}_$userId';
      int dailyLoginCount = pref.getInt(todayKey) ?? 0;
      dailyLoginCount++;
      await pref.setInt(todayKey, dailyLoginCount);

      final List<String> loginHistory = pref.getStringList('login_history_$userId') ?? [];
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

void forceLoginShowModal(context,response,emailController,passwordController)
 {

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
            userpassword: passwordController.text??"");
      },
    );

}

void loginCalledData(response,context) async
{
   final SharedPreferences pref = await SharedPreferences.getInstance();
   final body = json.decode(response.body);
    String accessToken = body['data']['accessToken'];
    pref.setString("accessToken", "Bearer " + accessToken);
    await initializeOneSignal(context);
    currentId.value = body['data']['_id'];
    isBankAccountLink.value = body['data']['isBankAccountLinked'];
    acceptReset.value = false;
    getPhoneNo(body);
     await getBankAccounts();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
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


void getOTP(context, String name, String email) async
{
  var response =await postDataApiCallwithOutSharedPref('${url}/otp/send', {'email': email, 'name': name, 'deviceInfo': deviceData});
  if (getFlagOfResponse(response)){
    snackBarCalled(context, "Sent Otp To Email Id!", Colors.black);
  } else {
    snackBarCalled(context, "can't send otp!", Colors.red);
  }

}

void forceLogoutUser( sessionId, email, userpassword, context, id, deviceName)async {
  try {
     var response=await postDataApiCallwithOutSharedPref('${url}/user/force-login',{
        "sessionId": sessionId,
        "email": email,
        "userpassword": userpassword,
        "deviceInfo": deviceData
      });
    if (getFlagOfResponse(response))
    {
      loginCalledData(response,context);
      sendNotificationsToDevice(currentId.value, context,"You have been logged out from StakePlot!"); 
    }else {
      snackBarCalled(context, "can't logout user!", Colors.red);
    }
  } catch (e)
  {
    print(e);
  }
}

void getforgotPassword(context, String name, String email) async {

   var responce=await postDataApiCallwithOutSharedPref('${url}/user/forgotPassword',{
      'email': email,
      "name": name,
    });

  if (getFlagOfResponse(responce)) {
    snackBarCalled(context, "Sent OTP To Email Id", Colors.black);
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
    snackBarCalled(context, "Email Id Not Valid!", Colors.red);
  }
}


void addThisDeviceToBackendDevice(SharedPreferences pref, context) async {
  await addThisDeviceToBackend(
      jsonDecode(pref.getString("deviceInfo") ?? "{}"), context);
}


Future<void> addThisDeviceToBackend(deviceData, context) async
{
    await postDataApiCall('${url}/notify/addDeviceToNotify/', deviceData);
}