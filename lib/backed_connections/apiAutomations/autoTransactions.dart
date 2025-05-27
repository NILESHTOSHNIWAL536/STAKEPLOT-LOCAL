import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';



void getAllAutoTransactions() async {
  var res = await getDataApiCall("${url}/transactionauto/pending-for-review-transactions/");
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



Future<void> addTagToTransactions(context,transactionId,bool flag,int index)async
{

  // http://localhost:5000/api/v1/transactionauto/verify-pending-transaction/:transactionId/:isCorrect
   var res =await postDataApiCall("${url}/transactionauto/verify-pending-transaction/${transactionId}/${flag}",{
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
     getAllTransactionHistory(context,false,false);
}


void getCustomCategory(context)async
{
  var res = await getDataApiCall("${url}/custom/custom-category");
  if(getFlagOfResponse(res))
  {
    var data = jsonDecode(res.body);
    data = data['categories'];
    customCategoryList.clear();
    customCategoryList.addAll(data);
    customCategoryList.refresh();
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
  
  var res = await postDataApiCall("${url}/custom/custom-category",body);

  if(getFlagOfResponse(res))
  {
    var data = jsonDecode(res.body);
    data = data["data"]['categories'];
    customCategoryList.clear();
    customCategoryList.addAll(data);
    customCategoryList.refresh();
    LoadTag.value=!LoadTag.value;
    custom=getthelist();
    Navigator.pop(context);
    snackBarCalled(context, SnackbarData().categoryAdded, Colors.green);
  }

}