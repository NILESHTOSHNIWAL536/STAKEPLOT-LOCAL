import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

void showSuccessTopSnackBar(BuildContext context, String message) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: message,
        backgroundColor: Colors.green.shade600,
        textStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}

void showErrorTopSnackBar(BuildContext context, String message) {
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.error(
      message: message,
      backgroundColor: Colors.red.shade600,
      textStyle: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
    ),
    displayDuration: const Duration(seconds: 3),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}
