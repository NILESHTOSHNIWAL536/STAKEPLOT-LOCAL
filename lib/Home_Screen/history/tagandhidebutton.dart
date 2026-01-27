import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/balanceout.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../routes/route_transactions.dart';
import '../insightsController.dart';

Widget getTab(BuildContext context) {
  return Obx(() => allOrGroupTransactionsName.value == StringConstant.allTransactions
          ? getTabsForTransactions(context)
          : getTabsForTransactions(context));
}

Widget getTabsForTransactions(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      tabItem(StringConstant.allTransactions, context),
      Padding(
        padding: const EdgeInsets.only(right:AppSizes.p10),
        child: tabItem(StringConstant.pollTransactions, context),
      ),
    ],
  );
}

Widget tabItem(String text, BuildContext context) {
  bool isSelected = text == allOrGroupTransactionsName.value;
  // Calculate width based on screen size for responsiveness
  double tabWidth = (MediaQuery.of(context).size.width) / 2.5;
  double tabHeight = (MediaQuery.of(context).size.height) /
      20; // 44 = 16*2 padding + 12 spacing
  return InkWell(
    onTap: () {
      allOrGroupTransactionsName.value = text;
    },
    child: Container(
      width: tabWidth,
      height: tabHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected
                ? AppColors.backgroundColor
                : AppColors.primaryColor,
            width: isSelected ? 3.0 : 0.0, // Adjust the width as needed
          ),
        ),
      ),
      child: Center(
        child: textStyleImage(
          context: context,
          text: text,
          c: isSelected ? AppColors.backgroundColor : AppColors.button,
          fontsize: 14,
          fontWeight: isSelected ?FontWeight.w700:FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget getTagHideButtons(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
    child: SizedBox(
      width:MediaQuery.sizeOf(context).width,
      height: 25,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          actionButton(
            text: 'Tag',
            icon: SvgPicture.asset(
              LikeComment.savedPost,
              width: 12,
              height: 20,
            ),
            context: context,
            onTap: () {
              tagName.value = "Untagged";
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return transactionsHistory.isNotEmpty &&
                          redioButtonIndex.isNotEmpty
                      ? TagShowmodal(
                          data:
                              transactionsHistory[redioButtonIndex.values.first],
                          index: 0,
                          isTag: true,
                        )
                      : const SizedBox.shrink(child: Text("No group Found"));
                },
              );
            },
          ),
           SizedBox(width: AppSizes.w10), // Spacing between buttons
          actionButton(
              text: 'Hide',
              icon:const Icon(
                Icons.visibility_off_rounded,
                color: AppColors.primaryColor,
                size: 20,
              ),
              onTap: () {
                hideSelectedTransactions(context, true);
                showCheckBox.value = false;
              },
              context: context),
          SizedBox(width: AppSizes.w10), // Spacing between buttons
          Obx(() => addManually.isEmpty
              ?const SizedBox.shrink()
              : actionButton(
                  text: 'Delete',
                  icon: Icon(
                    Icons.delete,
                    color:  AppColors.redColor,
                    size: 20,
                  ),
                  onTap: () {
                    showModal(context);
                  },
                  context: context)),
           SizedBox(width: AppSizes.w10),
           actionButton(
              text: 'balance out',
              icon: const Icon(
                Icons.balance,
               color: AppColors.primaryColor,
                size: 20,
              ),
              // icon: chatAvatartImage(url: 'assets/icons/Home-page/balanceout.svg', width: 200, height: 13),
              onTap: () {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => const BalanceOutDialog(),
                );
              },
              context: context),

       SizedBox(width: AppSizes.w10),
          actionButton(
              text: 'Not mine',
              icon: const Icon(
                Icons.close,
                color: AppColors.primaryColor,
                size: 20,
              ),
              onTap: () {
                excludeSelectedTransactions(context, true);
                showCheckBox.value = false;
              },
              context: context),
          //  assets/icons/Home-page/balanceout.svg
          
        ],
      ),
    ),
  );
}

