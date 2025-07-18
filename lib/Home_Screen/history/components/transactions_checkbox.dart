

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';



class TransactionCheckbox extends StatelessWidget {
  final TransactionModel transaction;
  final int index;
  final bool isExcluded;
  final bool isManual;
  final bool hide;
  final FontSizeFactor fontSizes;
  final BuildContext context;

  const TransactionCheckbox({
    required this.transaction,
    required this.index,
    required this.isExcluded,
    required this.isManual,
    required this.hide,
    required this.fontSizes,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child:Obx(()=> (showCheckBox.value && !isExcluded && !hide)
          ? Container(
              key: const ValueKey('checkbox'),
              height: 30,
              width: 30,
              child: Checkbox(
                value: redioButton.containsKey('${transaction.id}'),
                onChanged: (bool? isChecked) {
                  String id = '${transaction.id}';
                  if (isChecked == true) {
                    redioButton[id] = id;
                    balanceOutList[id] = transaction;
                    redioButtonIndex[id] = index;
                    redioButtonAmount[id] = transaction.type == "DEBIT"
                        ? 0 - transaction.amount
                        : transaction.amount;
                    if (isManual) addManually.add(id);
                    HapticFeedback.selectionClick();
                  } else {
                    redioButton.remove(id);
                    redioButtonIndex.remove(id);
                    balanceOutList.remove(id);
                    redioButtonAmount.remove(id);
                    if (isManual) addManually.remove(id);
                    HapticFeedback.selectionClick();
                  }
                },
                shape: const CircleBorder(),
                side: BorderSide(color: AppColors.primaryColor),
                checkColor: Colors.white,
                activeColor: AppColors.primaryColor,
                semanticLabel: 'Select transaction ${transaction.id}',
              ),
            )
          : const SizedBox.shrink(key: ValueKey('no-checkbox'))),
    );
  }
}