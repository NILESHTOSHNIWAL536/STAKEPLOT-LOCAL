import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';


import '../helper.dart';

class TransactionsSearchList extends StatefulWidget {
  const TransactionsSearchList({Key? key}) : super(key: key);

  @override
  State<TransactionsSearchList> createState() => _TransactionsSearchListState();
}

class _TransactionsSearchListState extends State<TransactionsSearchList> {
  String? selectedText;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 10, right: 14),
      child: Column(
        children: (matchedKeywords.length > 4
                ? matchedKeywords.sublist(0, 4)
                : matchedKeywords)
            .map((data) => getListIsValid(data.toLowerCase())
                ? SizedBox.shrink()
                : InkWell(
                    onTap: () {
                      searchTextController.value = data;
                      searchTextControllerBool.value =
                          !searchTextControllerBool.value;
                      setState(() {
                        selectedText = data;
                        searchController.value = TextEditingValue(
                          text: data,
                          selection:
                              TextSelection.collapsed(offset: data.length),
                        );
                      });
                       searchItemClicked.value=true;
                      onChanedAutoTransactionStatus(context);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(137, 137, 137,
                                  0.25), // Equivalent to rgba(137, 137, 137, 0.25);
                              blurRadius:
                                  4, // Equivalent to box-shadow: 0 0 4px 0;
                              offset: Offset(
                                  0, 0), // Equivalent to box-shadow: 0 0 4px 0;
                            ),
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: AppColors.primaryColor),
                            child: textStyle(
                                context: context,
                                text: (data[0].toString()).toUpperCase(),
                                fontWeight: FontWeight.bold,
                                fontsize: 20,
                                lineHeight: 1.3,
                                c: Colorcodes.white),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.4,
                            child: textStyle(
                                context: context,
                                text: data,
                                fontWeight: FontWeight.w600,
                                fontsize: 20,
                                lineHeight: 1.3,
                                c: AppColors.accentColor),
                          ),
                          if (selectedText == data) ...[
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 22),
                          ],
                        ])),
                  ))
            .toList(),
      ),
    );
  }
}
