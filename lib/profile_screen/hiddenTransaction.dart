
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

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
      padding: const EdgeInsets.all(2.0),
      child: ListView.builder(
        itemCount: hiddentrasactionsHistory.length,
        itemBuilder: (context, index) {
          TransactionModel transaction = hiddentrasactionsHistory[index];
          return HistoryTransactions(
             transaction:  transaction, 
             date:  transaction.transactionTimestamp.toString(), 
             index:  index,
             context:  context,
             hideReview:  false,
             isExpanded:  false,
             hide:  true);
        },
      ),
    );
  }
}