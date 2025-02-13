import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';

import 'package:intl/intl.dart';

class DebtDetailsScreen extends StatelessWidget {
  final Debt debt;

  DebtDetailsScreen({required this.debt});

  @override
  Widget build(BuildContext context) {
    double labelWidth = 100; // Set a fixed width for labels

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(debt.name),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.sizeOf(context).width / 1.1,
              decoration: BoxDecoration(
                color: AppColors.mt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AvatarProfileImage(
                              url: HomePageIcons.manualTransaction,
                              height: 28,
                              width: 28,
                            ),
                            textStyle(
                              context: context,
                              text: " ${debt.name} ",
                              fontsize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        Icon(Icons.more_horiz),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          rowItem("Loan type", debt.type, labelWidth, context),
                          SizedBox(height: Colorcodes.paddingSize/3,),
                          rowItem("Amount", "₹${debt.amount.toStringAsFixed(2)}", labelWidth, context),
                          SizedBox(height: Colorcodes.paddingSize/3,),
                          rowItem("Interest", "${debt.interest.toString()}", labelWidth, context),
                          SizedBox(height: Colorcodes.paddingSize/3,),
                          rowItem("Duration", "${debt.durationMonths.toString()} months", labelWidth, context),
                          SizedBox(height: Colorcodes.paddingSize/3,),
                          rowItem("Date", formattedDate(debt.date.toString()), labelWidth, context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowItem(String label, String value, double labelWidth, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: textStyle(
            context: context,
            text: label,
            fontsize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: textStyle(
            context: context,
            text: value,
            fontsize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String formattedDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  return DateFormat("d MMM yyyy").format(parsedDate);
}
