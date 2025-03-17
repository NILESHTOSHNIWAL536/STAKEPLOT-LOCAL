import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void approveBill(context, id, type, notifyId) async {
  // /acceptBill/:id/:accept/:notificationsId
  String urlPath = "${url}/bill/acceptBill/${id}/${type}/${notifyId}";

  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {}
}

// void getRemainders(context) async {
//   String urlPath = "${url}/reminders";
//   var responce = await getDataApiCall(urlPath);

//   if (getFlagOfResponse(responce)) {
//     var his = jsonDecode(responce.body);
//     var userDue = his['data']['PendingBills'];
//     var userDue2 = his['data']['PendingPayments'];
//     var userDue3 = his['data']['PendingSplits'];
//     dueAmountRemainders.clear();
//     dueAmountRemainders.addAll(userDue);
//     dueAmountRemainders.addAll(userDue2);
//     dueAmountRemainders.addAll(userDue3);
//     getdueUsers.value = !getdueUsers.value;
//   }

// }
void getRemainders(context) async {
  String urlPath = "${url}/reminders";
  var responce = await getDataApiCall(urlPath);
  // print(responce.body);
  if (getFlagOfResponse(responce)) {
    var his = jsonDecode(responce.body);
    // var userDue = his['data']['billsPayable'];
    // var userDue2 = his['data']['billsOwed'];
    // var userDue3 = his['data']['splitsPayable'];
    // var userDue4 = his['data']['splitsOwed'];
    var userDue = his['data']['payables'];
    var userDue2 = his['data']['owed'];

    dueAmountRemainders.clear();
    lendAmountRemainders.clear();

    dueAmountRemainders.addAll(userDue); //payables
    lendAmountRemainders.addAll(userDue2); //owed

// print("lendAmountRemainders: $lendAmountRemainders");
// print("dueAmountRemainders: $dueAmountRemainders");
    getdueUsers.value = !getdueUsers.value;
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

    myNotificationBool.value = !myNotificationBool.value;
    // snackBarCalled(context,"Lend Amount Adde to Dues!",Colors.black);
  } else {}
}

void getuserPost(id) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    // Uri.parse('${url}/post/userDiscussions/${id}'),
    Uri.parse('${url}/post/myDiscussions'),
    // Uri.parse('https://stakeplot.in/api/v1/post/feed'),
    // Uri.parse('https://stakeplot.in/api/v1/post/all'),
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

    List s = obj['accounts'];
    income.value = 0;
    s.forEach((element) {
      income.value += int.parse(element['income'].toString());
    });

    var data = obj;

    getuserPost(data['_id']);
    getSaved();
    currentId.value = data['_id'];
    avatar.value = data['avatarType'].toString();
    userName.value = data['name'];
    email.value = data['email'];
    Phone.value = data['phone'];
    currency.value = data['currency'];
    score.value = data['score'].toString();
    coin = data['coins'].toString();
    dob.value = data['dob'].toString().substring(0, 10);
    expenses.value = data['expense'].toString();
    isBankAccountLink.value = data['isBankAccountLinked'] ?? false;
    cupertinoPin.value = data['cupertino_pin']; //?? '0';

    // savedList.clear();
    // savedList.addAll(data['saved'] );

    friendsList.clear();
    friendsList.addAll(obj['friendsList']);

    friendsList.forEach((element) {
      friendsListDetails[element['_id']] = {
        'name': element['name'],
        'avatar': element['avatar'],
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

void addLendUserAmount(
    context, String amount, List members, String name) async {
  // List nameList=[];
  // members.forEach((element) {
  //      nameList.add(
  //        {
  //           'member':(element['id']),
  //           'markAsComplete':false,
  //        }
  //      );
  // });

  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/bill'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "name": name,
      "amount": amount,
      "billReceiverId": members[0]['id'],
      "subcategory": 'Lend Money',
      "Avatar": members[0]['avatar'],
      "userName": members[0]['name'],
      'dueDate': getCurrentFormattedDate(),
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(
        context, "The lend amount has been sent to users!", Colors.black);
    members.forEach((e) {
      sendNotificationsToDevice(e['id'], context,
          "${userName.value} Has Send U a Lend Bill..Of ${name} Of ${amount}");
    });

    addTransaction(amount, "Lend Bill", name, context, 'cash', true);
    getUserLend(context);
    //   Navigator.push(
    //   context,
    //   PageTransition(
    //     type: PageTransitionType.fade,
    //      duration: Durations.long1,
    //     child: Home_Screen(),
    //     isIos: true,
    //   ),
    // );
    // }
  } else {
    snackBarCalled(context, "can't split error!", Colors.red);
  }
  acceptReset.value = false;
}

void splitUserAmount(context, String amount, List members, String name) async {
  List nameList = [];
  members.forEach((element) {
    nameList.add({'member': (element['id']), 'markAsComplete': false});
  });

  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/split'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "name": name,
      "amount": amount,
      "paymentStatus": nameList,
      "image": ''
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    splitID.value = body['id']['_id'];

    members.forEach((e) {
      sendNotificationsToDevice(e['id'], context,
          "${userName.value} Has Send U a Split Bill..Of ${name} Of ${amount}");
    });

    snackBarCalled(
        context, "The split amount has been sent to users!", Colors.black);
    addTransaction(amount, "Split Bill", name, context, 'cash', true);

    // addSocketMessage(members);
    //   Navigator.push(
    //   context,
    //   PageTransition(
    //     type: PageTransitionType.fade,
    //      duration: Durations.long1,
    //     child: Home(),
    //     isIos: true,
    //   ),
    // );
    // }
  } else {
    snackBarCalled(context, "can't split error!", Colors.red);
  }
  acceptReset.value = false;
}

void aboutuser(context, String about) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse('https://stakeplot.in/api/v1/user/updateprofile'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "aboutMe": about,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(context, "User information has been updated successfully!",
        Colors.black);
  } else {
    snackBarCalled(context,
        "An error occurred while updating user information!", Colors.red);
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
    snackBarCalled(
        context, "The account has been added successfully!", Colors.black);
    Navigator.pushNamed(context, '/home');
  } else {
    snackBarCalled(
        context, "An error occurred while adding the account!", Colors.red);
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
      snackBarCalled(context, "User information has been updated successfully!",
          Colors.black);
      // getUserInfomations();
      avatar.value = changeAvater.value;
      userName.value = controller['name']!.text.toString();
      Phone.value = controller['Number']!.text.toString();
      number.value = controller['Number']!.text.toString();
      dob.value = controller['dob']!.text.toString();
    } else {
      // snackBarCalled(context, "can't edit User Info error!", Colors.red);
    }
  } catch (e) {}
}
