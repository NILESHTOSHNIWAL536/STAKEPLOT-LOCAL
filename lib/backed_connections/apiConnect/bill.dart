


import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

 void splitUserAmount(context, String amount, List members, String name,String subCategories,dynamic shareFriends) async {
    List nameList = [];
    double totalAmount=0.0;
    members.forEach((element) {
      String id=element['id'];
      var   data = shareFriends[id];
      totalAmount += data['Total'];
      nameList.add({'member': id, 'markAsComplete': false, 'amount':doubleToFixed(data['Total'].toString()) ,'isVegNonVeg':true ,'priorities':data});
    });
     print(nameList);
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
        'isVegNonVeg':true,
      }),
    );
    //printData(response,context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      splitID.value = body['id']['_id'];

      nameList.forEach((e)
       {
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

