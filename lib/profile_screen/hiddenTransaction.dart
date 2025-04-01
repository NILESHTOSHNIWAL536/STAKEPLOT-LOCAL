import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

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
                  child: Text('No hidden transactions.',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.accentColor)),
                )
              : hiddenTransactionsWidget())),
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
    final amount = transaction['amount']?.toString() ?? '0';
    final formattedDate = date != null ? formatDate(date) : 'Unknown Date';
    // String? s = imageMapForHistory[
    //     transaction['category'].toString().toLowerCase()];
    //String ImageUrl = Categories.link + s.toString();
    return GestureDetector(
      onLongPress: () {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Unhide'),
              content: Text('Do you want to unhide this transaction?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    hideTransaction(index, false, context, transaction['_id']);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colorcodes.greyLight, width: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colorcodes.greyLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AvatarProfileImage(
                        url: Categories.link +
                            (imageMapForHistory[category.toLowerCase()] ?? ''),
                        height: 16,
                        width: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: " $category",
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w600,
                              fontSize: 14,
                              lineHeight: 2.14,
                              color: AppColors.accentColor,
                            ),
                          ),
                          TextSpan(
                            text: " ($subcategory)",
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w400,
                              fontSize: 12,
                              lineHeight: 1.14,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  textStyle(
                    text: '₹$amount',
                    context: context,
                    fontWeight: FontWeight.bold,
                    fontsize: 15,
                  ),
                  const SizedBox(height: 6),
                  textStyle(
                    text: formattedDate,
                    context: context,
                    fontWeight: FontWeight.w300,
                    fontsize: 11,
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
