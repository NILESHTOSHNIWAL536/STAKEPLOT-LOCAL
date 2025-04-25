import 'dart:convert';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_transactions.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactionhistoryWidget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';

RxBool reloadHistory = false.obs;
RxString selectedValue = "30".obs;
RxString selectedValueType = "days".obs;
RxBool getPdgLoader = false.obs;
RxMap<int, double> swipeOffsets = <int, double>{}.obs;
RxList<Map<String, dynamic>> hiddenTransactions = <Map<String, dynamic>>[].obs;
// AnimationController? _animationController;

class TransactionHistory extends StatefulWidget {
  /// Optional
  final bool? isYearView;
  final bool? isflag;
  final bool? showIcon;
  bool expandedPage;
  bool pageTransition;
  TransactionHistory(
      {this.isflag = false,
      this.showIcon = false,
      this.isYearView = false,
      this.pageTransition = false,
      this.expandedPage = false,
      super.key});
  // const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with SingleTickerProviderStateMixin {
  final _scrollController2 = ScrollController();
  final Map<int, double> swipeOffsets = {};
  final List<Map<String, dynamic>> hiddenTransactions = [];
  final targetKey = GlobalKey();
  BuildContext? _stableContext;
  // For smooth animations

  @override
  void initState() {
    super.initState();
    _stableContext = context;
    if (!widget.expandedPage) currentPage = 1;

    // getAllTransactionHistory(context, widget.isflag!, widget.isYearView!);
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 200),
    // );
    _scrollController2.addListener(() {
      if (_scrollController2.position.pixels >=
          _scrollController2.position.maxScrollExtent - 100) {
        getAllTransactionHistory(
          context,
          widget.isflag!,
          widget.isYearView!,
        ); // Fetch next page
      }
    });
    // if(!widget.expandedPage) isLoadingMore.value=false;
    getAllTransactionHistory(context, widget.isflag!, widget.isYearView!,
        isRefreshing: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stableContext ??= context;
  }

