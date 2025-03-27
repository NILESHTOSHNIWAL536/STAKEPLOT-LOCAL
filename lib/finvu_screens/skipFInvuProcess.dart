import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

void showSkipDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(
          "Are you sure you want to skip the Finvu process?",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.bg1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(
              "Cancel",
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

              Navigator.of(context).pushReplacementNamed(
                  '/home'); // Navigate to home or another screen
            },
            child: Text(
              "Yes",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<bool?> showSkipModal2(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)), // Rounded top corners
    ),
    backgroundColor: Colors.white, // Modal background
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to stop the process of linking your account(s) with Finvu?",
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.bg1,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(false); // User chose "Cancel"
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(24)),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black),
                        ),
                      ),
                    )),
                SizedBox(width: 10),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(true); // User chose "Yes"
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(24)),
                      child: Center(
                        child: Text(
                          "Yes",
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      );
    },
  );
}
