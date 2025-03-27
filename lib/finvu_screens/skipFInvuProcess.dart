import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

void showSkipDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
       
        content: Text("Are you sure you want to skip the Finvu process?", style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.bg1,
                    ),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Cancel",
             style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.bg1,
                    ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog

              Navigator.of(context).pushReplacementNamed('/home'); // Navigate to home or another screen
            },
            child: Text("Yes", style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize:14,
                      color: AppColors.primaryColor,
                    ),),
          ),
        ],
      );
    },
  );
}
