

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/repository/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart'; 
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'predictions_category_icon.dart';




class ActionIcons extends StatelessWidget {
  final TransactionModel transaction;
  final String category;
  final String logo;
  final bool isManual;
  final bool hide;
  final double amount;
  final String subcategory;
  final int index;
  final double scaleFactor;
  final BuildContext context;

  const ActionIcons({
    required this.transaction,
    required this.category,
    required this.logo,
    required this.isManual,
    required this.hide,
    required this.amount,
    required this.subcategory,
    required this.index,
    required this.scaleFactor,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: HomepageStringsDart().hideTooltip,
          child: GestureDetector(
            onTap: hide
                ? () => _showHideConfirmationDialog(context, transaction.id, index)
                : null,
            child: hide
                ? Icon(
                    Icons.visibility_outlined,
                    color: AppColors.primaryColor,
                    size: 18,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        SizedBox(width: 8 * scaleFactor),
        Tooltip(
          message: HomepageStringsDart().splitWithFriendsTooltip,
          child: GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              transactionsId.value = transaction.id;
              await showCustomFriendsModalTransactionHistory(
                context,
                amount,
                false,
                category,
                subcategory,
                false,
              );
            },
            child: AvatarProfileImage(
              url: HomePageIcons.splitIcon,
              width: 120,
              height: 46,
            ),
          ),
        ),
        getRightSidePart(
          category,
          context,
          isManual,
          logo,
          scaleFactor,
          transaction,
          index,
        ),
      ],
    );
  }

  Future<void> _showHideConfirmationDialog(
      BuildContext context, String id, int index) async {
    final screenWidth = MediaQuery.sizeOf(context).width;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.95,
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundColor, Colors.grey[50]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                  child: textStyleOnly2(
                    context: context,
                    text: HomepageStringsDart().hideTransactionPrompt,
                    fontsize: screenWidth < 400 ? 14 : 16,
                    color: AppColors.bg1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Divider(
                  color: Colors.grey[200],
                  thickness: 1,
                  height: screenWidth * 0.06,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenWidth * 0.03,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: textStyleOnly2(
                        context: context,
                        text: HomepageStringsDart().noButton,
                        fontsize: screenWidth < 400 ? 14 : 16,
                        color: AppColors.bg1.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: screenWidth * 0.06,
                      color: Colors.grey[200],
                    ),
                    TextButton(
                      onPressed: () async {
                        await hideTransaction(index, !hide, context, id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenWidth * 0.03,
                        ),
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: textStyleOnly2(
                        context: context,
                        text: HomepageStringsDart().yesButton,
                        fontsize: screenWidth < 400 ? 14 : 16,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


