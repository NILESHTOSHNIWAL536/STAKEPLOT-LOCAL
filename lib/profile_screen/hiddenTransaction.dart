import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactionhistoryWidget.dart';

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
            transaction: transaction,
            date: transaction['transactionTimestamp'],
            index: index,
            context: context,
            showBankLogo: true,
            bankLogo: transaction['bankLogo']?.toString(),
            onHide: hideTransaction, // Pass the hideTransaction function
            isHiddenScreen: true, // Indicate this is the hidden screen
          );
        },
      ),
    );
  }
}