  @override
  void dispose() {
    _scrollController2.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.accentColor),
                ),
                if (!(widget.showIcon ?? false)) ...[
                  InkWell(
                    onTap: () {
                      showModalForPdfDownload(context);
                    },
                    child: const Icon(
                      Icons.backup_sharp,
                      size: 30,
                      color: AppColors.accentColor,
                    ),
                  ),
                ]
              ],
            ),
            (widget.showIcon ?? false)
                ? SizedBox(
                    height: 15,
                  )
                : Obx(() => allOrGroupTransactionsName.value ==
                        StringConstant.allTransactions
                    ? getTabsForTransactions()
                    : getTabsForTransactions()),

            //  getlist()
            // Obx(() => reloadHistory.value ? getlist() : getlist())
            // (widget.showIcon ?? false)? Obx(() => reloadHistory.value ? getlist() : getlist()):
            //        Obx(() => allOrGroupTransactionsName.value ==
            //             StringConstant.allTransactions
            //         ? Obx(() => reloadHistory.value ? getlist() : getlist())
            //         : GroupTransactions()),
            Obx(() {
              if (widget.showIcon ?? false) {
                return reloadHistory.value ? getlist() : getlist();
              } else {
                return allOrGroupTransactionsName.value ==
                        StringConstant.allTransactions
                    ? (reloadHistory.value ? getlist() : getlist())
                    : GroupTransactions();
              }
            })
          ],
        ),
      ),
    );
  }

  Widget getTabsForTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          tabItem(StringConstant.allTransactions),
          tabItem(StringConstant.pollTransactions),
        ],
      ),
    );
  }

  Widget tabItem(text) {
    bool f = text == allOrGroupTransactionsName.value;
    return InkWell(
      onTap: () {
        allOrGroupTransactionsName.value = text;
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: f ? AppColors.primaryColor : AppColors.bg5,
            border: Border.all(
              width: .5,
              color: AppColors.primaryColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: textStyle(
              context: context,
              text: text,
              c: f ? AppColors.bg5 : AppColors.primaryColor,
              fontsize: 15,
              fontWeight: FontWeight.w500)),
    );
  }

  void changeTheBool() {
    sectionReached.value = true;
    Navigator.pop(context);
  }

  Widget getlist() {
    // Group transactions by month and year
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    print(transactionsHistory);
    for (var transaction in transactionsHistory) {
      String? timestamp = transaction['transactionTimestamp']?.toString();
      if (timestamp != null) {
        try {
          // Parse as UTC and convert to IST
          DateTime utcDate = DateTime.parse(timestamp).toUtc();
          DateTime istDate = utcDate.subtract(Duration(hours: 5, minutes: 30));
          // Use only year and month for grouping to avoid day boundary issues
          String monthYearKey =
              DateFormat('MMMM yyyy').format(istDate); // e.g., "April 2025"
          groupedTransactions
              .putIfAbsent(monthYearKey, () => [])
              .add(transaction);
          // Debug: Log the timestamp and its IST conversion
        } catch (e) {
          continue;
        }
      }
    }

    // Sort months by date (descending order)
    List<String> sortedMonths = groupedTransactions.keys.toList();
    sortedMonths.sort((a, b) {
      DateTime dateA = DateFormat('MMMM yyyy')
          .parse(a, true)
          .toUtc()
          .subtract(Duration(hours: 5, minutes: 30)); // Convert UTC to IST
      DateTime dateB = DateFormat('MMMM yyyy')
          .parse(b, true)
          .toUtc()
          .subtract(Duration(hours: 5, minutes: 30)); // Convert UTC to IST
      return dateB.compareTo(dateA); // Most recent first
    });

    // Flatten the grouped transactions into a list for ListView.builder
    List<dynamic> displayItems = [];
    for (var monthYear in sortedMonths) {
      displayItems.add(monthYear); // Add the month header
      displayItems
          .addAll(groupedTransactions[monthYear] ?? []); // Null-safe access
    }

    // Show loader if no transactions are available
    // if (displayItems.isEmpty) {
    //   return const Center(
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       child: CircularProgressIndicator(
    //         color: AppColors.primaryColor,
    //       ),
    //     ),
    //   );
    // }

    // Add a loading indicator at the end if more data is being fetched
    if (isLoadingMore.value) {
      displayItems.add('loader'); // Use a distinct marker to avoid confusion
    }

    return ListView.builder(
      itemCount: displayItems.length,
      shrinkWrap: true,
      controller: _scrollController2,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = displayItems[index];
        // Case 1: Month Header
        if (item is String && item != 'loader') {
          String monthYear = item;
          // int transactionCount = groupedTransactions[monthYear]?.length ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthYear,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                ),
                // transactionCount == 0
                //     ? const SizedBox(
              ],
            ),
          );
        }

        // Case 2: Transaction Item
        else if (item is Map<String, dynamic>) {
          final transaction = item;
          int transactionIndex = transactionsHistory.indexOf(transaction);

          return Container(
            child: historyTransactions(
              transaction: transaction,
              date: transaction['transactionTimestamp']?.toString(),
              index: transactionIndex,
              context: context,
              onHide: hideTransaction,
              showBankLogo: true,
              bankLogo: transaction['bankLogo']?.toString(),
              isHiddenScreen: false,
            ),
          );
        }

        // Case 3: Loading Indicator
        else if (!isLoadingMore.value) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        return loadingDelay.value
            ? Container(width: 50, height: 50, child: Spinner())
            : transactionsHistory.isEmpty
                ? textStyle(context: context, text: "No Transactions")
                : SizedBox.shrink(); // Fallback for unexpected items
      },
    );
  }

  void extractTransaction(bool isYearView, List obj) {
    // print("------------------------ extra called...");
    // print(isYearView);
    if (isYearView) {
      getTransactionByYear(obj, selectedYear.value);
    } else {
      getTransactionByMonth(obj, selectedMonth.value);
    }
  }

  void getTransactionByYear(List obj, int y) {
    obj.forEach((ele) {
      if (ele is Map<String, dynamic> &&
          isCurrentYear(ele['transactionTimestamp']?.toString() ?? '', y)) {
        transactionsHistory.add(ele);
      }
    });
  }

  void getTransactionByMonth(List obj, int m) {
    obj.forEach((ele) {
      if (ele is Map<String, dynamic> &&
          isCurrentMonth(ele['transactionTimestamp']?.toString() ?? '', m)) {
        transactionsHistory.add(ele);
      }
    });
  }
}
