import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';


void clearStack(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
}

void expire(responce, BuildContext context) {
  try {
    var body = json.decode(responce.body);
    if (body['error'].toString() == "JsonWebTokenError") {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      Navigator.pushReplacementNamed(context, '/');
    }
  } catch (e) {
 
  }
}

void check(context, String flag) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();

  if (!_pref.containsKey("accessToken")) {
    if (flag != "loginuser") Navigator.pushReplacementNamed(context, '/');
  }
}

void loginUser(TextEditingController emailController,
      TextEditingController passwordController, BuildContext context,[bool flag=false]) async {
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('${url}/user/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': emailController.text.toString(),
          'userpassword': passwordController.text.toString(),
        }),
      );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    
    String accessToken = body['data']['accessToken'];
    _pref.setString("accessToken",  "Bearer "+accessToken);
    storeinmap(body,_pref, passwordController.text);
   
    currentId.value=body['data']['_id'];
    Phone.value=body['data']['phone'];
    isBankAccountLink.value=body['data']['isBankAccountLinked'];

    if(flag)return;
   
    // isBankAccountLink.value ?  getUserInfoBackDetails(context): loginToAutoTractions(context, Phone.value);
  
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
     acceptReset.value=false;
    // Navigator.popAndPushNamed(context, '/home');
  } else {
      acceptReset.value=false;
    var snackBar = SnackBar(
      duration: Durations.medium4,
      content: Text(
        'invalid credentials!',
        style: FontManager().getTextStyle(
          context,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void storeinmap(body,SharedPreferences _pref,String password) {

  var jsonObj=body['data'];

    var bodyObj={
      "accessToken":"Bearer "+jsonObj['accessToken'],
      "name":jsonObj['name'],
      "password":password,
      "email":jsonObj['email'],
      "avatar":jsonObj['avatarType'],
    };

    Map<String, dynamic> map=Map<String, dynamic>();

    if(_pref.containsKey("loginUsers")){
          String mapData= _pref.getString("loginUsers").toString();
          map=jsonDecode(mapData);
    }

    map[jsonObj['name']]=bodyObj;

    _pref.setString("loginUsers",jsonEncode(map));

    loginUsersList.clear();
    loginUsersList.addAll(map);
  
}

void getOTP(context, String name, String email) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/otp/send'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'email': email,
      'name': name,
    }),
  );
  // printData(response, context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
  
    snackBarCalled(context, "Sended Otp To Email Id...!", Colors.black);
  } else {
    snackBarCalled(context, "can't send opt!", Colors.red);
  }
}

void getforgotPassword(context, String name, String email) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/user/forgotPassword'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'email': email,
      'name': name,
    }),
  );
  printData(response, context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    snackBarCalled(context, "Sended Otp To Email Id...!", Colors.black);
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ResetOtp(
    //       email: email,
    //       name: name,
    //     ),
    //   ),
    // );
  } else {
    snackBarCalled(context, "Email Id Not Valid!", Colors.red);
  }
}

void checkEmail(context, email, otp, name) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/otp/verify-otp'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'email': email,
      "otp": otp,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "Accepted Opt...!", Colors.black);
    // Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    // Navigator.pushNamed(context, "/");
    acceptReset.value = false;
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //       type: PageTransitionType.fade,
    //       alignment: Alignment.bottomRight,
    //       duration: Durations.long1,
    //       child: ResetPassword(
    //         email: email,
    //         name: name,
    //       ),
    //       isIos: true,
    //     ));
  } else {
    acceptReset.value = false;
    snackBarCalled(context, "Invalid Opt...!", Colors.red);
  }
}

void changePassword(context, email, p1, p2) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.post(
    Uri.parse('${url}/user/resetPassword'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'email': email,
      "newPassword": p1,
      "confirmNewPassword": p2,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "Password change...!", Colors.black);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    Navigator.pushNamed(context, "/");
  } else {
    snackBarCalled(context, "Can't change...!", Colors.red);
  }
}

void resendOpt(context, email, name) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/otp/resend-otp'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({'email': email, "name": name, 'type': 'resetPassword'}),
  );
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "ReSended Otp To Email Id...!", Colors.black);
  } else {
    snackBarCalled(context, "can't send opt!", Colors.red);
  }
}

void resendOptUser(context, email, name) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/otp/resend-otp'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'email': email,
      "name": name,
    }),
  );
 
  printData(response, context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "ReSended Otp To Email Id...!", Colors.black);
  } else {
    snackBarCalled(context, "can't send opt!", Colors.red);
  }
}

