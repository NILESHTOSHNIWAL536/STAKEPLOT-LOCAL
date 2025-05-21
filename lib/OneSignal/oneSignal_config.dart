
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<void> initializeOneSignal(BuildContext context) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  String key = "deviceInfo";
  var json;

  if(pref.containsKey(key)){
     json = jsonDecode(pref.getString("deviceInfo") ?? "{}");
  }
  
  if (!pref.containsKey(key) || json["deviceId"]=="deviceData.value")
  {
    await oneSignalInit();
    await Future.delayed(Duration(seconds: 3)); // Small delay
    String? userDeviceId = await OneSignal.User.pushSubscription.id;
    deviceData['deviceId'] = userDeviceId ?? "deviceData.value";
    pref.setString(key, jsonEncode(deviceData));
  }
  else
  {
    deviceData['deviceId'] = json["deviceId"];
  }

 addThisDeviceToBackendDevice(pref, context);

}

void _handleNotificationClick(OSNotificationClickEvent event, BuildContext context) {

  try 
  {
        String screen = event.notification.additionalData?['screen'];
        navigateScreens(context,screen);
  } 
  catch (e)
  {
    print('Error handling notification click: $e');
  }

}


void navigateScreens(context,screen){
   if(screen.toString().contains("chat"))
    {
           Navigator.pushNamed(context, '/TribeChats');
    }
    else  if(screen.toString().contains("friends"))
    { 
            Navigator.pushNamed(context, '/Friends');
    }
   else if(screen.toString().contains("post"))
    {
            Navigator.pushNamed(context, '/post');
    }
   else if(screen.toString().contains("remainder" ) || screen.toString().contains("remainders"))
    {
           Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 2000), // Increase duration
              curve: Curves.easeInOut, // Smooth transition
              child:UserListScreen(isPayable: true,),
              isIos: true,
            ),
          );
    }
    else
    {
     Navigator.pushNamed(context, "/Notifications");
    }
}

// void navigateScreen(context) {
//   OneSignal.Notifications.addClickListener((event) {
//     print("user clicked on notification: $event");
//     String? screen = event.notification.additionalData?['screen'];
//     print("user clicked on notification with screen: $screen");
//     if (screen != null) {
//       Navigator.pushNamed(context, screen);
//     } else {
//       print("No screen specified in additional data.");
//     }
//   });

// }

Future<void> oneSignalInit() async {
  try {
    String appId = "66bc1852-d40b-4ad0-8a11-5e3d0da698a2";
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
    // OneSignal.Notifications.requestPermission(true);
  } catch (e)
  {
     print('Error initializing OneSignal: $e'); 
  }

}

Future<void> getDeviceInfo(
    String playerId,
    context,
    TextEditingController emailController,
    TextEditingController passwordController) async {
  
  deviceData.value = {};
  final SharedPreferences pref = await SharedPreferences.getInstance();
  String key = "deviceInfo";

  if(pref.containsKey(key))
  {
     deviceData.value = jsonDecode(pref.getString(key) ?? "{}");
     loginUser(emailController, passwordController, context);
  }
  else
  {
     getDeviceLocalDetails(playerId,emailController, passwordController, context);
  }

 
}



void getDeviceLocalDetails(String playerId,emailController, passwordController, context)async{


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
      // For iOS devices
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData.value = {
        'deviceId': playerId,
        'deviceName': iosInfo.name,
        'os': 'iOS',
        'osVersion': iosInfo.systemVersion
      };
    } else {
      deviceData.value = {
        'deviceId':( playerId==""||playerId==null)?"":playerId,
        'deviceName': 'Unknown',
        'os': 'Unknown',
        'brand': 'Unknown',
        'osVersion': 'Unknown',
      };
    }
  } catch (e) {
  
    deviceData.value = {
        'deviceId':( playerId==""||playerId==null)?"":playerId,
        'deviceName': 'Unknown',
        'os': 'Unknown',
        'brand': 'Unknown',
        'osVersion': 'Unknown',
      };
  }

   loginUser(emailController, passwordController, context);

}





void oneSignalAddClickListener(context)
{
  try{

  OneSignal.Notifications.addClickListener((event)
  {
      _handleNotificationClick(event, context);
  });

   OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      String s=event.notification.body.toString().toLowerCase().trim();
      String t1="There is a problem with you bank server. Please try again later.";
      String t2="we couldn't able to fetch your bank details, try again later";
      String t3="Your bank account data has been successfully fetched.";
      if(s=="you have been logged out from stakeplot!")
      {
          //  logoutUserFromDevice(context);
           return;
      }
      if(s.contains("problem")|| s.contains("try again later") || s.contains("successfully fetched")){
              isFected.value=false;
              getBankAccounts();
      } 
   });

 }catch(e)
 {
   print('Error adding click listener: $e');
 }

}


 Future<void> requestNotificationPermissionOncePerDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10); 
    String key="onesignal_permission_asked_date";
    bool isPermissionAsked = prefs.containsKey(key);
    String? lastAskedDate = prefs.getString(key);
    if (!isPermissionAsked || lastAskedDate != today)
    {
      OneSignal.Notifications.requestPermission(true);
      await prefs.setString(key, today);
    } 
    
  }