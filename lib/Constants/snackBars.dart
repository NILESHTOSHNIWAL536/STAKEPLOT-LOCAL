
part of 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

void snackBarCalled(BuildContext context, String text,
    [Color colors = const Color(0xFF43A047)]) {
  try {
    showTopSnackBar(
      Overlay.of(context),
      Container(
        height: 40,
        decoration: BoxDecoration(
    color: const Color(0xFFDBD7D7),
    borderRadius: BorderRadius.circular(5),
    border: Border.all(
      color: AppColors.primaryColor,
      width: 0.5,
    ),
  ),
        child: CustomSnackBar.success(
          message: text,
          backgroundColor: AppColors.primaryColorOpacity,
          textStyle: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 12,
            color: AppColors.primaryColor,
          ),
        ),
      ),

      displayDuration: const Duration(seconds: 2),
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
    );
  } catch (e) {
  }
}

void snackBarCalledfail(context, String text, [Color colors = AppColors.accentColor]) {
  vibrateForSnack();
  showTopSnackBar(
    
    Overlay.of(context),
    ShakeWidget(
      child: Container(
        height: 40,
        child: CustomSnackBar.success(
          message: text,
          backgroundColor: Colors.red,
          textStyle: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 12,
            color: AppColors.backgroundColor,
          ),
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}

void snackBarCalledSignup(context, String text, [Color colors = AppColors.accentColor
]) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: text,
        backgroundColor: Colors.green.shade600,
        textStyle: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.backgroundColor,
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}


void snackBarAllFeilds(context, [Color colors = Colors.red]) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: SnackbarData().enterAllFields,
        backgroundColor: Colors.red,
        textStyle: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.backgroundColor,
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}

void snackBarAllFeilds2(context, text, [Color colors = Colors.red]) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: text,
        backgroundColor: Colors.red,
        textStyle: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.backgroundColor,
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    snackBarPosition: SnackBarPosition.bottom,
    animationDuration: const Duration(milliseconds: 600),
  );
}

void snackBarAllBottom(context, text, [Color colors = Colors.green]) {
  showTopSnackBar(
  Overlay.of(context),
  
    Container(
    height: 40,
    child: CustomSnackBar.success(
      message: text,
      backgroundColor:colors,
      textStyle: FontManager().getTextStyle(
        context,
        lWeight: FontWeight.bold,
        fontSize: 12,
        color: AppColors.backgroundColor,
      ),
    ),
  ),
  snackBarPosition: SnackBarPosition.bottom,
  displayDuration: const Duration(seconds: 2),
  animationDuration: const Duration(milliseconds: 600),
  curve: Curves.easeOutBack,
  reverseCurve: Curves.easeInBack,
);
}