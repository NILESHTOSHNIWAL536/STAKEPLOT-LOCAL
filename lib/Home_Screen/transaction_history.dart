import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/model/transactions.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:get/get.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<dynamic> transactions = [];
  final Map<int, double> swipeOffsets = {}; // Store offset for each transaction
  final List<Map<String, dynamic>> hiddenTransactions = [];
  final transactionsHistory = <dynamic>[].obs;

  @override
  void initState() {
    super.initState();
    getAllTransaction(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          ],
        ),
        const SizedBox(height: 20),
        getHistory.value ? getlist() : getlist(),
      ],
    );
  }

  Widget getlist() {
    return ListView.builder(
      itemCount: trasactionsHistory.length, // Ensure correct item count
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, groupIndex) {
        final transaction = trasactionsHistory[groupIndex];
        var transactionList = transaction['transactions'];
        final date = transaction['date'];
        final total = transaction['total'];

        return Column(
          children: [
            getTransactionListUi(transaction, date, total, transactionList),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactionList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      double offset = swipeOffsets[
                              groupIndex * transactionList.length + index] ??
                          0.0;
                      offset += details.delta.dx;
                      offset = offset.clamp(
                          -50.0, 0.0); // Adjust the max swipe distance

                      swipeOffsets[(groupIndex * transactionList.length + index)
                          .toInt()] = offset;
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 80,
                        color: AppColors.primaryColor,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            print(
                                "Icon tapped for index: $index"); // Debug print
                            setState(() {
                              print(
                                  "Before removal: ${transactionList.length}"); // Debug print
                              hiddenTransactions.add(transactionList[index]);
                              transactionList.removeAt(index);
                              swipeOffsets.remove(
                                  (groupIndex * transactionList.length + index)
                                      .toInt());
                              print(
                                  "After removal: ${transactionList.length}"); // Debug print
                            });
                          },
                          child: const Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(
                            swipeOffsets[groupIndex * transactionList.length +
                                    index] ??
                                0.0,
                            0),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [
                                (1.0 -
                                        ((swipeOffsets[groupIndex *
                                                            transactionList
                                                                .length +
                                                        index] ??
                                                    0.0)
                                                .abs() /
                                            200))
                                    .clamp(0.0, 1.0),
                                1.0,
                              ],
                              //stops: [
//                             (1.0 - (offset.abs() / 200)).clamp(0.0, 1.0),
//                             1.0,
//                           ],
                              colors: [
                                AppColors.backgroundColor,
                                AppColors.backgroundColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                          child: historyTransactions(transactionList[index]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget getTransactionListUi(
      transactions, date, total, List listTransactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  date.toString(),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight:
                        FontWeight.w600, // Correct weight enum for semi-bold
                    fontSize: 16,
                    lineHeight: 2.14,

                    color: AppColors.accentColor, // Style for category
                  ),
                ),
                Text(
                  total.toString(),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight:
                        FontWeight.w600, // Correct weight enum for semi-bold
                    fontSize: 16,
                    lineHeight: 2.14,

                    color: AppColors.accentColor, // Style for category
                  ),
                ),
              ],
            ),
          ),
          Divider(
              // thickness: 1,
              // indent: 10,
              // endIndent: 10,
              ),
        ],
      ),
    );
  }

  Widget historyTransactions(EachTransactions) {
    print(EachTransactions);
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TrasactionIconImage(
                url: Categories.link +
                    (imageMapForHistory[EachTransactions['category']] ??
                        imageMapForHistory['others'].toString()),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: " " + EachTransactions['category'], // Category text
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight
                            .w600, // Correct weight enum for semi-bold
                        fontSize: 16,
                        lineHeight: 2.14,

                        color: AppColors.accentColor, // Style for category
                      ),
                    ),
                    TextSpan(
                      text: " ( " +
                          EachTransactions['category'] +
                          " )", // Name text
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight
                            .w400, // Correct weight enum for semi-bold
                        fontSize: 12,
                        lineHeight: 1.14,
                        color: AppColors.accentColor, // Style for name
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text('₹${EachTransactions['amount'].toString()}'),
        ],
      ),
    );
  }
}
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/model/transactions.dart';
// import 'package:flutter_application_code_stakeplot/profile.dart';
// import 'package:get/get.dart';

// class TransactionHistory extends StatefulWidget {
//   const TransactionHistory({super.key});

//   @override
//   State<TransactionHistory> createState() => _TransactionHistoryState();
// }

// class _TransactionHistoryState extends State<TransactionHistory> {
//   List<dynamic> transactions = [];
//   final List<Map<String, dynamic>> hiddenTransactions = [];
//   final transactionsHistory = <dynamic>[].obs;

//   @override
//   void initState() {
//     super.initState();
//     getAllTransaction(context); // Fetch transaction data initially
//   }

//   Future<List<dynamic>> fetchTransactionData() async {
//     // You can use your API call or method to fetch data here
//     return await getAllTransaction(context); // Modify as per your API call
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Transaction History',
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: AppColors.accentColor),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         FutureBuilder<List<dynamic>>(
//           future: fetchTransactionData(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator(); // Loading indicator
//             }
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}'); // Error handling
//             }
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Text('No transactions available.');
//             }

//             transactionsHistory.assignAll(snapshot.data!); // Store data in observable
//             return getHistoryList();
//           },
//         ),
//       ],
//     );
//   }

//   Widget getHistoryList() {
//     return ListView.builder(
//       itemCount: transactionsHistory.length,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemBuilder: (context, groupIndex) {
//         final transaction = transactionsHistory[groupIndex];
//         var transactionList = transaction['transactions'];
//         final date = transaction['date'];
//         final total = transaction['total'];

//         return Column(
//           children: [
//             getTransactionListUi(transaction, date, total, transactionList),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: transactionList.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onHorizontalDragUpdate: (details) {
//                     // Your swipe offset logic can be handled here
//                     // Simplify if possible to reduce complexity
//                   },
//                   child: Container(
//                     height: 80,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                         colors: [
//                           AppColors.backgroundColor,
//                           AppColors.backgroundColor.withOpacity(0.0),
//                         ],
//                       ),
//                     ),
//                     child: historyTransactions(transactionList[index]),
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget getTransactionListUi(transactions, date, total, List listTransactions) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             date.toString(),
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.w600,
//               fontSize: 16,
//               lineHeight: 2.14,
//               color: AppColors.accentColor,
//             ),
//           ),
//           Text(
//             total.toString(),
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.w600,
//               fontSize: 16,
//               lineHeight: 2.14,
//               color: AppColors.accentColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget historyTransactions(EachTransactions) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               TrasactionIconImage(
//                 url: Categories.link +
//                     (imageMapForHistory[EachTransactions['category']] ??
//                         imageMapForHistory['others'].toString()),
//               ),
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: " " + EachTransactions['category'],
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w600,
//                         fontSize: 16,
//                         lineHeight: 2.14,
//                         color: AppColors.accentColor,
//                       ),
//                     ),
//                     TextSpan(
//                       text: " ( " + EachTransactions['category'] + " )",
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w400,
//                         fontSize: 12,
//                         lineHeight: 1.14,
//                         color: AppColors.accentColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Text('₹${EachTransactions['amount'].toString()}'),
//         ],
//       ),
//     );
//   }
// }
