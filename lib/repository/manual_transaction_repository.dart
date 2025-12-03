import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/amount_entry_modal.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/lendMessage.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/repository/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/repository/notification_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/payables_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';



// adding manual transaction api call function
void addTransaction(String amount, String subCategory, String categories,
    BuildContext context, String dropdownValue,
    [bool isSplit = false, bool snackBar = true]) async {
  var body = {
    'amount': amount.toString(),
    'category': categories.toString(),
    'label': subCategory.toString(),
    'account': dropdownValue.toString(),
    'room': {},
    'isSplit': isSplit,
    'isDebit': isDebit
  };
  final response = await postDataApiCall("${TransactionRoutes.addTransaction}", body);
  if (getFlagOfResponse(response)) {
    final body = json.decode(response.body);
    transactionsHistory.insert(
        0, TransactionModel.fromJson(body['data'][0]['data']));
    updateCatAndMoneyMap(context);
    userController.fetchUserInfo();
    Future.wait([
      () async {
        reloadHistory.value = !reloadHistory.value;
        setDonectChat.value = !setDonectChat.value;
        if (!isSplit && snackBar) {
          snackBarCalled(context, SnackbarData().transactionSuccess,
              AppColors.primaryColor);
        }
        Navigator.pop(context);
      }
    ].map((fn) => fn())).then((_) {
      // All actions are complete
    });
    getBudget();
  } else {
    snackBarCalledfail(context, SnackbarData().transactionAddFail, Colors.red);
  }

  cashInAndOut.value = false;
}



// for split 
 void splitUserAmount(

    BuildContext context,
    String totalAmount,
    List members,
    String category,
    String subcategory, {
    Map<String, double>? amounts,
    bool ismanual = true,
  }) async {
    UserController controller = ControllerManagement.userController;
    double? parsedTotalAmount = double.tryParse(totalAmount);
    if (parsedTotalAmount == null || parsedTotalAmount <= 0) {
      snackBarCalled(context, SnackbarData().invalidAmountEntered, Colors.red);
      return;
    }

    if (members.isEmpty) {
      snackBarCalledfail(context, SnackbarData().noMembersSelected, Colors.red);
      return;
    }

    // Prepare paymentStatus list with individual amounts
    List<Map<String, dynamic>> nameList = [];
    double calculatedTotal = 0.0;

    if (amounts != null) {
      members.forEach((element) {
        double memberAmount = amounts[element['id']] ?? 0.0;
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': memberAmount,
        });
        calculatedTotal += memberAmount;
      });
      // Include the user's amount if present
      if (amounts.containsKey(userController.userId.value)) {
        double userAmount = amounts[userController.userId.value]!;
        nameList.add({
          'member': userController.userId.value,
          'markAsComplete': false,
          'amount': userAmount,
        });
        calculatedTotal += userAmount;
      }
    } else {
      double amountPerPerson = parsedTotalAmount / (members.length + 1);
      members.forEach((element) {
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': amountPerPerson,
        });
        calculatedTotal += amountPerPerson;
      });
      nameList.add({
        'member': userController.userId.value,
        'markAsComplete': false,
        'amount': amountPerPerson,
        'avatarBackGround': userController.avatarBackGround.value
      });
      calculatedTotal += amountPerPerson;
    }

    // Verify total matches
    if ((calculatedTotal - parsedTotalAmount).abs() > 0.01) {
      // Allow small floating-point errors

      return;
    }

   

    final response = await postDataApiCall('$url/split', 
        {
        "subcategory": subcategory,
        "category": category,
        "amount": calculatedTotal,
        "ismanual": true,
        "transactionId": !ismanual ? transactionsId.value : "",
        "paymentStatus": nameList,
        "image": '',
      }
    );

    if (getFlagOfResponse(response)) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];

      // Send notifications and socket messages with individual amounts
      for (var member in members) {
        double memberAmount = amounts?[member['id']] ??
            (parsedTotalAmount / (members.length + 1));
        String formattedAmount = memberAmount.toStringAsFixed(2);

        sendNotificationsToDevice(
            member['id'],
            context,
            "${controller.userName.value} has sent you a Split Bill of $category ($subcategory) for ₹$formattedAmount",
            "/chat");
        addSocketMessage(
          [member],
          formattedAmount,
          category,
          splitID.value,
          parsedTotalAmount,
        );
        // searchController.clear();
        // currentPage=1;
        // isLoadingMore.value=false;
        // getAllTransaction(context);
      }
     if (!context.mounted) return;
      snackBarCalled(context, SnackbarData().splitAmountSent);
    } else {
      snackBarCalledfail(context, SnackbarData().splitError, Colors.red);
    }

    acceptReset.value = false;
  }

 void addSocketMessage(
    List addedUser,
    String amount,
    String splitName,
    String splitID,
    double parsedTotalAmount,
  ) {
    if (addedUser.isEmpty) {
      return;
    }
    UserController controller = ControllerManagement.userController;
    for (var rec in addedUser) {
      String room1 = rec['name'] + controller.userName.value;
      String room2 = controller.userName.value + rec['name'];
      String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

      var jsonData = {
        "messageType": "split",
        "receiver": rec['id'],
        "sender": userController.userId.value,
        "message": null,
        "image": null,
        "poll": null,
        "post": null,
        "split": {
          "BillName": splitName,
          "Amount": parsedTotalAmount,
          "Share": amount,
          "isPaid": false,
          "splitId": splitID,
        },
        "roomId": roomId,
      };

      try {
        socketManualTransaction.emit("joinRoom", roomId);
        socketManualTransaction.emit("message", jsonData);
        String userToSend =
            rec['name'] + rec['name']; // Fix concatenation if needed
        socketManualTransaction.emit("LoadCharts", {"roomId": userToSend});
      } catch (e) {}
    }
  }


// lend api call functions
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
      // getUserLend(context);
      getRemainders(context);
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


  // void getUserLend(context) async {
//   String urlPath = "${url}/bill/lend";
//   var responce = await getDataApiCall(urlPath);

//   if (getFlagOfResponse(responce)) {
//     var his = jsonDecode(responce.body);
//     var userLend = his['data'];
//     lendAmountRemainders.clear();
//     lendAmountRemainders.addAll(userLend);
//     getlendUsers.value = !getlendUsers.value;
//   }
// }