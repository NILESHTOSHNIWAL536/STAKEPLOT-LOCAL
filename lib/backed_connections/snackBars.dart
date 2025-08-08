
part of 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

void snackBarCalled(BuildContext context, String text,
    [Color colors = const Color(0xFF43A047)]) {
  try {
    showTopSnackBar(
      Overlay.of(context),
      Container(
        height: 40,
        child: CustomSnackBar.success(
          message: text,
          backgroundColor: AppColors.finSpaceColor,
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
  } catch (e) {
  }
}

void snackBarCalledfail(context, String text, [Color colors = Colors.black]) {
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
          color: Colors.white,
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 3),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}

void snackBarCalledSignup(context, String text, [Color colors = Colors.black]) {
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
          color: Colors.white,
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
        color: Colors.white,
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