void loginUser2(TextEditingController emailController,
    TextEditingController passwordController, BuildContext context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  final response = await http.post(
    Uri.parse('${url}/user/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'email': emailController.text.toString(),
      'userpassword': passwordController.text.toString(),
    }),
  );
  //printData(response,context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    String accessToken = body['data']['accessToken'];
    _pref.setString("accessToken", "Bearer "+accessToken);
    // snackBarCalled(context, "User logined..",Colors.green);
    // .pop(context);Navigator
    // Get.p
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    // Navigator.popAndPushNamed(context, '/home');
  } else {
    var snackBar = SnackBar(
      duration: Durations.medium4,
      content: Text(
        'invalid credentials!',
        style: FontManager().getTextStyle(
          context,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Future<void> handleSignInGoogle(BuildContext context) async {
  const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  String serverClientId =
      "191971007715-768tpapqjlkvcj4grgfi66md6fh3a89m.apps.googleusercontent.com";
  String mobile="637011980078-s9kioj0kh6pkqebbf20h6fk45ufujsbg.apps.googleusercontent.com";
  String web="637011980078-snckpvhmqpcog8jejihnr8ioonvf1n22.apps.googleusercontent.com";
  // String serverClientId = 
  //     "637011980078-s9kioj0kh6pkqebbf20h6fk45ufujsbg.apps.googleusercontent.com";

  // GoogleSignIn _googleSignIn = GoogleSignIn(serverClientId:serverClientId,);

  
  try {
  
    // var googleUser = await _googleSignIn.signIn();
   
    // if (googleUser != null) {
      // final GoogleSignInAuthentication googleAuth =
      //     await googleUser.authentication;

      // final SharedPreferences _pref = await SharedPreferences.getInstance();
      // //  _pref.setString("accessToken", "Bearer "+accessToken);
      // _pref.setString("accessToken", "Google "+googleAuth.accessToken.toString());
   
      // Navigator.pushNamed(context, '/home');
      

      // You can use the ID Token to authenticate with your backend
    // } else {
     
    // }
  } catch (error) {
    
  }
}


 void clearGetX() {
            income=0.obs;
            messages.clear();
            messagesTemp.clear();
            roomBills.clear();
            questionRoom.clear();
            productList.clear();
            userPostList.clear();
            savedList.clear();
            myPostList.clear();
            friendsList.clear();
            chatList.clear();
            chatListOriginal.clear();
            friendsListDetails.clear();
            chatOfUserList.clear();
            chatOfUserListData.clear();
            aboutMe=false.obs;
            sizeRoom=false;
            fontSize=20;
            budgetLength=0.obs;
            billLength=0.obs;
            debtLength=0.obs;
            paymentLength=0.obs;
            keyss=originalKeys;
            room=[];
            account=[];
            notificationList.clear();
            hasGetNewNotifications.value=false;
              userName="Loading...".obs;
            currentId="Loading...".obs;
            Phone="Loading...".obs;
            currency="Loading...".obs;
            score="Loading...".obs;
            email="Loading...".obs;
            userId=""; 
         targetString="".obs;
        //  listOfCater =<Plot> [].obs;
           isBankAccountLink.value=true;
           trasactionsData.clear();
           isBankAccountLink.value=false;     
  }




void oneSignalApis(context)async{
   
  String appId="ff897875-4bac-4b0c-9bb6-a371998d4d1c";
  
 await OneSignal.shared.setAppId(appId);
 

 
OneSignal().promptUserForPushNotificationPermission().then((granted) {
    if (granted) {
      print("Notification permission granted");
    } else {
      print("Notification permission not granted");
    }
  });
 var status =await OneSignal.shared.getDeviceState();
 String? userDeviceId = status?.userId; 
 print("userDeviceId");// Get us the device Unique Id
 print(userDeviceId);// Get us the device Unique Id
 await  getDeviceInfo(userDeviceId!,context);
 

 OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
  print("Notification Opened: ${result.notification.additionalData}");

  String? screen = result.notification.additionalData?['screen'];
  print("Screen to Navigate To: $screen");
  // var data=await  getDeviceInfo();

  if (screen != null) {
    Navigator.pushNamed(context, screen); // Navigate to the screen
  } else {
    print("No screen specified in additional data.");
  }
});

  // var data=await  getDeviceInfo();
  // print(data);
}



Future<void> getDeviceInfo(String playerId,context) async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Map<String, String> deviceData = {};

  try {
    if (Platform.isAndroid) {
      // For Android devices
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // print(androidInfo);
      // print(androidInfo.device);
      deviceData = {
        'deviceId':playerId,
        'deviceName': androidInfo.device ?? 'Unknown',
        // 'manufacturer': androidInfo.manufacturer ?? 'Unknown',
        'os': 'Android',
        'osVersion': androidInfo.version.release ?? 'Unknown',
      };
    } else if (Platform.isIOS) {
      // For iOS devices
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData = {
        'deviceId':playerId,
        'deviceName': iosInfo.name ?? 'Unknown',
        // 'manufacturer': 'Apple',
        'os': 'iOS',
        'osVersion': iosInfo.systemVersion ?? 'Unknown',
      };
    } else {
      deviceData = {
        'deviceId':playerId,
        'deviceName': 'Unknown',
        // 'manufacturer': 'Unknown',
        'os': 'Unknown',
        'osVersion': 'Unknown',
      };
    }
  } catch (e) {
    print('Error getting device info: $e');
  }  
  
  await addThisDeviceToBackend(deviceData,context);
 
}


Future<void> addThisDeviceToBackend(deviceData,context)async
{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var accessToken = _pref.getString("accessToken");
  
  final response = await http.post(
    Uri.parse('${url}/notify/addDeviceToNotify/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(deviceData),
  );
  printData(response, context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    print(body);
    snackBarCalled(context, "user device login...!", Colors.black);
  } else {
    snackBarCalled(context, "can't send opt!", Colors.red);
  }
}