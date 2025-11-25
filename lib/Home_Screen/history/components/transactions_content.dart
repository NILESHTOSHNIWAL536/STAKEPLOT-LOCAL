
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/components/transactions_checkbox.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter/services.dart';
import 'transactions_details.dart';



class TransactionContent extends StatelessWidget {
  final TransactionModel transaction;
  final bool isExcluded;
  final bool isReview;
  final bool isManual;
  final bool isSplit;
  final bool hide;
  final String category;
  final String logo;
  final double amount;
  final String formatAmount;
  final String formatAmountBalance;
  final String nameOfUser;
  final String formattedDate;
  final String formattedDateManual;
  final int index;
  final FontSizeFactor fontSizes;
  final Color amtColor;
  final BuildContext context;

  const TransactionContent({
    required this.transaction,
    required this.isExcluded,
    required this.isReview,
    required this.isManual,
    required this.isSplit,
    required this.hide,
    required this.category,
    required this.logo,
    required this.amount,
    required this.formatAmount,
    required this.formatAmountBalance,
    required this.nameOfUser,
    required this.formattedDate,
    required this.formattedDateManual,
    required this.index,
    required this.fontSizes,
    required this.amtColor,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        
        SizedBox(height: isExcluded ? 8 : 0),
        Container(
          padding: EdgeInsets.only(top: isExcluded ? 0 : fontSizes.padding / 6),
          child: Row(
            children: [
              
              TransactionCheckbox(
                transaction: transaction,
                index: index,
                isExcluded: isExcluded,
                isManual: isManual,
                hide: hide,
                fontSizes: fontSizes,
                context: context,
              ),
              TransactionDetails(
                transaction: transaction,
                isExcluded: isExcluded,
                isReview: isReview,
                isManual: isManual,
                isSplit: isSplit,
                category: category,
                logo: logo,
                amount: amount,
                formatAmount: formatAmount,
                formatAmountBalance: formatAmountBalance,
                nameOfUser: nameOfUser,
                formattedDate: formattedDate,
                formattedDateManual: formattedDateManual,
                index: index,
                fontSizes: fontSizes,
                amtColor: amtColor,
                context: context,
                hide: hide,
              ),
          
              
            ],
          ),
        ),
      ],
    );
  }
}
