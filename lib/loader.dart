import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Spinner(size: 30,);
    return Container(
      height: 30,
      width: 30,
      child: Lottie.asset(
        'assets/splashScreen/loader.json',
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error); // fallback UI
        },
      ),
    );
  }
}


class Spinner extends StatelessWidget {
  double size;
  Color color;
  Spinner({Key? key, this.size = 50.0, this.color = AppColors.primaryColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return SpinKitCircle(
    //   color: color, // Use a single color
    //   size: size,
    // );
    return Container(
      height: 30,
      width: 30,
      child: Lottie.asset(
        'assets/splashScreen/loader.json',
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error); // fallback UI
        },
      ),
    );
  }
}

class Verify extends StatelessWidget {
  String str;
  Color color;
  Verify({Key? key, this.str = "Verifying.....", this.color = AppColors.accentColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          str,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
        Container(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        )
      ],
    );
  }
}
