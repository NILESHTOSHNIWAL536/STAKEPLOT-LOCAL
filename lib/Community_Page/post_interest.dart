
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart'; // Assuming FontManager2 is here
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

void showTagListOfInterestModal({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  final screenSize = MediaQuery.of(context).size;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows dynamic height
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          height: screenSize.height * 0.7, // 60% of screen height
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05, // Responsive padding
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Semantics(
                label: 'Add Interest',
                child: Text(
                  'Add Interest',
                  style: FontManager2().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: screenSize.width < 360 ? 18 : 20,
                    color: AppColors.finSpaceColor,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02), // Responsive spacing
              // List of interests
              
                Container(
                  height: MediaQuery.sizeOf(context).height/2,
                  
                  child: GetListOfInterest(height: 0, limitTagbool: true,enableAnimations: false, ), // Let it take available space
                ),
              
              SizedBox(height: screenSize.height * 0.02),
              // Continue button
              
              Obx(()=> InkWell(
                onTap: ()
                {
                  if(!isListEnabled.value)return;
                  onConfirm();// Call the passed function
                  Navigator.pop(context); // Close the modal
                },
                child: isListEnabled.value? getButton(context, "Continue"): getButton(context, "Add", Colors.grey.shade400,AppColors.bg1,)),
              ),
            ],
          ),
        ),
      );
    },
  );
}