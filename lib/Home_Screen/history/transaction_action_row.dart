import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:lottie/lottie.dart';

class TransactionActionRow extends StatelessWidget {
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

  const TransactionActionRow({
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
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 360;
    final fontSizeMedium = 12.0 * scaleFactor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCategorySection(fontSizeMedium, screenWidth),
          isReview
              ? getTagButton(transaction, index, category, context, id)
              : _buildActionSection(scaleFactor, screenWidth),
        ],
      ),
    );
  }

  Widget _buildCategorySection(double fontSize, double screenWidth) {
    return Row(
      children: [
        GestureDetector(
          onTap: category == 'Untagged'
              ? null
              : () {
                  tagName.value = category;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => TagShowmodal(data: transaction, index: index),
                  );
                },
          child: Row(
            children: [
              textStyle(
                context: context,
                text: toUpperCase(category),
                c: AppColors.primaryColor,
                fontsize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              (transaction.isBalanceOut ?? false) && formatAmountBalance != "₹-1"
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: textStyle(
                        context: context,
                        text: " ( $formatAmountBalance )",
                        fontsize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        if (isSplit)
          Container(
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

  Widget _buildActionSection(double scaleFactor, double screenWidth) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hide Icon
        Tooltip(
          message: HomepageStringsDart().hideTooltip,
          child: GestureDetector(
            onTap: () {
              if (!hide) return;
              _showHideDialog(screenWidth);
            },
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

        // Split Friends
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

        // Untagged Tag Button
        if (category == 'Untagged')
          Tooltip(
            message: HomepageStringsDart().tagTooltip,
            child: GestureDetector(
              onTap: () {
                tagName.value = category;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => TagShowmodal(data: transaction, index: index),
                );
              },
              child: AvatarProfileImage(
                url: HomePageIcons.tagIcon,
                width: 1200,
                height: 46,
              ),
            ),
          ),

        // Exclude Button
        if (isExcluded)
          GestureDetector(
            onTap: () async {
              final shouldExclude = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Exclusion'),
                  content: const Text('Are you sure you want to exclude this transaction?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
              if (shouldExclude == true) {
                excludeCashFlowTransaction(index, false, context, transaction.id);
              }
            },
            child: Tooltip(
              message: "Exclude",
              child: AvatarProfileImage(
                url: HomePageIcons.cashIn,
                width: 1200,
                height: 46,
              ),
            ),
          ),

        SizedBox(width: 8 * scaleFactor),

        // Manual / Logo
        isManual
            ? SizedBox(
                height: 30,
                width: 30,
                child: Lottie.asset(
                  'assets/splashScreen/manualTransactionIcon.json',
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              )
            : Image.network(
                logo,
                width: 22,
                height: 22,
                fit: BoxFit.fitWidth,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator(strokeWidth: 2);
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 22),
              ),
      ],
    );
  }

  void _showHideDialog(double screenWidth) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: screenWidth * 0.95,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey[50]!],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: textStyleOnly2(
                  context: context,
                  text: hide
                      ? HomepageStringsDart().unhideTransactionPrompt
                      : HomepageStringsDart().hideTransactionPrompt,
                  fontsize: screenWidth < 400 ? 14 : 16,
                  color: AppColors.bg1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(color: Colors.grey[200], thickness: 1, height: screenWidth * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: textStyleOnly2(
                      context: context,
                      text: HomepageStringsDart().noButton,
                      fontsize: screenWidth < 400 ? 14 : 16,
                      color: AppColors.bg1.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(width: 1, height: screenWidth * 0.06, color: Colors.grey[200]),
                  TextButton(
                    onPressed: () async {
                      await hideTransaction(index, !hide, context, transaction.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
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
      ),
    );
  }
}
