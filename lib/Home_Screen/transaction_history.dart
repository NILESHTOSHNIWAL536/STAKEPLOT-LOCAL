// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/profile.dart';

// class TransactionHistory extends StatefulWidget {
//   const TransactionHistory({super.key});

//   @override
//   State<TransactionHistory> createState() => _TransactionHistoryState();
// }

// class _TransactionHistoryState extends State<TransactionHistory> {
//   List<dynamic> transactions = [];
//   final Map<int, double> swipeOffsets = {};
//   //bool showAllTransactions = false;
//   final List<Map<String, String>> hiddenTransactions = [];

//   @override
//   void initState() {
//     getTransaction(context);
//     // print("transactions -------------------------------------------------");
//     //   print(transactions);
//     //  print("transactions -------------------------------------------------");
//     print(getTransaction);
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
//             // TextButton(
//             //   onPressed: () {
//             //     setState(() {
//             //       showAllTransactions = !showAllTransactions;
//             //     });
//             //   },
//             //   child: Text(
//             //     showAllTransactions ? 'Show Less' : 'View More',
//             //     style: FontManager().getTextStyle(context,
//             //         lWeight: FontWeight.normal,
//             //         fontSize: 14,
//             //         color: AppColors.primaryColor),
//             //   ),
//             // ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         ListView.builder(
//           itemCount: trasactionsHistory.length,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemBuilder: (context, index) {
//             if (index >= trasactionsHistory.length) {
//               return const SizedBox.shrink();
//             }

//             final transaction = trasactionsHistory[index];
//             var data = transaction['transactions'][index];
//             final date = transaction['date'];
//             final transactionList = transaction['transactions'];

//             double offset = swipeOffsets[index] ?? 0;

//             String urlPath = imageMapForHistory[data['category']] ??
//                 imageMapForHistory['others'].toString();

//             return GestureDetector(
//               onHorizontalDragUpdate: (details) {
//                 setState(() {
//                   offset += details.delta.dx;
//                   offset = offset.clamp(-40.0, 0.0);
//                   swipeOffsets[index] = offset;
//                 });
//               },
//               child: Stack(
//                 children: [
//                   Container(
//                     height: 80,
//                     color: AppColors.primaryColor,
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.only(right: 16),
//                     child: GestureDetector(
//                       onTap: () {
//                         // setState(() {
//                         //   hiddenTransactions.add(transactions[index]);
//                         //   transactions.removeAt(index);
//                         //   swipeOffsets.remove(index);
//                         // });
//                       },
//                       child: const Icon(
//                         Icons.visibility_off,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                   ),
//                   Transform.translate(
//                     offset: Offset(offset, 0),
//                     child: Container(
//                       height: 80,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                           stops: [
//                             (1.0 - (offset.abs() / 200)).clamp(0.0, 1.0),
//                             1.0,
//                           ],
//                           colors: [
//                             AppColors.backgroundColor,
//                             AppColors.backgroundColor.withOpacity(0.0),
//                           ],
//                         ),
//                       ),
//                       child: ListTile(
//                           leading: TrasactionIconImage(
//                             url: Categories.link + urlPath.toString(),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text("${data['category']} (${data['name']})",
//                                   style: FontManager().getTextStyle(context,
//                                       lWeight: FontWeight.normal,
//                                       fontSize: 15,
//                                       color: AppColors.bg3)),
//                             ],
//                           ),
//                           trailing: Column(
//                             children: [
//                               Text("₹${data['amount']}",
//                                   style: FontManager().getTextStyle(context,
//                                       lWeight: FontWeight.normal,
//                                       fontSize: 15,
//                                       color: AppColors.bg3)),
//                               Text(
//                                 "${transaction['date']} ",
//                                 style: FontManager().getTextStyle(context,
//                                     lWeight: FontWeight.normal,
//                                     fontSize: 12,
//                                     color: AppColors.accentColor),
//                               ),
//                             ],
//                           )),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<dynamic> transactions = [];
  final Map<int, double> swipeOffsets = {}; // Store offset for each transaction

//   //bool showAllTransactions = false;
  final List<Map<String, String>> hiddenTransactions = [];
  @override
  void initState() {
    super.initState();
    getTransaction(context); // This will load the transactions
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
        ListView.builder(
          itemCount: trasactionsHistory.length, // Ensure correct item count
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final transaction =
                trasactionsHistory[index]; // Get the transaction details
            var transactionList =
                transaction['transactions']; // Get transaction list
            final date = transaction['date'];

            double offset = swipeOffsets[index] ??
                0; // Use swipe offset for individual transaction

            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  double offset = swipeOffsets[index] ?? 0;
                  offset += details.primaryDelta!;
                  offset = offset.clamp(-40.0, 0.0); // Limit swipe range
                  swipeOffsets[index] =
                      offset; // Update offset for specific transaction
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
                        // Action when tapped
                        setState(() {
                          hiddenTransactions.add(transactions[index]);
                          transactions.removeAt(index);
                          swipeOffsets.remove(index);
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
                    offset: Offset(offset, 0), // Apply individual offset here
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [
                            (1.0 - (offset.abs() / 200)).clamp(0.0, 1.0),
                            1.0,
                          ],
                          colors: [
                            AppColors.backgroundColor,
                            AppColors.backgroundColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Use Column to list transaction details
                            for (var txn in transactionList)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        TrasactionIconImage(
                                          url: Categories.link +
                                              (imageMapForHistory[
                                                      txn['category']] ??
                                                  imageMapForHistory['others']
                                                      .toString()),
                                        ),
                                        Text(
                                          txn["category"],
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.normal,
                                            fontSize: 15,
                                            color: AppColors.bg3,
                                          ),
                                        ),
                                        Text(
                                          "(${txn["name"]})",
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: AppColors.bg3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "₹${txn["amount"]}",
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.normal,
                                            fontSize: 15,
                                            color: AppColors.bg3,
                                          ),
                                        ),
                                        Text(
                                          "$date",
                                          style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.normal,
                                              fontSize: 12,
                                              color: AppColors.accentColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