Widget actionButton(
    {required String text,
    required VoidCallback onTap,
    required BuildContext context,
    dynamic icon}) {
  return InkWell(
    onTap: onTap,
    splashColor: AppColors.primaryColor.withOpacity(0.2),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: AppSizes.p4),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor, // Match modal background for consistency
        borderRadius: BorderRadius.circular(3),
        border: Border.all(width: .1,color:AppColors.primaryColor, ),
        boxShadow:const [
                 BoxShadow(
                  color: Color.fromRGBO(120, 120, 120, 0.25),
                  offset: Offset(0, 0),
                  blurRadius: 4,
                  spreadRadius: 0,
                )                    ]
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon is IconData
                  ? Icon(icon, color: AppColors.accentColor, size: 6)
                  : Container(
                    // color: Colorcodes.chatBody,
                    child: icon as Widget
                  ),
            ],
              SizedBox(width: AppSizes.w6),
            textStyleImage(
              context: context,
              text: text,
              c: AppColors.accentColor,
              fontsize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    ),
  );
}

void showModal(context2) {
  showDialog<bool>(
    context: context2,
    builder: (context) => AlertDialog(
      title: textStyleImage(
          context: context,
          text: 'Confirm Deletion',
          c: Colorcodes.red,
          fontWeight: FontWeight.bold,
          fontsize: 18),
      content: Container(
          // width: MediaQuery.of(context).size.width,
          child: textStyleImage(
              context: context,
              iswrap: true,
              text:
                  'Only manual transactions can be deleted. Do you want to proceed?')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context2).pop(false);
          },
          child: textStyleImage(context: context, text: 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            deletSelectedTransactions(context);
          },
          child: textStyleImage(
              context: context,
              text: 'Delete',
              c:  AppColors.redColor,
              fontsize: 16,
              fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

void deletSelectedTransactions(BuildContext context) async {
  try {
    var body = {'transactionIds': addManually};
    var urlPath = BankTransactionRoutes.deleteTransactions;

    var response = await postDataApiCall(urlPath, body);

    if (getFlagOfResponse(response)) {
      snackBarCalled(context, SnackbarData().selectedTransactionsDeleted);
      onChanedAutoTransactionStatus(context);
    }
  } catch (e) {
    snackBarCalledfail(
        context, SnackbarData().selectedTransactionsDeleteFailed);
  }

  showCheckBox.value = false;
  redioButton.clear(); // Optionally clear selection after hiding
  redioButtonIndex.clear(); // Optionally clear selection after hiding
  addManually.clear();
  getCategoryData(context);
    final InsightsController _controller = Get.put(InsightsController());
    _controller.getHomePageInsights(context);
  _controller.getHomePageMoneyMapInsights(context);
  Navigator.pop(context);
}

void hideSelectedTransactions(BuildContext context, bool hidden) {
  int index = 0; // Or get from another list/map if you have matching indexes

  redioButton.forEach((id, value) {
    hideTransaction(redioButtonIndex[id] ?? 0, hidden, context, id);
    index++;
  });

  redioButton.clear(); // Optionally clear selection after hiding
  redioButtonIndex.clear(); // Optionally clear selection after hiding
  redioButtonAmount.clear(); // Optionally clear selection after hiding
  addManually.clear();
  Navigator.pop(context);
}


void updateTheGroupTransactions(BuildContext context, bool hidden,String id,double finalAmount) {


    updateTransactionsBalanceOut(context,id,redioButtonIndex[id] ?? 0 ,finalAmount);

    redioButton.forEach((txnID, value)
    {
      if(txnID!=id)updateTransactionsBalanceOut(context,txnID,redioButtonIndex[txnID] ?? 0 ,-1);
    });

      redioButton.clear();      // Optionally clear selection after hiding
      redioButtonIndex.clear(); // Optionally clear selection after hiding
      redioButtonAmount.clear(); // Optionally clear selection after hiding
      addManually.clear();
       balanceOutList.clear();
      Navigator.pop(context);
}

void excludeSelectedTransactions(BuildContext context, bool isExcluded) {
  int index = 0; // Or get from another list/map if you have matching indexes

  redioButton.forEach((id, value) {
    excludeCashFlowTransaction(redioButtonIndex[id] ?? 0, isExcluded, context, id);
    index++;
  });

  redioButton.clear(); // Optionally clear selection after hiding
  redioButtonIndex.clear(); // Optionally clear selection after hiding
  addManually.clear();
  // Navigator.pop(context);
}
