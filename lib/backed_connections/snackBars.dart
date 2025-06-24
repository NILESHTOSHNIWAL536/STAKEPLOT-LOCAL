
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
          backgroundColor: AppColors.primaryColor,
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
    print("error in snackbar " + e.toString());
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
    displayDuration: const Duration(seconds: 2),
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

void snackBarCalledFrds(context, String text, [Color colors = Colors.black]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    action: SnackBarAction(
      label: 'Click Here',
      onPressed: () {},
    ),
    content: Row(
      children: [
        Text(
          text,
          style: FontManager()
              .getTextStyle(context, color: Colors.white, fontSize: 13),
        ),
      ],
    ),
    backgroundColor: colors,
  ));
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
    animationDuration: const Duration(milliseconds: 600),
  );
}