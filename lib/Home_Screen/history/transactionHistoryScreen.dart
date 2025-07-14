import 'package:flutter/material.dart';
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
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
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
  calculatedHeight = screenHeight / 1.5;
} else if (showFilter.value && redioButton.isNotEmpty) {
  calculatedHeight = screenHeight / 1.5;
} else {
  calculatedHeight = (groupTransactionList.isNotEmpty || redioButton.isNotEmpty)
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
                              showFilter.value = !showFilter.value; // Toggle the filter visibility
                            },
                                child: AvatarProfileImage(
                                    url: HomePageIcons.filterIcon,
                                    width: 66,
                                    height: 30),
                              ),
                              //               InkWell(
                              //                 onTap: () {
                              //                   showModalBottomSheet(
                              //                     context: context,
                              //                     builder: (_) => SafeArea(
                              //                       child: Container(
                              //                         width:
                              //                             MediaQuery.of(context).size.width,
                              //                         decoration: const BoxDecoration(
                              //                           color: AppColors.bg5,
                              //                           borderRadius: BorderRadius.only(
                              //                             topLeft: Radius.circular(20),
                              //                             topRight: Radius.circular(20),
                              //                           ),
                              //                         ),
                              //                         child: filterTransaction(context),
                              //                       ),
                              //                     ),
                              //                   );
                              //                 },
                              //                 child:  AvatarProfileImage(
                              // url: HomePageIcons.filterIcon, width: 66, height: 30),
                              //               ),
                            ],
                          ),
                        ),
                        !isDateSummaryView.value? Padding(
                           padding: const EdgeInsets.only(left: 10, right: 2),
                          child: Obx(() => (groupTransactionList.length != 0 ||
                                  redioButton.isNotEmpty) 
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: getTab(context),
                                )
                              : SizedBox.shrink()),
                        ):SizedBox(height:10),
                       
                        Container(
                          
                          
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                           
                          ),
                          child: Padding(
                             padding:  redioButton.isNotEmpty?const EdgeInsets.only(left: 10, right: 2,top: 8):const EdgeInsets.only(left: 10, right: 2,top: 0),
                             
                            child: Obx(() =>  redioButton.isNotEmpty
                                ? getTagHideButtons(context)
                                : SizedBox.shrink()),
                          ),
                        ),
                           Obx(() => (showFilter.value )
                        ? filterTransaction(context)
                        : SizedBox.shrink()),
                    
                      ],
                    ),
                  ),

                  //       Obx(() =>Container(
                  //         width: MediaQuery.of(context).size.width,
                  //               height: MediaQuery.sizeOf(context).height /
                  //                   ((groupTransactionList.length != 0 ||
                  //                           redioButton.isNotEmpty)
                  //                       ? 1.35
                  //                       : 1.25),
                  //   child: isDateSummaryView.value
                  //       ? CalendarTransactionScreen()
                  //       : SingleChildScrollView(
                  //           controller: scrollController,
                  //           child: TransactionHistory(
                  //             isYearView: false,
                  //             isflag: true,
                  //             showIcon: false,
                  //             expandedPage: false,
                  //           ),
                  //         ),
                  // )),

                  Obx(() => Container(
                        width: MediaQuery.of(context).size.width,
                         height: (showFilter.value && redioButton.isNotEmpty)
    ? MediaQuery.sizeOf(context).height / 1.6
    : (showFilter.value || redioButton.isNotEmpty)
        ? MediaQuery.sizeOf(context).height / 1.5
        : MediaQuery.sizeOf(context).height /
            ((groupTransactionList.length != 0 || redioButton.isNotEmpty) ? 1.35 : 1.25),
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
                      ))
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
}
