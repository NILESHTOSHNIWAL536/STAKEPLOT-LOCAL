import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/routes.dart';

class TransactionCreditDebitScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
   
    return  Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/6.5,
        padding: const EdgeInsets.all(5.0),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            TransactionCard(
              title: 'Weekly Transaction',
              credits: lastWeekjson['credit'].toString(),
              debits: lastWeekjson['debit'].toString(),
            ),
            TransactionCard(
              title: 'Monthly Transaction',
              credits: lastmonthjson['credit'].toString(),
              debits: lastmonthjson['debit'].toString(),
            ),
          ],
        ),
      );
  }
}

class TransactionCard extends StatelessWidget {
  final String title;
  final String credits;
  final String debits;

  TransactionCard({required this.title, required this.credits, required this.debits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width /  (credits.toString().length<=4 ? 2.2 :  credits.toString().length<=5? 2: credits.toString().length<=6?1.8:1.6),
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: .3)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          textStyle(
            context: context,
            text:  title,
            fontsize: 16, 
            c: Colorcodes.black,
            fontWeight: FontWeight.bold
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     textStyle(
                      context: context,
                      text:  '+ ₹$credits',
                      fontsize: 16, 
                      c: AppColors.primaryColor,
                       fontWeight: FontWeight.bold
                    ),
                     const SizedBox(height: 4,),
                     textStyle(
                      context: context,
                      text: 'credits',
                      fontsize: 14, 
                      c: Colors.grey,
                       fontWeight: FontWeight.bold
                    ),
                    
                  ],
                ),
                Container(
                  height: 30,
                  child: VerticalDivider(
                     thickness: .9,
                     color: AppColors.greyCard,
                     width: 1,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textStyle(
                      context: context,
                      text:  '- ₹$debits',
                      fontsize: 16, 
                       c: AppColors.primaryColor,
                       fontWeight: FontWeight.bold
                    ),
                    const SizedBox(height: 4,),
                     textStyle(
                      context: context,
                      text: 'debits',
                      fontsize: 14, 
                     c: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}