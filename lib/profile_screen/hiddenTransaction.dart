
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:lottie/lottie.dart';

class HiddenTransactionsScreen extends StatefulWidget {
  //final List<Map<String, String>> hiddenTransactions;
  const HiddenTransactionsScreen({
    super.key,
  });

  @override
  State<HiddenTransactionsScreen> createState() =>
      _HiddenTransactionsScreenState();
}

class _HiddenTransactionsScreenState extends State<HiddenTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    getHiddenTransactions(context);
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat("dd MMM yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text("History archives"),
      ),
      body: SafeArea(
          child: Obx(() => hiddentrasactionsHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       AvatarProfileImage(
                                        url: FinSpaceIcons.empty,
                                        height: 4.5,
                                        width: 4.5,
                                      ),
                      Text('No hidden transactions.',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.accentColor)),
                    ],
                  ),
                )
              :  hideTransactionReload.value? hiddenTransactionsWidget():hiddenTransactionsWidget())),
    );
  }

  Widget hiddenTransactionsWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: hiddentrasactionsHistory.length,
        itemBuilder: (context, index) {
          final transaction = hiddentrasactionsHistory[index];
          return historyTransactions(
              transaction, transaction['transactionTimestamp'], index);
        },
      ),
    );
  }
Widget historyTransactions(
    Map<String, dynamic> transaction, String? date, int index) {
  final category = transaction['category']?.toString() ?? 'Uncategorized';
  final subcategory = transaction['subcategory']?.toString() ?? 'General';
  final double amount = double.parse(
      doubleToFixed((transaction['amount'] ?? 0.0).toString()));
  final isManual = transaction['manualTransaction'] ?? false;
  final formattedDate = date != null
      ? formatWhatsAppDate4(convertStringToDateTime(date))
      : 'Date';
      final formattedDateManual =
      date != null ? formatWhatsAppDate(convertStringToDateTime(date)) : 'Date';
  final narration = transaction['narration'] ?? 'Unnamed Group';
  final type = transaction['type']?.toString() ?? '0';
  final amtColor = type == 'CREDIT'
      ? Colors.green.shade700
      : const Color.fromARGB(255, 207, 118, 113);
  final formatAmount = type == 'CREDIT' ? "+₹$amount" : "-₹$amount";
  final isSplit = transaction['isSplit'] ?? false;

  // Responsive scaling with MediaQuery
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 360; // Base width: 360px
  final padding = 16.0 * scaleFactor;
  final margin = 10.0 * scaleFactor;
  final iconSize = 14.0 * scaleFactor; // Smaller icons for simplicity
  final avatarSize = 40.0 * scaleFactor;
  final fontSizeLarge = 14.0 * scaleFactor;
  final fontSizeMedium = 12.0 * scaleFactor;
  final fontSizeSmall = 10.0 * scaleFactor;
  final badgeSize = 20.0 * scaleFactor;

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
                               width: MediaQuery.sizeOf(context).width/2.7,
                              child: Tooltip(
                                message: narration,
                                child: textStyle(
                                  context: context,
                                  text: narration.length > 20
                                      ? '${narration.substring(0, 20)}...'
                                      : narration,
                                  c: AppColors.accentColor,
                                  fontsize: fontSizeMedium,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 4 * scaleFactor),
                            textStyle(
                              context: context,
                              text: isManual
                                            ? formattedDateManual
                                            : formattedDate,
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
                  textStyle(
                    context: context,
                    text: category,
                    c: AppColors.accentColor,
                    fontsize: fontSizeMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  // Action Icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hide Trans
                       isManual
                                               ?
                                                  Container(
                            height: 30,
                            width: 30,
                            child: Lottie.asset(
                              'assets/splashScreen/manualTransactionIcon.json',
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error); // fallback UI
                              },
                            ),
                          ):SizedBox.shrink(),
                      Tooltip(
                        message: 'unHide',
                        child: GestureDetector(
                          onTap: () {
  //       // Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            double screenWidth = MediaQuery.sizeOf(context).width;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              backgroundColor: Colors.transparent, // For custom container
              child: Container(
                width: screenWidth * 0.85, // 85% of screen width
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
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
                    // Content
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                      child: textStyleOnly2(
                        context: context,
                        text:
                            "Do you want to unhide this transaction?\nThis action will make it visible again.",
                        fontsize: screenWidth < 400 ? 14 : 16,
                        color: AppColors.bg1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Divider
                    Divider(
                      color: Colors.grey[200],
                      thickness: 1,
                      height: screenWidth * 0.06,
                    ),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
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
                          onPressed: () async{
                            await hideTransaction(
                                index, false, context, transaction['_id']);
                            if (context.mounted) {
        Navigator.of(context).pop(); // Pop the dialog after hiding
      }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenWidth * 0.03,
                            ),
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: textStyleOnly2(
                            context: context,
                            text: "Yes",
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
      },
                          child: Container(
                            padding: EdgeInsets.all(6 * scaleFactor),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8 * scaleFactor),
                            ),
                            child: Icon(
                              Icons.visibility,
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
                            await showCustomFriendsModal(
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
                              borderRadius: BorderRadius.circular(8 * scaleFactor),
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
                            padding: EdgeInsets.all(6 * scaleFactor),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8 * scaleFactor),
                            ),
                            child: Icon(
                              Icons.tag_rounded,
                              color: AppColors.primaryColor,
                              size: iconSize,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scaleFactor),
                      // Details Action
                      
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Manual Badge
        if (isSplit)
          Positioned(
            top: margin,
            left: margin ,
            child:  Container(
            // width: badgeSize,
            // height: badgeSize,
            decoration: BoxDecoration(
             // color: AppColors.bg5,
              shape: BoxShape.circle,
             
            ),
            child: AvatarProfileImage(
                url: HomePageIcons.isSplit, width: 50, height:50)),
          ),
      ],
    ),
  );
}
}

Future<dynamic> showCustomFriendsModal(
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
  