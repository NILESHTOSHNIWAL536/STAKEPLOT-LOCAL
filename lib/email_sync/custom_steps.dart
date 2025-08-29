import 'package:flutter/material.dart';

import '../Constants/colors.dart';

class CustomStepper extends StatelessWidget {
  final int activeStep;
  const CustomStepper({required this.activeStep});
  @override
  Widget build(BuildContext context) {
    Color active = Color(0xFF37344F);
    Color inactive = Color(0xFFD4D1D5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) => Row(
        children: [
          CircleAvatar(
            radius: 5.5,
            backgroundColor: i <= activeStep ? active : inactive,
          ),
          if (i < 3)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              height: 2,
              width: 52,
              color: i < activeStep ? active : inactive,
            )
        ],
      )),
    );
  }
}


Widget leadIcon(context) {
  return InkWell(
              onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back, color: AppColors.primaryColor)
          );
}