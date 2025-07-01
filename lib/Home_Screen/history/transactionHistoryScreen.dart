import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dayWiseTransactions.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionCalender.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';

final TextEditingController searchController = TextEditingController();
FocusNode focusNodeSearchFeild = FocusNode();


class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final RxList<Map<String, dynamic>> filteredTransactions =
      RxList<Map<String, dynamic>>([]);
  final ScrollController scrollController = ScrollController();
  final RxList<Map<String, dynamic>> dayWiseTransactions =
      RxList<Map<String, dynamic>>([]);
      final RxBool isDateSummaryView = false.obs;
  // State to toggle views

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    addManually.clear();
    getAllTransactionHistory(context, false, false, isRefreshing: true);
    getDayWiseTransactions(context).then((data) {
      dayWiseTransactions.assignAll(data);
    });
    

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50) {
        getAllTransactionHistory(context, false, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: historyAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / .1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              getTextFeild(),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) => SafeArea(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: const BoxDecoration(
                                          color: AppColors.bg5,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: filterTransaction(context),
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(Icons.filter_alt_outlined,
                                    size:
                                        MediaQuery.of(context).size.height / 20,
                                    color: AppColors.finSpaceColor),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isDateSummaryView.value = !isDateSummaryView
                                        .value; // Toggle state
                                  });
                                },
                                child: Icon(
                                  isDateSummaryView.value
                                      ? Icons
                                          .calendar_today // Icon when collapsed
                                      : Icons
                                          .calendar_view_month, // Icon when expanded
                                  size: MediaQuery.of(context).size.height / 24,
                                  color: AppColors.finSpaceColor,
                                ),
                              ),
                            ],
                          ),
                          Obx(() => (groupTransactionList.length != 0 ||
                                  redioButton.isNotEmpty)
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: getTab(context),
                                )
                              : SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),

                  // Transaction History or Date Summary View
                  // Obx(() => Container(
                  //       width: MediaQuery.of(context).size.width,
                  //       height: MediaQuery.sizeOf(context).height /
                  //           ((groupTransactionList.length != 0 ||
                  //                   redioButton.isNotEmpty)
                  //               ? 1.35
                  //               : 1.25),
                  //       child: isDateSummaryView.value
                  //           ? DateSummaryView(
                  //               dayWiseTransactions: dayWiseTransactions,
                  //               onBack: () {
                  //                 setState(() {
                  //                   isDateSummaryView.value = false;
                  //                 });
                  //               },
                  //             )
                  //           : SingleChildScrollView(
                  //               controller: scrollController,
                  //               child: TransactionHistory(
                  //                 isYearView: false,
                  //                 isflag: true,
                  //                 showIcon: false,
                  //                 expandedPage: false,
                  //               ),
                  //             ),
                  //     ))
                Obx(() =>Container(
                  width: MediaQuery.of(context).size.width,
                        height: MediaQuery.sizeOf(context).height /
                            ((groupTransactionList.length != 0 ||
                                    redioButton.isNotEmpty)
                                ? 1.35
                                : 1.25),
            child: isDateSummaryView.value
                ? CalendarTransactionScreen()
                : SingleChildScrollView(
                    controller: scrollController,
                    child: TransactionHistory(
                      isYearView: false,
                      isflag: true,
                      showIcon: false,
                      expandedPage: false,
                    ),
                  ),
          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTextFeild() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.4,
      height: MediaQuery.of(context).size.width / 8,
      child: TextField(
        controller: searchController,
        focusNode: focusNodeSearchFeild,
        onChanged: (value) {
          onChanedAutoTransactionStatus(context);
        },
        decoration: InputDecoration(
          hintText: HomepageStringsDart().searchTransactions,
          hintStyle: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.likesharecommentCount,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.accentColor),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.accentColor),
                  onPressed: () {
                    clearTransactions(context: context, f: true);
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.bg5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.accentColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
        style: const TextStyle(color: AppColors.accentColor),
      ),
    );
  }
}
