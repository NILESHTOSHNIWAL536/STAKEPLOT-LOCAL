import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionCalender.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';

final TextEditingController searchController = TextEditingController();
FocusNode focusNodeSearchFeild = FocusNode();
final RxBool showFilter = false.obs; // NEW

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
    showFilter.value=false;
    addManually.clear();
    balanceOutList.clear();
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
    double screenHeight = MediaQuery.sizeOf(context).height;

    double calculatedHeight;

    if (showFilter.value || redioButton.isNotEmpty) {
      calculatedHeight = screenHeight / 1.52;
    } else if (showFilter.value && !isDateSummaryView.value) {
      calculatedHeight = screenHeight / 1.5;
    } else {
      calculatedHeight =
          (groupTransactionList.isNotEmpty || redioButton.isNotEmpty)
              ? screenHeight / 1.35
              : screenHeight / 1.25;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: historyAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Search Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              getTextFeild(),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      isDateSummaryView.value =
                                          !isDateSummaryView
                                              .value; // Toggle state
                                    });
                                  },
                                  child: !isDateSummaryView.value
                                      ? AvatarProfileImage(
                                          url: HomePageIcons.dayWiseIcon1,
                                          width: 70,
                                          height: 36)
                                      : AvatarProfileImage(
                                          url: HomePageIcons.dayWiseIcon2,
                                          width: 70,
                                          height: 36)),
                              InkWell(
                                onTap: () {
                                  showFilter.value = !showFilter
                                      .value; // Toggle the filter visibility
                                },
                                child: AvatarProfileImage(
                                    url: HomePageIcons.filterIcon,
                                    width: 66,
                                    height: 30),
                              ),
                             
                            ],
                          ),
                        ),
                        // !isDateSummaryView.value
                        //     ? Padding(
                        //         padding:
                        //             const EdgeInsets.only(left: 10, right: 2),
                        //         child: Obx(() => (groupTransactionList.length !=
                        //                     0 ||
                        //                 redioButton.isNotEmpty)
                        //             ? Padding(
                        //                 padding: const EdgeInsets.only(top: 8),
                        //                 child: getTab(context),
                        //               )
                        //             : SizedBox.shrink()),
                        //       )
                        //     : SizedBox(height: 10),
                            !isDateSummaryView.value
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 2),
                              child: Obx(() => (groupTransactionList.isNotEmpty ||
                                      redioButton.isNotEmpty)
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Obx(() => showCheckBox.value
                                          ? Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // Cancel Button
                                                  
                                                  
                                                  SelectButton("Selected (${redioButton.length})", context),
                                                  CancelButton("Cancel", context),
                                                 
                                                 
                                                ],
                                              ),
                                          )
                                          : getTab(context)),
                                    )
                                  : SizedBox.shrink()),
                            )
                          : SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                          ),
                          child: Obx(() => (redioButton.isNotEmpty && getBoolFalg())
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  left: 10, right: 2, top: 8),
                                child: getTagHideButtons(context),
                              )
                              : SizedBox.shrink()),
                        ),
                        Obx(() => (showFilter.value && getBoolFalg())
                            ? filterTransaction(context)
                            : SizedBox.shrink()),
                      ],
                    ),
                  ),

                  Obx(() {
                    double calculatedHeight;
                    if (showFilter.value || redioButton.isNotEmpty) {
                      calculatedHeight = screenHeight / 1.52;
                    } else if (showFilter.value && !isDateSummaryView.value) {
                      calculatedHeight = screenHeight / 1.5;
                    } else {
                      calculatedHeight = (groupTransactionList.isNotEmpty ||
                              redioButton.isNotEmpty)
                          ? screenHeight / 1.35
                          : screenHeight / 1.25;
                    }

                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: calculatedHeight,
                      child: IndexedStack(
                        index: isDateSummaryView.value ? 0 : 1,
                        children: [
                          CalendarTransactionScreen(),
                          SingleChildScrollView(
                            controller: scrollController,
                            child: TransactionHistory(
                              isYearView: false,
                              isflag: true,
                              showIcon: false,
                              expandedPage: false,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  bool getBoolFalg()
  {
    return !isDateSummaryView.value &&  allOrGroupTransactionsName.value == StringConstant.allTransactions;
  }

  Widget getTextFeild() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.4,
      height: MediaQuery.of(context).size.width / 10,
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
            lWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.grey,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.grey),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.accentColor),
                  onPressed: () {
                    clearTransactions(context: context, f: true);
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.bg5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        ),
        style: const TextStyle(color: AppColors.accentColor),
      ),
    );
  }


Widget CancelButton(String text, BuildContext context) {
 
  // Calculate width based on screen size for responsiveness
  double tabWidth = (MediaQuery.of(context).size.width) / 2.5;
  double tabHeight = (MediaQuery.of(context).size.height) /
      26; // 44 = 16*2 padding + 12 spacing
  return InkWell(
    onTap: () {
      showCheckBox.value = false;
                                                      redioButton.clear();
                                                      redioButtonIndex.clear();
                                                      balanceOutList.clear();
                                                      addManually.clear();
                                                      HapticFeedback
                                                          .selectionClick();
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: tabWidth,
      height: tabHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8)

      ),
      child: Center(
        child: textStyleImage(
          context: context,
          text: text,
          c:  AppColors.primaryColor,
          fontsize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
Widget SelectButton(String text, BuildContext context) {
 
  // Calculate width based on screen size for responsiveness
  double tabWidth = (MediaQuery.of(context).size.width) / 2.5;
  double tabHeight = (MediaQuery.of(context).size.height) /
      26; // 44 = 16*2 padding + 12 spacing
  return Container(
    margin: EdgeInsets.symmetric(vertical: 4),
    width: tabWidth,
    height: tabHeight,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      // border: Border(
      //   bottom: BorderSide(
      //     color: 
      //          AppColors.backgroundColor,
              
      //     width:  3.0 , // Adjust the width as needed
      //   ),
      // ),
    ),
    child: Center(
      child: textStyleImage(
        context: context,
        text: text,
        c:  AppColors.button,
        fontsize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

}
