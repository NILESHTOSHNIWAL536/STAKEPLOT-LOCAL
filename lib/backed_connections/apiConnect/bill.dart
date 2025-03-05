import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/user_chat/chat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
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
      sendNotificationsToDevice(e['id'], context,
          "${userName.value} has send u a Split Bill..Of ${name} Of ${e['amount']}");
    });

    snackBarCalled(context, "Split amount sent to users!", Colors.black);
    // addTransaction(amount, "Split Bill (${subCategories})", name, context, 'cash', true);
    Navigator.pop(context);
  } else {
    snackBarCalled(context, "can't split error!", Colors.red);
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

    members.forEach((element) {
      String id = element['id'];
      totalAmount += perFriendShare;
      nameList.add({
        'member': id,
        'markAsComplete': false,
        'amount': doubleToFixed(perFriendShare.toString()),
        'isVegNonVeg': true,
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
        "category": name,
        "amount": totalAmount,
        "paymentStatus": nameList,
        "image": '',
        //"isVegNonVeg": true,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];

      List<String> messagedMembers = [];

      for (var member in members) {
        String memberId = member['id'];
       
        String memberName = member['name'] ?? 'Unknown';

       addChatSplitAmount(context, name, amount, memberId, members);
        
        // Send notification
        try {

           sendNotificationsToDevice(
            memberId,
            context,
            "${userName.value} has sent you a Split Bill of $name for $perFriendShare",
          );
         
        } catch (notificationError) {
          snackBarCalled(context, "split successful, but notification failed for $memberId");
        }

        // Send socket message separately
  
      }



     
    } else {
       snackBarCalled(context, "Can't split - error! ${response.statusCode}");

    }
    acceptReset.value = false;
  }