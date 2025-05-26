import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void approveBill(context, id, type, notifyId) async {
  // /acceptBill/:id/:accept/:notificationsId
  String urlPath = "${url}/bill/acceptBill/${id}/${type}/${notifyId}";

  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {}
}

Future<void> getRemainders(context) async {
  String urlPath = "${url}/reminders";
  var responce = await getDataApiCall(urlPath);
  //print("Response: ${responce.body}"); // Log the response body
  if (getFlagOfResponse(responce)) {
    var his = jsonDecode(responce.body);
    var userDue = his['data']['payables'] ?? [];
    var userDue2 = his['data']['owed'] ?? [];
    // print("User Due: $userDue"); // Log userDue
    // print("User Due2: $userDue2"); // Log userDue2
    dueAmountRemainders.clear();
    lendAmountRemainders.clear();
    dueAmountRemainders.addAll(userDue); //payables
    lendAmountRemainders.addAll(userDue2); //owed
    dueAmountRemainders.refresh();
    lendAmountRemainders.refresh();
    getdueUsers.value = !getdueUsers.value;
  } else {}
}

Future<void> getFoodieFundsDetails(BuildContext context, String id) async {
  String urlPath = "${url}/reminders/$id";
  var response = await getDataApiCall(urlPath);
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var data = his['data'] ?? {};

    foodieFundsDetailsRemainders.clear();

    // Add the entire data object as a single item (or adjust to extract friends + currentUser)
    foodieFundsDetailsRemainders.add(data);

    foodieFundsDetailsRemainders.refresh();
    getFoodieFundsUsers.value = !getFoodieFundsUsers.value;
  } else {
    snackBarCalled(context,SnackbarData().failedToFetchFoodieFundsDetails);
  }
}

void getNotifications(context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('${url}/user/myNotifications'),
    // Uri.parse('https://stakeplot.in/api/v1/post/all'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    notificationList.clear();
    notificationList.addAll(his['data']);
    notificationList.forEach((req) {
      String type = req['notificationMessage']['type'];
      var e = req['notificationMessage'];
      if (type == "friendRequest") {
        friendRequestList.add(e['from_id']);
      }
    });
    
      hasGetNewNotifications.value = false;
    myNotificationBool.value = !myNotificationBool.value;
  } else {}
}

void getuserPost(id) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('${url}/post/myDiscussions'),    
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    myPostList.clear();
    myPostList.addAll(obj);
    myPostList.forEach((element) {
      postCount[element["_id"]] = element['upvotes'];
      postCommentCount[element["_id"]] = element['comments'];
    });
  } else {}
}

void getSaved() async {
  String urlPath = "${url}/post/saved";
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    var his = jsonDecode(response.body);
    var obj = his['data'];

    savedList.clear();
    savedList.addAll(obj);
    savedList.forEach((element) {
      postCount[element["_id"]] = element['upvotes'];
      postCommentCount[element["_id"]] = element['comments'];
    });
  } else {}
}

void getUserInfomations() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('${url}/user/info'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];

    likedList.clear();
    likedProducts.clear();
    likedList.addAll(obj["likedPosts"]);
    likedList.addAll(obj["likedComments"]);
    likedProducts.addAll(obj["likedProducts"]);

    frdsList.clear();
    frdsListOrigin.clear();
    frdsList.addAll(obj['friendsList']);
    frdsListOrigin.addAll(frdsList);

    aboutMe.value = (obj['aboutMe'] == "Hello");
    aboutUS.value = obj['aboutMe'];
    selectedBank.value = obj['selectedBank'] ?? "";
    userAvatarBackGround.value = obj['avatarBackGround'] ?? "#FA7070";

    List s = obj['accounts'];
    income.value = 0;
    s.forEach((element) {
      income.value += int.parse(element['income'].toString());
    });

    var data = obj;

    getuserPost(data['_id']);
    getSaved();
    currentId.value = data['_id'];
    userName.value = data['name'];
    avatar.value = avaterUrlPath(userName.value);
    userAvatar = avatar.value;
    email.value = data['email'];
    currency.value = data['currency'];
    score.value = data['score'].toString();
    coin = data['coins'].toString();
    dob.value = data['dob'].toString().substring(0, 10);
    expenses.value = data['expense'].toString();
    isBankAccountLink.value = data['isBankAccountLinked'] ?? false;
    isFected.value = data['fetchInProgress'] ?? false;
    cupertinoPin.value = data['cupertino_pin']; //?? '0';
    getPhoneNo(his);
    // savedList.clear();
    // savedList.addAll(data['saved'] );

    friendsList.clear();
    friendsList.addAll(obj['friendsList']);

    friendsList.forEach((element) {
      friendsListDetails[element['_id']] = {
        'name': element['name'],
        'avatar': element['avatarBackGround'],
      };
    });
  } else {}
}

void getUserInfo() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('${url}/user/info'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];

    List s = obj['accounts'];
    final SharedPreferences _pref = await SharedPreferences.getInstance();

    // likedList.clear();
    // likedProducts.clear();
    // likedList.addAll(obj["likedPosts"]);
    // likedList.addAll(obj["likedComments"]);
    // likedProducts.addAll(obj["likedProducts"]);
    isBankAccountLink.value = obj['isBankAccountLinked'] ?? false;

    s.forEach((element) {
      if (!account.contains(element['name'])) {
        account.add(element['name']);
        // accountMap[element['name']]= double.parse(element['balance'].toString());
      }
    });

    _pref.setString("userId", obj['_id']);
    userId = obj['_id'];

    if (obj['roomsAssociated'].length > 0) {
      room = obj['roomsAssociated'];

      var r = {
        'name': obj['roomsAssociated'][0]['name'] ?? "",
        'id': obj['roomsAssociated'][0]['id'] ?? "",
        "expenseType": "running",
        "expenseId": null
      };

      room.insert(0, r);
    }
  } else {}
}

String getCurrentFormattedDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  return formattedDate;
}

void aboutuser(context, String about) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse('${url}/user/updateprofile'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "aboutMe": about,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(context,SnackbarData().userInfoUpdated,
        Colors.black);
  } else {
    snackBarCalled(context,SnackbarData().errorUpdatingUserInfo, Colors.red);
  }
}

void addAccount(context, String account, String money) async {
  var urlPath = Uri.parse('${url}/user/addAccount');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${urlPath}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'newAccount': account,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(context,SnackbarData().accountAddedSuccessfully, Colors.black);
    Navigator.pushNamed(context, '/home');
  } else {
    snackBarCalled(context,SnackbarData().errorAddingAccount, Colors.red);
  }
}

void editUserDetails(
    context, Map<String, TextEditingController> controller) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  try {
    final response = await http.post(
      Uri.parse('${url}/user/updateprofile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "name": controller['name']!.text.toString(),
        "phone": controller['Number']!.text.toString(),
        "dob": controller['dob']!.text.toString(),
        "avatarType":
            (changeAvater.value == "Loading..." || changeAvater.value == "")
                ? avatar.value
                : changeAvater.value,
      }),
    );

    var responce = jsonDecode(response.body);

    bool boolvar = responce['success'];
    if (!boolvar) {
      snackBarCalled(context, responce['error']['explanation'], Colors.red);
      return;
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      snackBarCalled(context,SnackbarData().userInfoUpdated,
          Colors.black);
      // getUserInfomations();
      avatar.value = changeAvater.value;
      userName.value = controller['name']!.text.toString();
      Phone.value = controller['Number']!.text.toString();
      number.value = controller['Number']!.text.toString();
      dob.value = controller['dob']!.text.toString();
    } else {
      
    }
  } catch (e) {}
}
