  import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/lendMessage.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/repository/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

void addLendUserAmount(context, String amount, List members, String name,
      String subCategories) async {

    var response=await postDataApiCall('${url}/bill', {
        "userName": members[0]['name'],
        "avatarType": members[0]['avatar'],
        "billReceiverId": members[0]['id'],
        "avatarBackGround": members[0]['avatarBackGround'] ?? "#68B2A0",
        "category": name,
        "subcategory": subCategories,
        "type": "Lend Money",
        "amount": amount,
        'message': messageController.text.toString(),
        'dueDate': selectedDueDate.toString().substring(0, 10)
      });


    if (getFlagOfResponse(response)) 
    {
      members.forEach((e) {
        sendNotificationsToDevice(e['id'], context,"${ userController.userName.value} has sent u a lend bill..Of ${name} Of ${amount}");
      });
      snackBarCalled(context,SnackbarData().lendAmountSuccess, AppColors.accentColor);
      addTransaction(amount, "Lend Bill (${subCategories})", name, context, 'cash', false,false);
      getUserLend(context);
      messageController.clear();
      addedMembers.clear();
      addedUser.clear();
      selectedDueDate = null;
    } else {
      snackBarCalledfail(context,SnackbarData().lendAmountError, Colors.red);
    }

    acceptReset.value = false;
    cashInAndOut.value =false;
  }


  void getUserLend(context) async {
  String urlPath = "${url}/bill/lend";
  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {
    var his = jsonDecode(responce.body);
    var userLend = his['data'];
    lendAmountRemainders.clear();
    lendAmountRemainders.addAll(userLend);
    getlendUsers.value = !getlendUsers.value;
  }
}