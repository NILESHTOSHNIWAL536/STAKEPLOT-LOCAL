

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';

class GroupTransactions extends StatefulWidget 
{
const GroupTransactions({ Key? key }) : super(key: key);

  @override
  State<GroupTransactions> createState() => _GroupTransactionsState();
}

class _GroupTransactionsState extends State<GroupTransactions> {

 @override
  void initState() {
    super.initState();
    getGroupTransactions();
  }

  @override
  Widget build(BuildContext context){
    return Container(
         child: Obx(()=>!setGroupTransactions.value?  Spinner(size: 40,):getGroupItemList()),
     );
  }


  Widget getGroupItemList(){

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/1.4,
      child: ListView.builder(
        itemCount: groupTransactionList.length,
        itemBuilder: (context, index) {
          var transaction = groupTransactionList[index];
          return ListTile(
            title: Text(transaction['narrationPattern']),
            subtitle: Text(transaction['count']),
            trailing: Text(transaction['totalAmount'].toString()),
          );
        },
      ),
    );
  }



}

