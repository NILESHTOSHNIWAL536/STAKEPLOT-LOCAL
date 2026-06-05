import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';

// Controller to manage pop-up state
class WeeklyPopupController extends GetxController {
  RxBool shouldShowPopup = false.obs;
  RxList<TransactionModel> topThreeTransactions = <TransactionModel>[].obs;

  // Get ISO week number
  int getWeekNumber(DateTime date) {
    String weekString = DateFormat('w').format(date);
    int? weekNumber = int.tryParse(weekString);
    if (weekNumber == null) {
      return 0;
    }
    return weekNumber;
  }

  // Check if current time is after Monday 10 AM
  bool isAfterMonday10AM(DateTime now) {
    return now.weekday >= DateTime.monday && now.hour >= 10;
  }

  // Check if pop-up should be shown for the user
  Future<bool> checkPopupStatus(String userId) async {
    if (userId.isEmpty) {
      return false;
    }
    final now = DateTime.now();
    final weekNumber = getWeekNumber(now);
    final year = now.year;
    final prefs = await SharedPreferences.getInstance();
    final popupKey = 'popup_shown_${userId}_$year$weekNumber';

    // Check if pop-up was already shown this week
    bool shown = prefs.getBool(popupKey) ?? false;

    if (shown) {
      return false; // Don't show if already shown
    }

    if (isAfterMonday10AM(now)) {
      return true;
    }

    return false;
  }

  // Mark pop-up as shown
  Future<void> markPopupAsShown(String userId) async {
    if (userId.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final weekNumber = getWeekNumber(now);
    final year = now.year;
    final prefs = await SharedPreferences.getInstance();
    final popupKey = 'popup_shown_${userId}_$year$weekNumber';
    await prefs.setBool(popupKey, true);
  }

  // Fetch top 3 transactions for the specific user
  Future<void> fetchTopThreeTransactions(BuildContext context, String userId) async {
    await getTopThreeTransactions(context, this, userId);
  }
}

// Custom TransactionCard widget
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String date;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
       width: MediaQuery.of(context).size.width / 1.3,
      margin: const EdgeInsets.symmetric(vertical: AppSizes.p4, horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(156, 156, 156, 0.25),
            offset: Offset(0, 0),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p12),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // color: Colors.green,
              width: MediaQuery.of(context).size.width / 4,
              child: Text(
                transaction.title.isEmpty ? 'Unknown' : transaction.title,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 11,
              // color:  AppColors.redColor,
              child: transaction.bankLogo != null && transaction.bankLogo!.isNotEmpty
                  ? Image.network(
                      transaction.bankLogo!,
                      width: 20,
                      height: 10,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_balance,
                        size: 20,
                        color: AppColors.accentColor,
                      ),
                    )
                  : const Icon(
                      Icons.account_balance,
                      size: 20,
                      color: AppColors.accentColor,
                    ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3.5,
              // color: Colors.amber,
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.type == 'DEBIT'
                        ? '-₹${transaction.amount.toStringAsFixed(2)}'
                        : '+₹${transaction.amount.toStringAsFixed(2)}',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    formatWhatsAppDate(convertStringToDateTime(date)),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Show the pop-up
Future<void> showWeeklyPopup(BuildContext context, String userId) async {
  final controller = Get.put(WeeklyPopupController(), tag: 'weeklyPopup_$userId');

  // Check if pop-up should be shown
  bool shouldShow = await controller.checkPopupStatus(userId);
  if (!shouldShow) {
    return;
  }

  // Fetch transactions
  await controller.fetchTopThreeTransactions(context, userId);

  // Only show pop-up if transactions are present
  if (controller.topThreeTransactions.isEmpty) {
    return;
  }

  // Show dialog
  await showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            minWidth: MediaQuery.of(context).size.width * 0.9, // Minimum width
            maxHeight: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
            minHeight: MediaQuery.of(context).size.height * 0.3, // Minimum height to ensure content fits
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.p8),
            decoration: BoxDecoration(
               color: AppColors.backgroundColor,
               borderRadius: BorderRadius.circular(16)

            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your Top 3 Transactions",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                ),
                SizedBox(height: AppSizes.h10),
                Obx(() {
                  return controller.topThreeTransactions.isEmpty
                      ? Text(
                          "No transactions found for this week.",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.accentColor,
                          ),
                        )
                      : Column(
                          children: controller.topThreeTransactions
                              .asMap()
                              .entries
                              .map((entry) => TransactionCard(
                                    transaction: entry.value,
                                    date: DateFormat('yyyy-MM-dd').format(
                                      entry.value.transactionTimestamp,
                                    ),
                                  ))
                              .toList(),
                        );
                }),
                SizedBox(height: AppSizes.h10),
                GestureDetector(
                  onTap: () async {
                    await controller.markPopupAsShown(userId);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                     width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.height / 26,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6)

                    ),
                    child: Center(
                      child: Text(
                        "Done",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.backgroundColor,
                        ),
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
