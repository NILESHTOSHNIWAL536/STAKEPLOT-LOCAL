import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/components/transactions_content.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';

class TransactionContainer extends StatelessWidget {
  final TransactionModel transaction;
  final String id;
  final int index;
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
  final String type;
  final FontSizeFactor fontSizes;
  final Color amtColor;
  final bool isExpanded;
  final BuildContext context;

  const TransactionContainer({
    required this.transaction,
    required this.id,
    required this.index,
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
    required this.type,
    required this.fontSizes,
    required this.amtColor,
    required this.isExpanded,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isExcluded
          ? () => _showExcludeConfirmationDialog(context, transaction.id, index)
          : () => _handleTap(context, transaction, id, index, isManual, hide),
      onLongPress: isExcluded || hide || isExpanded
          ? null
          : () {
              showCheckBox.value = true;
              HapticFeedback.mediumImpact();
            },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            vertical: fontSizes.margin / 2, horizontal: fontSizes.margin),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: !isReview
              ? Border.all(color: Colorcodes.greyLight, width: 0.1)
              : Border.all(color: Colorcodes.red, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(155, 155, 155, 0.25),
              offset: const Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              TransactionContent(
                transaction: transaction,
                isExcluded: isExcluded,
                isReview: isReview,
                isManual: isManual,
                isSplit: isSplit,
                hide: hide,
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
              ),
              if (isExcluded)
                Positioned(
                  top: 0,
                  right: -2,
                  child: SvgPicture.asset(
                    'assets/icons/Home-page/notMIne.svg',
                    height: 20,
                    width: 60,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExcludeConfirmationDialog(
      BuildContext context, String id, int index) async {
    final shouldExclude = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 220,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  textStyle(
                    context: context,
                    text: "Include transaction?",
                    c: AppColors.bg1,
                    fontsize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  textStyle(
                    context: context,
                    text:
                        "Are you sure you want to add this transaction? It will be included in your category spending and reflected in your insights.",
                    c: AppColors.grey,
                    fontsize: 14,
                    fontWeight: FontWeight.w600,
                    iswrap: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.bg1),
                          ),
                          child: textStyle(
                            context: context,
                            text: "Cancel",
                            c: AppColors.grey,
                            fontsize: 14,
                            fontWeight: FontWeight.w600,
                            iswrap: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: textStyle(
                            context: context,
                            text: "Include",
                            c: AppColors.backgroundColor,
                            fontsize: 14,
                            fontWeight: FontWeight.w600,
                            iswrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (shouldExclude == true) {
      excludeCashFlowTransaction(index, false, context, id);
    }
  }

  void _handleTap(BuildContext context, TransactionModel transaction, String id,
      int index, bool isManual, bool hide) {
    if (showCheckBox.value) {
      bool isChecked = redioButton.containsKey(id);
      if (!isChecked) {
        redioButton[id] = id;
        redioButtonIndex[id] = index;
        balanceOutList[id] = transaction;
        redioButtonAmount[id] = transaction.type == "DEBIT"
            ? 0 - transaction.amount
            : transaction.amount;
        if (isManual) addManually.add(id);
        HapticFeedback.selectionClick();
      } else {
        redioButton.remove(id);
        redioButtonIndex.remove(id);
        balanceOutList.remove(id);
        redioButtonAmount.remove(id);
        if (isManual) addManually.remove(id);
        HapticFeedback.selectionClick();
      }
    } else if (!isManual && !hide) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return TransactionDetailsPage(transaction: transaction);
        },
      );
    } else if (isManual) {
      snackBarCalled(context, "This transaction was added manually.");
    }
  }
}
