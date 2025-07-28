


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionCalender.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

class TransactionsSearchList extends StatefulWidget {
const TransactionsSearchList({ Key? key }) : super(key: key);

  @override
  State<TransactionsSearchList> createState() => _TransactionsSearchListState();
}

class _TransactionsSearchListState extends State<TransactionsSearchList> {
  @override
  Widget build(BuildContext context){
    return Container(
       width: MediaQuery.of(context).size.width/1.1,
       child: Column(
          children: (matchedKeywords.length > 4
                    ? matchedKeywords.sublist(0, 4)
                    : matchedKeywords).map((data)=> InkWell(
                            onTap: (){
                searchTextController.value=data;
                searchTextControllerBool.value=!searchTextControllerBool.value;
                setState(() {
                  searchController.value = TextEditingValue(
                        text: data,
                        selection: TextSelection.collapsed(offset: data.length),
                      );
                });
                onChanedAutoTransactionStatus(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width/1.1,
              padding: EdgeInsets.symmetric(horizontal: 5,vertical: 7),
               decoration: BoxDecoration(
                  border: Border.all(
                    width: .5,
                    color: Colorcodes.greyLight
                  )
               ),
                child:Row(
                  children: [
                    Container(
                       padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(4),
                         color: AppColors.primaryColor
                       ),
                       child: textStyle(context: context,text: data[0].toString(), 
                         fontWeight: FontWeight.bold,
                        fontsize: 23,
                        lineHeight: 1.3,
                        c: Colorcodes.white
                        ),
                    ),
                    const SizedBox(width: 10,),
                    textStyle(
                        context: context,
                        text: data,
                        fontWeight: FontWeight.bold,
                        fontsize: 23,
                        lineHeight: 1.3,
                        c: AppColors.primaryColor
                      ),
                 ])
            ),
          ) ).toList(),
       ),
    );
  }
}