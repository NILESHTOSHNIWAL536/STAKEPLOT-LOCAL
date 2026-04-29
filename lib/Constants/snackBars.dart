part of 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

// void snackBarCalled(BuildContext context, String text,
//     [Color colors = const Color(0xFF43A047)]) {
//   try {
//     showTopSnackBar(
//       Overlay.of(context),
//       Container(
//         height: 40,
//         decoration: BoxDecoration(
//     color: const Color(0xFFDBD7D7),
//     borderRadius: BorderRadius.circular(5),
//     border: Border.all(
//       color: AppColors.primaryColor,
//       width: 0.5,
//     ),
//   ),
//         child: CustomSnackBar.info(

//           message: text,
//           backgroundColor: AppColors.primaryColorOpacity,
//           textStyle: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.bold,
//             fontSize: 12,
//             color: AppColors.primaryColor,
//           ),
//         ),
//       ),

//       displayDuration: const Duration(seconds: 2),
//       curve: Curves.easeOutBack,
//       reverseCurve: Curves.easeInBack,
//       animationDuration: const Duration(milliseconds: 600),
//     );
//   } catch (e) {
//   }
// }
void snackBarCalled(BuildContext context, String text) {
  try {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: AppColors.transparentColor,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 36),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p14, vertical: AppSizes.p10),
          decoration: BoxDecoration(
            color: AppColors.snackbarcolor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primaryColor,
              width: 0.6,
            ),
            boxShadow: [AppShadows.soft],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 5),
      animationDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  } catch (e) {}
}

void snackBarCalledfail(BuildContext context, String text,
    [Color colors = AppColors.accentColor]) {
  try {
    vibrateForSnack();
    showTopSnackBar(
      Overlay.of(context),
      ShakeWidget(
        child: Material(
          color: AppColors.transparentColor,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p14, vertical: AppSizes.p10),
            decoration: BoxDecoration(
              color: AppColors.redColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primaryColor,
                width: 0.6,
              ),
              boxShadow: [AppShadows.soft],
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.backgroundColor,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  } catch (e) {}
}

void snackBarCalledfail2(context, String text,
    [Color colors = AppColors.accentColor]) {
  vibrateForSnack();
  showTopSnackBar(
    Overlay.of(context),
    ShakeWidget(
      child: Container(
        height: 40,
        child: CustomSnackBar.success(
          message: text,
          backgroundColor: AppColors.redColor,
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
