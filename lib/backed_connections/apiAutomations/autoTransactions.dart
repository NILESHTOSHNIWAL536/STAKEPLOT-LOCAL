import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/repository/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';

import '../../Constants/app_styles.dart';
import '../../routes/route_transactions.dart';



void getAllAutoTransactions() async {
  var res = await getDataApiCall(BankTransactionRoutes.getPendingForReviewTransactions);
  if (getFlagOfResponse(res))
   {
    var data = jsonDecode(res.body);
    data = data['data'];
    autoTransactionList.clear();
    autoTransactionList.addAll(data);
    autoTransactionList.refresh();
    setAutoTransactions.value = true;
  }
}


void updateTransactionsBalanceOut(context,transactionId,int index,double amount)async
{
  var res =await postDataApiCall("${TransactionRoutes.updateGroupTransactions}/${transactionId}",{
      "amount":(amount).abs()
  });

  if(getFlagOfResponse(res))
  {
              (transactionsHistory[index]).balanceOut = (amount).abs();
              (transactionsHistory[index]).isBalanceOut = true;
              transactionsHistory.refresh();       
  }
}

Future<void> addTagToTransactions(context,transactionId,bool flag,int index)async
{

   var res =await postDataApiCall(BankTransactionRoutes.verifyPendingTransaction(transactionId: transactionId, isCorrect: flag),{
      "flag":flag
   });
  
  if(getFlagOfResponse(res))
  {
    autoTransactionList.removeAt(index);
    autoTransactionList.refresh();
    currentPage=1;
    getAllTransaction(context);
  }

}



void onChanedAutoTransactionStatus(context)async
{
     currentPage=1;
     isLoadingMore.value=false;
     transactionsHistory.clear();
     getAllTransactionHistory(context,false,false, isRefreshing: true);
}


Future<void> getCustomCategory(context)async
{
  var res = await getDataApiCall(BankTransactionRoutes.customCategory);
  if(getFlagOfResponse(res))
  {
    var data = jsonDecode(res.body);
    data = data['categories'];
    customCategoryList.clear();
    customCategoryList.addAll(data);
    customCategoryList.refresh();
    updateCusTagList();
    // Extract used imageUrls from category list
  }
}

void postCustomCategory(context,name,urlPath,narr)async
{
  var body =
  {
    "name":name,
    "imageUrl":urlPath,
    "narration":narr
  };
  
  var res = await postDataApiCall(BankTransactionRoutes.customCategory,body);

  if(getFlagOfResponse(res))
  {
    var data = jsonDecode(res.body);
    data = data["data"]['categories'];
    customCategoryList.clear();
    customCategoryList.addAll(data);
    customCategoryList.refresh();
    updateCusTagList();
    LoadTag.value=!LoadTag.value;
    custom=getthelist();
    Navigator.pop(context);
    snackBarCalled(context, SnackbarData().categoryAdded, Colors.green);
  }

}


void updateCusTagList(){
   List<String> usedImages = customCategoryList
        .map((e) => (e['imageUrl'] ?? '').toString())
        .toList();

    // Filter unused from tag list
    List<String> unusedImages = customTagList
        .where((img) => !usedImages.contains(img))
        .toList();

    customCategoryUnUsedList.clear();
    customCategoryUnUsedList.addAll(unusedImages);
}