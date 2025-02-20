import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/bill.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/transactions.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  BuildContext? _stableContext;

  @override
  void initState() {
    super.initState();
    _stableContext = context;
    getAllTransaction(context);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    _stableContext ??= context; // Capture stable context
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        key: targetKey,
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
              ],
            ),
            const SizedBox(height: 20),
            getHistory.value ? getlist() : getlist(),
          ],
        ),
      ),
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
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Positioned(
                      right: 10, // Position visibility_off icon from right
                      top: 25, // Center vertically, adjust as needed
                      child: GestureDetector(
                        onTap: () {
                          hideTransaction(transactionList, index, groupIndex);
                        },
                        child: const Icon(
                          Icons.visibility_off,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 50, // Position split bill icon from left
                      top: 25, // Center vertically, adjust as needed
                      child: GestureDetector(
                        onTap: () {
                          // double amount = double.parse(
                          //     transactionList["amount"].toString());
                          // splitUserAmount(
                          //     context,
                          //     amount.toString(),
                          //     addedMembers,
                          //     transactionList["category"],
                          //     transactionList["subcategory"],
                          //     amount.toString());
                          showCustomFriendsModal2(
                              context, transactionList[index]);
                        },
                        child: const Icon(
                          Icons.person_add, // Placeholder for split bill icon
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        scrollLeft(details, transactionList, groupIndex, index);
                      },
                      onTap: () {
                        // hideTransaction(transactionList, index, groupIndex);
                      },
                      child: Transform.translate(
                        offset: Offset(
                            swipeOffsets[groupIndex * transactionList.length +
                                    index] ??
                                0.0,
                            0),
                        child: Container(
                          decoration: getBoxDecoration(
                              groupIndex, transactionList, index),
                          child:
                              historyTransactions(transactionList[index], date),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showCustomFriendsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (BuildContext context) {
        return FriendsUi(); // Use the modal widget here
      },
    );
  }

  void showCustomFriendsModal2(
      BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext modalContext) {
        // Rename context for clarity
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(modalContext).size.height / 1.9,
              decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: FriendsUi(),
                  ),
                  Obx(() => addedMembers.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InkWell(
                            onTap: () async {
                              try {
                                double amount = double.parse(
                                    transaction["amount"].toString());
                                double sharePerFriend =
                                    amount / addedMembers.length;
                                print(
                                    "Amount: $amount, Share Per Friend: $sharePerFriend");
                                 splitUserAmount2(
                                  _stableContext ??
                                      context, // Use _stableContext or fallback to current context
                                  amount.toString(),
                                  addedMembers.toList(),
                                  transaction["category"].toString(),
                                  transaction["subcategory"].toString(),
                                  sharePerFriend.toString(),
                                );
                                Navigator.pop(
                                    modalContext); // Close modal after initiating split
                              } catch (e) {
                                ScaffoldMessenger.of(modalContext).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Error splitting amount: $e")),
                                );
                              }
                            },
                            child: getButton(modalContext, "Continue"),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget getTransactionListUi(
      transactions, date, total, List listTransactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formatDate(date.toString()),
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
                  "₹" + total.toString(),
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
            thickness: 1,
          ),
        ],
      ),
    );
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat("dd MMM yyyy").format(date);
  }

  Widget historyTransactions(EachTransactions, date) {
    String? s = imageMapForHistory[
        EachTransactions['category'].toString().toLowerCase()];
    String ImageUrl = Categories.link + s.toString();

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colorcodes.greyLight, width: .3)),
      // padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.center,
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
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colorcodes.greyLight,
                        borderRadius: BorderRadius.circular(10)),
                    child: AvatarProfileImage(
                      url: ImageUrl,
                      height: 16,
                      width: 20,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  flex: 2,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: " " +
                              EachTransactions['category'], // Category text
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight
                                .w600, // Correct weight enum for semi-bold
                            fontSize: 14,
                            lineHeight: 2.14,

                            color: AppColors.accentColor, // Style for category
                          ),
                        ),
                        TextSpan(
                          text: " ( " +
                              EachTransactions['subcategory'] +
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
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                textStyle(
                    text: '₹${EachTransactions['amount'].toString()}',
                    context: context,
                    fontWeight: FontWeight.bold,
                    fontsize: 15),
                const SizedBox(
                  height: 6,
                ),
                textStyle(
                    text: formatDate(date.toString()),
                    context: context,
                    fontWeight: FontWeight.w300,
                    fontsize: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration getBoxDecoration(groupIndex, transactionList, index) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: [
          (1.0 -
                  ((swipeOffsets[groupIndex * transactionList.length + index] ??
                              0.0)
                          .abs() /
                      200))
              .clamp(0.0, 1.0),
          1.0,
        ],
        colors: [
          AppColors.backgroundColor,
          AppColors.backgroundColor.withOpacity(0.0),
        ],
      ),
    );
  }

  // void scrollLeft(details, transactionList, groupIndex, index) {
  //   setState(() {
  //     double offset =
  //         swipeOffsets[groupIndex * transactionList.length + index] ?? 0.0;
  //     offset += details.delta.dx;
  //     offset = offset.clamp(-90.0, 0.0); // Adjust the max swipe distance

  //     swipeOffsets[(groupIndex * transactionList.length + index).toInt()] =
  //         offset;
  //   });
  // }
  void scrollLeft(details, transactionList, groupIndex, index) {
    setState(() {
      // Reset all other swipe offsets before updating the current one
      swipeOffsets.forEach((key, value) {
        if (key != (groupIndex * transactionList.length + index).toInt()) {
          swipeOffsets[key] = 0.0;
        }
      });

      double offset =
          swipeOffsets[groupIndex * transactionList.length + index] ?? 0.0;
      offset += details.delta.dx;
      offset = offset.clamp(-90.0, 0.0); // Adjust the max swipe distance

      swipeOffsets[(groupIndex * transactionList.length + index).toInt()] =
          offset;
    });
  }

  void hideTransaction(transactionList, index, groupIndex) {
    // String transactionId = transactionList[index]['_id'];
    // hideTransactionViaApi(transactionId);
    setState(() {
      hiddenTransactions.add(transactionList[index]);
      print("hiddenTransactions");
      print(hiddenTransactions);
      transactionList.removeAt(index);
      swipeOffsets
          .remove((groupIndex * transactionList.length + index).toInt());
    });
  }
}
