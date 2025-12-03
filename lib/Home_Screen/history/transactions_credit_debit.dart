import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

import '../../components/shared_utils.dart';

class TransactionCreditDebitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 7.5,
      padding: const EdgeInsets.all(5.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          TransactionCard(
            title: 'This week transaction(s)',
            credits: lastWeekjson['credit'].toString(),
            debits: lastWeekjson['debit'].toString(),
          ),
          TransactionCard(
            title: 'This month transaction(s)',
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

  TransactionCard(
      {required this.title, required this.credits, required this.debits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width /
          (credits.toString().length <= 4
              ? 2.2
              : credits.toString().length <= 5
                  ? 2
                  : credits.toString().length <= 6
                      ? 1.8
                      : 1.6),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(137, 137, 137,
                0.25), // Equivalent to rgba(137, 137, 137, 0.25);
            blurRadius: 4, // Equivalent to box-shadow: 0 0 4px 0;
            offset: Offset(0, 0), // Equivalent to box-shadow: 0 0 4px 0;
          ),
        ],
        // border: Border.all(width: .3)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          textStyle(
              context: context,
              text: title,
              fontsize: 14,
              c: AppColors.grey,
              fontWeight: FontWeight.w600),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    credits.toString().length >= 6
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width /
                                4, // adjust as needed
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: textStyle(
                                  context: context,
                                  text: '+ ₹${formatMoneyIndian(credits)}',
                                  fontsize: 14,
                                  c: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        : textStyle(
                            context: context,
                            text: '+ ₹${formatMoneyIndian(credits)}',
                            fontsize: 14,
                            c: AppColors.primaryColor,
                            fontWeight: FontWeight.w700),
                    const SizedBox(
                      height: 4,
                    ),
                    textStyle(
                        context: context,
                        text: 'credits',
                        fontsize: 14,
                        c: AppColors.grey,
                        fontWeight: FontWeight.bold),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    debits.toString().length >= 6
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width /
                                5, // adjust as needed
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: textStyle(
                                  context: context,
                                  text: '- ₹${formatMoneyIndian(debits)}',
                                  fontsize: 14,
                                  c: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        : textStyle(
                            context: context,
                            text:'- ₹${formatMoneyIndian(debits)}',
                            fontsize: 14,
                            c: AppColors.primaryColor,
                            fontWeight: FontWeight.w700),
                    const SizedBox(
                      height: 4,
                    ),
                    textStyle(
                        context: context,
                        text: 'debits',
                        fontsize: 14,
                        c: AppColors.grey,
                        fontWeight: FontWeight.bold),
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
