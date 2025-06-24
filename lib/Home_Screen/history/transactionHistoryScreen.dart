// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:get/get.dart';

// final TextEditingController searchController = TextEditingController();
// FocusNode focusNodeSearchFeild = FocusNode();

// class TransactionHistoryScreen extends StatefulWidget {
//   const TransactionHistoryScreen({super.key});

//   @override
//   State<TransactionHistoryScreen> createState() =>
//       _TransactionHistoryScreenState();
// }

// class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
//   final RxList<Map<String, dynamic>> filteredTransactions =
//       RxList<Map<String, dynamic>>([]);
//   final ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     currentPage = 1;
//     addManually.clear();
//     getAllTransactionHistory(context, false, false, isRefreshing: true);
//     getDayWiseTransactions(context);
//     scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     scrollController.addListener(() async {
//       if (scrollController.position.pixels >=
//           scrollController.position.maxScrollExtent - 50) {
//         getAllTransactionHistory(context, false, false);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: historyAppBar(context),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               // height: MediaQuery.of(context).size.height/1.1,
//               width: MediaQuery.of(context).size.width / .1,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Search Bar
//                   Padding(
//                     padding: const EdgeInsets.only(left: 12, right: 4),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       //  height: MediaQuery.of(context).size.height /5,
//                       decoration: BoxDecoration(
//                         color: AppColors.backgroundColor,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             height: 4,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               getTextFeild(),
//                               InkWell(
//                                 onTap: () {
//                                   showModalBottomSheet(
//                                       context: context,
//                                       builder: (_) => SafeArea(
//                                             child: Container(
//                                                 width: MediaQuery.of(context)
//                                                     .size
//                                                     .width,
//                                                 decoration: const BoxDecoration(
//                                                   color: AppColors.bg5,
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                     topLeft:
//                                                         Radius.circular(20),
//                                                     topRight:
//                                                         Radius.circular(20),
//                                                   ),
//                                                 ),
//                                                 child:
//                                                     filterTransaction(context)),
//                                           ));
//                                 },
//                                 child: Icon(Icons.filter_alt_outlined,
//                                     size:
//                                         MediaQuery.of(context).size.height / 20,
//                                     color: AppColors.accentColor),
//                               )
//                             ],
//                           ),
//                           Obx(() => (groupTransactionList.length != 0 ||
//                                   redioButton.isNotEmpty)
//                               ? Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 8),
//                                   child: getTab(context),
//                                 )
//                               : SizedBox.shrink()),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Transaction History
//                   Obx(() => Container(
//                         width: MediaQuery.of(context).size.width,
//                         height: MediaQuery.sizeOf(context).height /
//                             ((groupTransactionList.length != 0 ||
//                                     redioButton.isNotEmpty)
//                                 ? 1.35
//                                 : 1.25),
//                         child: SingleChildScrollView(
//                           controller: scrollController,
//                           child: transactionsHistoryList(),
//                         ),
//                       ))
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget transactionsHistoryList() {
//     return Obx(() => loadChatdataOnChnage.value
//         ? TransactionHistory(
//             isYearView: isYearView.value,
//             isflag: true,
//             showIcon: false,
//             expandedPage: false,
//           )
//         : TransactionHistory(
//             isYearView: isYearView.value,
//             isflag: true,
//             showIcon: false,
//             expandedPage: false,
//           ));
//   }

//   Widget getTextFeild() {
//     return Container(
//       width: MediaQuery.of(context).size.width / 1.20,
//       height: MediaQuery.of(context).size.width / 8,
//       child: TextField(
//         controller: searchController,
//         focusNode: focusNodeSearchFeild,
//         onChanged: (value) {
//           onChanedAutoTransactionStatus(context);
//         },
//         decoration: InputDecoration(
//           hintText: HomepageStringsDart().searchTransactions,
//           hintStyle: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w400,
//             fontSize: 14,
//             color: AppColors.likesharecommentCount,
//           ),
//           prefixIcon: const Icon(Icons.search, color: AppColors.accentColor),
//           suffixIcon: searchController.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear, color: AppColors.accentColor),
//                   onPressed: () {
//                     clearTransactions(context: context, f: true);
//                   },
//                 )
//               : null,
//           filled: true,
//           fillColor: AppColors.bg5,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(
//                 30), // Changed to 30 for more circular appearance
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             // Added for the enabled state
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide(
//               color: AppColors.accentColor,
//             ), // Border color when enabled
//           ),
//           focusedBorder: OutlineInputBorder(
//             // Added for the focused state
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide(
//                 color: AppColors.primaryColor), // Border color when focused
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//         ),
//         style: const TextStyle(color: AppColors.accentColor),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
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
  final RxBool isDateSummaryView = false.obs; // State to toggle views

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    addManually.clear();
    getAllTransactionHistory(context, false, false, isRefreshing: true);
    getDayWiseTransactions(context).then((data) {
      dayWiseTransactions.assignAll(data);
    });
    // getDayWiseTransactionsForDate(context);
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
                                    color: AppColors.accentColor),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isDateSummaryView.value = !isDateSummaryView
                                        .value; // Toggle state
                                  });
                                },
                                child: Icon(Icons.calendar_today,
                                    size:
                                        MediaQuery.of(context).size.height / 20,
                                    color: AppColors.accentColor),
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
                  Obx(() => Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.sizeOf(context).height /
                            ((groupTransactionList.length != 0 ||
                                    redioButton.isNotEmpty)
                                ? 1.35
                                : 1.25),
                        child: isDateSummaryView.value
                            ? DateSummaryView(
                                dayWiseTransactions: dayWiseTransactions,
                                onBack: () {
                                  setState(() {
                                    isDateSummaryView.value = false;
                                  });
                                },
                              )
                            : SingleChildScrollView(
                                controller: scrollController,
                                child: TransactionHistory(
                                  isYearView: false,
                                  isflag: true,
                                  showIcon: false,
                                  expandedPage: false,
                                ),
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
      width: MediaQuery.of(context).size.width / 2,
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

// New DateSummaryView Widget
class DateSummaryView extends StatelessWidget {
  final RxList<Map<String, dynamic>> dayWiseTransactions;
  final VoidCallback onBack;

  const DateSummaryView({
    required this.dayWiseTransactions,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Header with Back Button
        Container(
          padding: const EdgeInsets.all(8.0),
          color: AppColors.backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.accentColor),
                onPressed: onBack,
              ),
              Text(
                'Date Summary',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 18,
                  color: AppColors.accentColor,
                ),
              ),
              SizedBox(width: 48), // Placeholder for symmetry
            ],
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: dayWiseTransactions.length,
                itemBuilder: (context, index) {
                  final data = dayWiseTransactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['date'],
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Credit: ₹${data['creditAmount'].toStringAsFixed(0)} | Debit: ₹${data['debitAmount'].toStringAsFixed(0)}',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      children: [
                       FutureBuilder<List<Map<String, dynamic>>>(
                          future: getDayWiseTransactionsForDate(context, data['date']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Center(child: Text('Error loading transactions'));
                            }
                            final transactions = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (context, txIndex) {
                                final transactionData = transactions[txIndex];
                                final transaction = TransactionModel.fromJson(transactionData);
                                // Ensure transactionTimestamp is used for date and bankId or logo is mapped
                                return historyTransactions(
                                  transaction,
                                  transaction.transactionTimestamp.toString() ?? data['date'], // Use transaction timestamp if available
                                  txIndex,
                                  context,
                                  true, 
                                  true,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }
}
