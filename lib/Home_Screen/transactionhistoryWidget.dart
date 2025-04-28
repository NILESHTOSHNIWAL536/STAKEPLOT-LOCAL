// lib/widgets/transaction_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';

Widget historyTransactions({
  required Map<String, dynamic> transaction,
  required String? date,
  required int index,
  required BuildContext context,
  required Function(int, bool, BuildContext, String)
      onHide, // Callback for hide/unhide
  bool showBankLogo = false, // Whether to show bank logo
  String? bankLogo, // Bank logo URL
  bool isHiddenScreen = false, // Flag to differentiate hide vs unhide
}) {
  final category = transaction['category']?.toString() ?? 'Uncategorized';
  final subcategory = transaction['subcategory']?.toString() ?? 'General';
  final double amount =
      double.parse(doubleToFixed((transaction['amount'] ?? 0.0).toString()));
  final amountT = formatMoneyIndian(amount.toString());
  final isManual = transaction['manualTransaction'] ?? false;
  final formattedDate =
      date != null ? (isManual?formatWhatsAppDate(convertStringToDateTime(date)):formatWhatsAppDate4(convertStringToDateTime(date)) ): 'Date';
  final narration = transaction['narration'] ?? 'Unnamed Group';
  List<String> parts = narration.split('/');
  if (parts.isEmpty || parts.length == 1) parts = narration.split('-');
  if (parts.isEmpty || parts.length == 1) parts = narration.split('&');
  if (parts.isEmpty || parts.length == 1) parts = narration.split(' ');

  String nameOfUser = parts.length >= 4
      ? parts[3]
      : parts.length >= 3
          ? parts[2]
          : parts.length >= 2
              ? parts[1]
              : parts[0];
  final type = transaction['type']?.toString() ?? '0';
  final amtColor = type == 'CREDIT'
      ? Colors.green.shade700
      : const Color.fromARGB(255, 207, 118, 113);
  final formatAmount = type == 'CREDIT' ? "+₹$amountT" : "-₹$amountT";

  // Responsive scaling with MediaQuery
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 360; // Base width: 360px
  final padding = 16.0 * scaleFactor;
  final margin = 12.0 * scaleFactor;
  final iconSize = 14.0 * scaleFactor;
  final avatarSize = 40.0 * scaleFactor;
  final fontSizeLarge = 14.0 * scaleFactor;
  final fontSizeMedium = 12.0 * scaleFactor;
  final fontSizeSmall = 10.0 * scaleFactor;
  final badgeSize = 20.0 * scaleFactor;

  // Reusable confirmation dialog
  Future<bool> showConfirmationDialog({
    required String message,
    required String confirmText,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            double screenWidth = MediaQuery.of(context).size.width;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              backgroundColor: Colors.transparent,
              child: Container(
                width: screenWidth * 0.85,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                      child: textStyleOnly2(
                        context: context,
                        text: message,
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
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: textStyleOnly2(
                            context: context,
                            text: "No",
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
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: textStyleOnly2(
                            context: context,
                            text: confirmText,
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
        ) ??
        false;
  }

  return GestureDetector(
    onTap: () {
      if (!isManual) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return TransactionDetailsPage(transaction: transaction);
          },
        );
      }
    },
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: margin, horizontal: margin),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * scaleFactor),
            gradient: LinearGradient(
              colors: [
                AppColors.backgroundColor.withOpacity(0.03),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8 * scaleFactor,
                offset: Offset(0, 3 * scaleFactor),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon, Narration, Amount
              Row(
                children: [
                  // Icon Container
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.button.withOpacity(0.8),
                          Colors.white.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                    ),
                    child: Center(
                      child: AvatarProfileImage(
                        url: Categories.link +
                            (imageMapForHistory[category.toLowerCase()] ??
                                'default_image.png'),
                        height: avatarSize * 0.5,
                        width: avatarSize * 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: padding),
                  // Narration and Amount
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width / 2.9,
                              child: Tooltip(
                                message: narration,
                                child: textStyle(
                                  context: context,
                                  text:  !isManual?nameOfUser:narration,
                                  c: AppColors.accentColor,
                                  fontsize: fontSizeMedium,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 4 * scaleFactor),
                            textStyle(
                              context: context,
                              text: formattedDate,
                              c: AppColors.primaryColor.withOpacity(0.7),
                              fontsize: fontSizeSmall,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                        textStyle(
                          context: context,
                          text: formatAmount,
                          c: amtColor,
                          fontsize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: padding / 2.5),
              // Bottom Row: Category and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category
                  Container(
                    width: MediaQuery.sizeOf(context).width / 3,
                    child: textStyle(
                      context: context,
                      text: category,
                      c: AppColors.accentColor,
                      fontsize: fontSizeMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Action Icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bank Logo (if applicable)
                      if (showBankLogo &&
                          bankLogo != null &&
                          bankLogo.isNotEmpty)
                        Image.network(
                          bankLogo,
                          width: 30,
                          height: 30,
                          fit: BoxFit.fitWidth,
                        ),
                      if (showBankLogo &&
                          bankLogo != null &&
                          bankLogo.isNotEmpty)
                        SizedBox(width: 8 * scaleFactor),
                      // Hide/Unhide Transaction
                      Tooltip(
                        message: isHiddenScreen ? 'Unhide' : 'Hide',
                        child: GestureDetector(
                          onTap: () async {
                            bool confirmed = await showConfirmationDialog(
                              message: isHiddenScreen
                                  ? "Do you want to unhide this transaction?\nThis action will make it visible again."
                                  : "Do you want to hide this transaction?\nThis action will move it to hidden transactions.",
                              confirmText: "Yes",
                            );
                            if (confirmed) {
                              onHide(index, !isHiddenScreen, context,
                                  transaction['_id']);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(6 * scaleFactor),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(8 * scaleFactor),
                            ),
                            child: Icon(
                              isHiddenScreen
                                  ? Icons.visibility
                                  : Icons.visibility_off_rounded,
                              color: AppColors.primaryColor,
                              size: iconSize,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scaleFactor),
                      // Friends Modal
                      Tooltip(
                        message: 'Split with Friends',
                        child: GestureDetector(
                          onTap: () async {
                            await showCustomFriendsModalTransactionHistory(
                              context,
                              amount,
                              false,
                              category,
                              subcategory,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(6 * scaleFactor),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(8 * scaleFactor),
                            ),
                            child: Icon(
                              Icons.group_add_rounded,
                              color: AppColors.primaryColor,
                              size: iconSize,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scaleFactor),
                      // Tag Action
                      Tooltip(
                        message: 'Tag',
                        child: GestureDetector(
                          onTap: () {
                            tagName.value = category;
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
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
                            padding: EdgeInsets.all(6 * scaleFactor),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(8 * scaleFactor),
                            ),
                            child: Icon(
                              Icons.tag_rounded,
                              color: AppColors.primaryColor,
                              size: iconSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Manual Badge
        if (isManual)
          Positioned(
            top: margin,
            left: margin + 4,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4 * scaleFactor,
                    offset: Offset(2 * scaleFactor, 2 * scaleFactor),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeSmall * 0.8,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// Reusable showCustomFriendsModal function (extracted for completeness)
Future<dynamic> showCustomFriendsModalTransactionHistory(
  BuildContext context,
  double amount,
  bool isLendMode,
  String category,
  String subcategory,
) async {
  return await showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (BuildContext context) {
      return NewFriendsUi(
        totalAmount: amount.toDouble(),
        userId: currentId.value,
        userName: userName.value,
        userAvatar: avatar.value,
        isLendMode: isLendMode,
        category: category,
        subcategory: subcategory,
        flag: true,
      );
    },
  );
}
