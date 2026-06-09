import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import 'package:get/get.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../components/helper.dart';
import '../../components/shared_utils.dart';
import '../../controllers/transactions_controller.dart';
import '../../repository/transactions_repository.dart';

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
      padding: const EdgeInsets.only(left:AppSizes.p10, right:AppSizes.p14),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
         borderRadius: BorderRadius.circular(8),
                          boxShadow:const [
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
      child: Column(
        children: (matchedKeywords.length > 4
                ? matchedKeywords.sublist(0, 4)
                : matchedKeywords)
            .map((data) => getListIsValid(data.toLowerCase())
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: () {
                      searchTextController.value = data;
                      searchTextControllerBool.value =
                          !searchTextControllerBool.value;
                      setState(() {
                        selectedText = data;
                        //  final tx = Get.find<TransactionController>();


                        // tx.searchController.value = TextEditingValue(
                        //   text: data,
                        //   selection:
                        //       TextSelection.collapsed(offset: data.length),
                        // );
                        tnxSearchController.value = TextEditingValue(
                          text: data,
                          selection:
                              TextSelection.collapsed(offset: data.length),
                        );
                      });
                       searchItemClicked.value=true;
                      onChanedAutoTransactionStatus(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppColors.primaryColor),
                          child: textStyle(
                              context: context,
                              text: (data[0].toString()).toUpperCase(),
                              fontWeight: FontWeight.bold,
                              fontsize: 18,
                              lineHeight: 1.3,
                              c: AppColors.backgroundColor),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: textStyle(
                              context: context,
                              text: '${data[0].toUpperCase()}${data.substring(1)}',
                              fontWeight: FontWeight.w600,
                              fontsize: 18,
                              lineHeight: 1.3,
                              c: AppColors.accentColor),
                        ),
                        if (selectedText == data) ...[
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 22),
                        ],
                      ]),
                    ),
                  ))
            .toList(),
      ),
    );
  }
}
