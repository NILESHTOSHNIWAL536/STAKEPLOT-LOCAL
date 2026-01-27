



import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import 'predictions_category_icon.dart';




class CategoryAndSplitIcons extends StatelessWidget {
  final TransactionModel transaction;
  final String category;
  final bool isSplit;
  final double amount;
  final String formatAmountBalance;
  final int index;
  final double fontSizeMedium;
  final BuildContext context;

  const CategoryAndSplitIcons({
    required this.transaction,
    required this.category,
    required this.isSplit,
    required this.amount,
    required this.formatAmountBalance,
    required this.index,
    required this.fontSizeMedium,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            category == 'Untagged'
                ? getPredictedCategoryIcons(transaction, context, index)
                : GestureDetector(
                    onTap: category == 'Untagged'
                        ? null
                        : () {
                            tagName.value = category;
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return TagShowmodal(
                                  data: transaction,
                                  index: index,
                                );
                              },
                            );
                          },
                    child: Container(
                      padding:const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        
                        color:  AppColors.primaryColor.withOpacity(0.10), 
    // Border Radius: 2px
    borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: textStyleImage(
                        context: context,
                        text: toUpperCase(category),
                        c: AppColors.primaryColor,
                        fontsize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            ((transaction.isBalanceOut ?? false) && formatAmountBalance != "₹-1")
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       SizedBox(width: AppSizes.w10),
                      textStyle(
                        context: context,
                        text: " ( $formatAmountBalance )",
                        fontsize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
        if (isSplit)
          SizedBox(
            width: MediaQuery.sizeOf(context).width / 11,
            child: AvatarProfileImage(
              url: HomePageIcons.isSplit,
              width: 50,
              height: 50,
            ),
          ),
      ],
    );
  }
}


