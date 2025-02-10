


import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

void splitUserAmount(context, String name, List members,Map<String, Map<String, double>> friendShares) async
   {
    List nameList = [];
   
    members.forEach((element) 
    {
      nameList.add({'member': (element['id']), 'markAsComplete': false,'isVegNonVeg':true,'priorities':{
           
      }});
    });

    // final SharedPreferences _pref = await SharedPreferences.getInstance();
    // var accessToken = _pref.getString("accessToken");

    // final response = await http.post(
    //   Uri.parse('${url}/split'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     "Authorization": "$accessToken",
    //   },
    //   body: jsonEncode({
    //     "name": name,
    //     "subcategory": subCategories,
    //     "category:": name,
    //     "amount": amount,
    //     "paymentStatus": nameList,
    //     "image": ''
    //   }),
    // );
    //printData(response,context);
    // if (response.statusCode == 200 || response.statusCode == 201) {
    //   final body = json.decode(response.body);

    //   splitID.value = body['id']['_id'];

    //   members.forEach((e) {
    //     sendNotificationsToDevice(e['id'], context,
    //         "${userName.value} has send u a Split Bill..Of ${name} Of ${amount}");
    //   });
     
    //   snackBarCalled(context, "Split amount sent to users!", Colors.black);
    //   // addTransaction(amount, "Split Bill (${subCategories})", name, context, 'cash', true);
    //   Navigator.pop(context);
    // } else {
    //   snackBarCalled(context, "can't split error!", Colors.red);
    // }
    acceptReset.value = false;
  }

  void addLendUserAmount(context, String amount, List members, String name,
      String subCategories) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    //  print('nameList');
    //  print(nameList);

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
    //printData(response,context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      members.forEach((e) {
        sendNotificationsToDevice(e['id'], context,
            "${userName.value} has sent u a lend bill..Of ${name} Of ${amount}");
      });

      snackBarCalled(context, "Lend amount sent to users!", Colors.black);
      addTransaction(
          amount, "Lend Bill (${subCategories})", name, context, 'cash', true);
     
      getUserLend(context);
      Navigator.pop(context);
  
    } else {
      snackBarCalled(context, "can't split ,error!", Colors.red);
    }
    acceptReset.value = false;
  }