import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/user_chat/chat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

void splitUserAmount(context, String amount, List members, String name,
    String subCategories, dynamic shareFriends) async {
  List nameList = [];
  double totalAmount = 0.0;
  members.forEach((element) {
    String id = element['id'];
    var data = shareFriends[id];
    totalAmount += data['Total'];
    nameList.add({
      'member': id,
      'markAsComplete': false,
      'amount': doubleToFixed(data['Total'].toString()),
      'isVegNonVeg': true,
      'priorities': data
    });
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
      "subcategory": subCategories,
      "category:": name,
      "amount": totalAmount,
      "paymentStatus": nameList,
      "image": '',
      'isVegNonVeg': true,
    }),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    splitID.value = body['id']['_id'];

    nameList.forEach((e) {
      sendNotificationsToDevice(e['id'], context,"${userName.value} has shared a split bill..Of ${name} totaling ${e['amount']}","/remainder");
    });

    snackBarCalled(
        context, "Split amount successfully dispatched!", Colors.black);
    // addTransaction(amount, "Split Bill (${subCategories})", name, context, 'cash', true);
    Navigator.pop(context);
  } else {
    snackBarCalled(context, "Failed to split the amount!", Colors.red);
  }
  acceptReset.value = false;
}

void addSocketMessage(
    addedUser, String amount, String splitName, String splitID) {
  if (addedUser.isEmpty) {
    return;
  }

  // int index=0;

  addedUser.forEach((rec) {
    String room1 = rec['name'] + userName.value;
    String room2 = userName.value + rec['name'];
    // index++;
    String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

    var jsonData = {
      "messageType": "split",
      "receiver": rec['id'],
      "sender": currentId.value,
      "message": null,
      "image": null,
      "poll": null,
      "post": null,
      "split": {
        "BillName": splitName,
        "Amount": amount,
        "Share": ((double.parse(amount) / (addedUser.length + 1)).toString()),
        "isPaid": false,
        "splitId": splitID,
      },
      "roomId": roomId,
    };

    socket.emit("joinRoom", roomId);
    socket.emit("message", jsonData);
    String userToSend = rec['name'] + "" + rec['name'];
    socket.emit("LoadCharts", {
      "roomId": userToSend,
    });
  });
}

void splitUserAmount2(
  dynamic context,
  String amount,
  List members,
  String name,
  String subCategories,
  dynamic shareFriends,
) async {
  List nameList = [];
  double totalAmount = 0.0;
  double perFriendShare = double.parse(shareFriends.toString());

  print(
      "Starting splitUserAmount2 with amount: $amount, name: $name, perFriendShare: $perFriendShare");

  members.forEach((element) {
    String id = element['id'];
    totalAmount += perFriendShare;
    nameList.add({
      'member': id,
      'markAsComplete': false,
      'amount': doubleToFixed(perFriendShare.toString()),
      'isVegNonVeg': true,
    });
    print("Added member: $id, current totalAmount: $totalAmount");
  });

  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  print("Access token retrieved: $accessToken");

  final response = await http.post(
    Uri.parse('${url}/split'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "name": name,
      "subcategory": subCategories,
      "category": name,
      "amount": totalAmount,
      "paymentStatus": nameList,
      "image": '',
      //"isVegNonVeg": true,
    }),
  );

  print("Response status code: ${response.statusCode}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    splitID.value = body['id']['_id'];
    print("Split ID retrieved: ${splitID.value}");

    List<String> messagedMembers = [];

    for (var member in members) {
      String memberId = member['id'];
      String memberName = member['name'] ?? 'Unknown';

      print("Processing member: $memberName with ID: $memberId");
      addChatSplitAmount(context, name, amount, memberId, members);

      // Send notification
      try {
        sendNotificationsToDevice(
          memberId,
          context,
          "${userName.value} has sent you a Split Bill of $name for $perFriendShare",
          "/remainder"
        );
        print("Notification sent to $memberName");
      } catch (notificationError) 
      {
        snackBarCalled(context, "split successful, but notification failed for $memberId");
        print("Notification failed for $memberId: $notificationError");
      }
    }
  } else {
    snackBarCalled(context, "Can't split - error! ${response.statusCode}");
    print("Error response: ${response.body}");
  }
  acceptReset.value = false;
}
