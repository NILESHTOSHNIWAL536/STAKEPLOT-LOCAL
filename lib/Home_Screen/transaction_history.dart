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
                      scrollLeft(details,transactionList,groupIndex,index);
                  },
                  child: Stack(
                    children: [
                      Container(
                         height: 50,
                        color: AppColors.primaryColor,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                             hideTransaction(transactionList,index,groupIndex);      
                          },
                          child: const Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(swipeOffsets[groupIndex * transactionList.length +index] ??0.0,0),
                        child: Container(
                          height: 50,
                          decoration: getBoxDecoration(groupIndex,transactionList,index),
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
                  "₹"+total.toString(),
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

  String formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat("dd MMM yyyy").format(date);
}

  Widget historyTransactions(EachTransactions) {
  
    String? s=  imageMapForHistory[EachTransactions['category'].toString().toLowerCase()];
    String ImageUrl= Categories.link + s.toString();

   return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AvatarProfileImage(
                url: ImageUrl,
                height: 10,
                width: 20,
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
                      text:
                          " ( " + EachTransactions['subcategory'] + " )", // Name text
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




  
BoxDecoration getBoxDecoration(groupIndex,transactionList,index){
   return BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.centerLeft,end: Alignment.centerRight,stops: [
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
                              
                              colors: [
                                AppColors.backgroundColor,
                                AppColors.backgroundColor.withOpacity(0.0),
                              ],
                            ),
                          );
}



  void scrollLeft(details,transactionList,groupIndex,index){
    setState(() {
                      double offset = swipeOffsets[
                              groupIndex * transactionList.length + index] ??
                          0.0;
                      offset += details.delta.dx;
                      offset = offset.clamp(-50.0, 0.0); // Adjust the max swipe distance

                      swipeOffsets[(groupIndex * transactionList.length + index)
                          .toInt()] = offset;
                    });
  }



  void hideTransaction(transactionList,index,groupIndex){
     setState(() {
                              
                              hiddenTransactions.add(transactionList[index]);
                              transactionList.removeAt(index);
                              swipeOffsets.remove(
                                  (groupIndex * transactionList.length + index)
                                      .toInt());
                            
                            });
  }


}
