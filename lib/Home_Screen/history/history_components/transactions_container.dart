import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_components/transactions_content.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';

import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/theme_helper.dart';
import '../../autoPays/CreateAutoPayFromTransactionScreen.dart';

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
  final bool fromAutoPay;
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
    required this.fromAutoPay,
  });
  void _navigateToAutoPayPage(
    BuildContext context,
    TransactionModel transaction,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAutoPayFromTransactionScreen(
          transaction: transaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isExcluded
          ? () => _showExcludeConfirmationDialog(context, transaction.id, index)
          : () {
              if (fromAutoPay) {
                _navigateToAutoPayPage(context, transaction);
              } else {
                _handleTap(context, transaction, id, index, isManual, hide);
              }
            },

      // onTap: isExcluded
      //     ? () => _showExcludeConfirmationDialog(context, transaction.id, index)
      //     : () => _handleTap(context, transaction, id, index, isManual, hide),
      onLongPress: isExcluded || hide || isExpanded || fromAutoPay
          ? null
          : () {
              showCheckBox.value = true;
              HapticFeedback.mediumImpact();
            },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            vertical: AppSizes.p6, horizontal: fontSizes.margin),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: !isReview
              ? Border.all(color: colors.border, width: 0.8)
              : Border.all(color: AppColors.redColor, width: 0.5),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              Column(
                children: [
                  isReview
                      ? SizedBox(height: fontSizes.padding)
                      : const SizedBox(height: 4),
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
                ],
              ),
              (isReview)
                  ? Positioned(
                      top: -2,
                      right: -1.6,
                      child: reviewTagTransactions(
                        isReview,
                        fontSizes.scaleFactor,
                        isSplit,
                        fontSizes.margin,
                        fontSizes.badgeSize,
                        fontSizes.fontSizeSmall,
                        context,
                        index,
                        transaction.id,
                      ))
                  : SizedBox(height: AppSizes.h10),
              if (isExcluded)
                Positioned(
                    top: 0,
                    right: -2,
                    child: AvatarProfileImageZero(
                        url: HomePageIcons.notMIne, width: 50, height: 50)),
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
        final colors = context.appColors;
        return Dialog(
          backgroundColor: colors.dialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 220,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  textStyle(
                    context: context,
                    text: "Include transaction?",
                    c: colors.onBackground,
                    fontsize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: AppSizes.h10),
                  textStyle(
                    context: context,
                    text:
                        "Are you sure you want to add this transaction? It will be included in your category spending and reflected in your insights.",
                    c: colors.secondaryText,
                    fontsize: 14,
                    fontWeight: FontWeight.w400,
                    iswrap: true,
                  ),
                  SizedBox(height: AppSizes.h16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: AppSizes.p8),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.border),
                          ),
                          child: textStyle(
                            context: context,
                            text: "Cancel",
                            c: colors.secondaryText,
                            fontsize: 14,
                            fontWeight: FontWeight.w600,
                            iswrap: true,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.w10),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: AppSizes.p8),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: textStyle(
                            context: context,
                            text: "Include",
                            c: Colors.white,
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionDetailsPage(
            transaction: transaction,
            index: index,
          ),
        ),
      );
      // showModalBottomSheet(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return TransactionDetailsPage(transaction: transaction);
      //   },
      // );
    } else if (isManual) {
      snackBarCalled(context, "This transaction was added manually.");
    }
  }
}
