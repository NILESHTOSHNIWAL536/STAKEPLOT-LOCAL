


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

Widget getTab(BuildContext context){
  return Obx(() => redioButton.isNotEmpty
                    ? getTagHideButtons(context)
                    : allOrGroupTransactionsName.value ==
                            StringConstant.allTransactions
                        ? getTabsForTransactions(context)
                        : getTabsForTransactions(context));
}


 Widget getTabsForTransactions(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      tabItem(StringConstant.allTransactions,context),
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: tabItem(StringConstant.pollTransactions,context),
      ),
    ],
  );
}



Widget tabItem(String text,BuildContext context) {
  bool isSelected = text == allOrGroupTransactionsName.value;
  // Calculate width based on screen size for responsiveness
  double tabWidth = (MediaQuery.of(context).size.width) / 2.5; 
  double tabHeight = (MediaQuery.of(context).size.height ) / 20; // 44 = 16*2 padding + 12 spacing
  return InkWell(
    onTap: () {
      allOrGroupTransactionsName.value = text;
    },
    child: Container(
      width: tabWidth,
      height: tabHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : AppColors.bg5,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.bg1,
        ),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: textStyleImage(
          context: context,
          text: text,
          c: isSelected ? AppColors.bg5 : AppColors.primaryColor,
          fontsize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}


 Widget getTagHideButtons(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          actionButton(
            text: 'Tag',
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
                  return TagShowmodal(
                    data: transactionsHistory.isNotEmpty &&
                            redioButtonIndex.isNotEmpty
                        ? transactionsHistory[redioButtonIndex.values.first]
                        : {},
                    index: 0,
                    isTag: true,
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10), // Spacing between buttons
          actionButton(
            text: 'Hide',
            onTap: () {
              hideSelectedTransactions(context, true);
              showCheckBox.value = false;
            },
            context: context
          ),
          const SizedBox(width: 10), // Spacing between buttons
        Obx(()=> addManually.isEmpty?SizedBox.shrink():  actionButton(
            text: 'Delete',
            onTap: () {
              showModal(context);
              
            },
            context: context
          )),
        ],
      ),
    );
  }

  Widget actionButton({required String text, required VoidCallback onTap,required BuildContext context}) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primaryColor.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.mt, // Match modal background for consistency
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: textStyle(
          context: context,
          text: text,
          c: AppColors.accentColor,
          fontsize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  void showModal(context2){
     showDialog<bool>(
                      context: context2,
                      builder: (context) => AlertDialog(
                      title:  textStyleImage(context: context,text:'Confirm Deletion',c: Colorcodes.red,fontWeight: FontWeight.bold,fontsize: 18),
                      content: Container(
                              // width: MediaQuery.of(context).size.width,
                              child: textStyleImage(context: context,iswrap: true,
                              text:'Only manual transactions can be deleted. Do you want to proceed?')),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context2).pop(false);
                            },
                            child: textStyleImage(context: context,text:'Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              deletSelectedTransactions(context);
                             
                            },
                            child: textStyleImage(context: context,text:'Delete', c: Colors.red,fontsize: 16,fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
  }


  void deletSelectedTransactions(BuildContext context)async {


 try{
  var body={
      'transactionIds':addManually
  };
  var urlPath="${url}/transactionauto/delete/";

  var response= await postDataApiCall(urlPath,body);

  if(getFlagOfResponse(response))
  {
      snackBarCalled(context,SnackbarData().selectedTransactionsDeleted);
      onChanedAutoTransactionStatus(context);
  }

 }catch(e)
 {
  snackBarCalledfail(context, SnackbarData().selectedTransactionsDeleteFailed);
 }

   showCheckBox.value = false;
   redioButton.clear(); // Optionally clear selection after hiding
  redioButtonIndex.clear(); // Optionally clear selection after hiding
  addManually.clear();
    getCategoryData();
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
  addManually.clear();
  Navigator.pop(context);
}