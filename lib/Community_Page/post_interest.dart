import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

void showTagListOfInterestModal({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
   final screenSize = MediaQuery.of(context).size;
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        height:  screenSize.height ,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            textStyleImage(context: context, text: 'Select the Tag...!', fontsize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            GetListOfInterest(height: 0.25,),
            const SizedBox(height: 20),
           Obx(()=> InkWell(
              onTap: ()
              {
                if(!isListEnabled.value)return;
                onConfirm();// Call the passed function
                Navigator.pop(context); // Close the modal
              },
              child: isListEnabled.value? getButton(context, "Continue"): getButton(context, "Select Interest", Colors.grey.shade400,AppColors.bg1,)),
            ),
          ],
        ),
      );
    },
  );
}
