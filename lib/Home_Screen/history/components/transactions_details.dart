

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'icon_split_hide.dart';


class TransactionDetails extends StatelessWidget {
  final TransactionModel transaction;
  final bool isExcluded;
  final bool isReview;
  final bool isManual;
  final bool isSplit;
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
  final bool hide;

  const TransactionDetails({
    required this.hide,
    required this.transaction,
    required this.isExcluded,
    required this.isReview,
    required this.isManual,
    required this.isSplit,
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
    return Obx(()=> Container(
      width: MediaQuery.of(context).size.width / (showCheckBox.value ? 1.2 : 1.1),
      padding: EdgeInsets.only(
          top: isExcluded ? 0 : fontSizes.padding / 6,
          bottom: isExcluded ? 0 : fontSizes.padding / 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (isManual || isReview)
              ? reviewTagTransactions(
                  isReview,
                  fontSizes.scaleFactor,
                  isSplit,
                  fontSizes.margin,
                  fontSizes.badgeSize,
                  fontSizes.fontSizeSmall,
                  context,
                  index,
                  transaction.id,
                )
              : const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: fontSizes.padding),
            child: Row(
              children: [
                isExcluded
                    ? getIconAvtar(30, category, fontSizes.scaleFactor / 2)
                    : getIconAvtar(fontSizes.avatarSize, category, fontSizes.scaleFactor),
                SizedBox(width: fontSizes.padding),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width / 3.3,
                            child: textStyle(
                              context: context,
                              text: !isManual ? nameOfUser : transaction.subcategory,
                              c: AppColors.accentColor,
                              fontsize: fontSizes.fontSizeMedium,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              textStyle(
                                context: context,
                                text: formatAmount,
                                c: amtColor,
                                fontsize: fontSizes.fontSizeLarge,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ),
                      textStyle(
                        context: context,
                        text: isManual ? formattedDateManual : formattedDate,
                        c: AppColors.primaryColor.withOpacity(0.7),
                        fontsize: fontSizes.fontSizeSmall,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          isExcluded ? const SizedBox(height: 10) : const SizedBox.shrink(),
          isExcluded
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconsForHideUpdateSplit(
                  iconSize:   fontSizes.iconSize,
                  padding:   fontSizes.padding,
                  category:   category,
                 amount:    amount,
                 logo:    logo,
                 context:    context,
                 index:    index,
                 subcategory:    transaction.subcategory,
                 transaction:    transaction,
                  isReview:   isReview,
                  id:   transaction.id,
                   isManual:  isManual,
                   hide:  hide,
                   isSplit:  isSplit,
                   isExcluded:  isExcluded,
                   formatAmountBalance:  formatAmountBalance,
                  ),
                ),
          (isManual || isReview)
              ? const SizedBox(height: 0)
              : isExcluded
                  ? const SizedBox.shrink()
                  : SizedBox(height: fontSizes.padding / 2),
        ],
      ),
    ));
  }
}

