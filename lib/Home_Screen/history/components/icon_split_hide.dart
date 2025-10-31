import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';

import 'action_icon.dart';
import 'category_splitIcons.dart';


class IconsForHideUpdateSplit extends StatelessWidget {
  final double iconSize;
  final double padding;
  final String category;
  final double amount;
  final String logo;
  final BuildContext context;
  final int index;
  final String subcategory;
  final TransactionModel transaction;
  final bool isReview;
  final String id;
  final bool isManual;
  final bool hide;
  final bool isSplit;
  final bool isExcluded;
  final String formatAmountBalance;

  const IconsForHideUpdateSplit({
    Key? key,
    required this.iconSize,
    required this.padding,
    required this.category,
    required this.amount,
    required this.logo,
    required this.context,
    required this.index,
    required this.subcategory,
    required this.transaction,
    required this.isReview,
    required this.id,
    required this.isManual,
    required this.hide,
    required this.isSplit,
    required this.isExcluded,
    required this.formatAmountBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 360;
    final fontSizeMedium = 12.0 * scaleFactor;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: (transaction.predictions != null &&
                transaction.predictions!.entries.length > 4 &&
                (transaction.isBalanceOut ?? false) &&
                formatAmountBalance != "₹-1")
            ? null
            : MediaQuery.of(context).size.width / ( showCheckBox.value? 1.2:1.1),
        height: MediaQuery.of(context).size.height / 20,
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CategoryAndSplitIcons(
              transaction: transaction,
              category: category,
              isSplit: isSplit,
              amount: amount,
              formatAmountBalance: formatAmountBalance,
              index: index,
              fontSizeMedium: fontSizeMedium,
              context: context,
            ),
            isReview
                ? getTagButton(transaction, index, category, context, id)
                : ActionIcons(
                    transaction: transaction,
                    category: category,
                    logo: logo,
                    isManual: isManual,
                    hide: hide,
                    amount: amount,
                    subcategory: subcategory,
                    index: index,
                    scaleFactor: scaleFactor,
                    context: context,
                  ),
          ],
        ),
      ),
    );
  }
}