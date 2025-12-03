import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import '../Constants/colors.dart';

class CustomStepper extends StatelessWidget {
  final int activeStep;
  const CustomStepper({required this.activeStep});
  @override
  Widget build(BuildContext context) {
    Color active = Color(0xFF37344F);
    Color inactive = Color(0xFFD4D1D5);
    return Padding(
      padding: const EdgeInsets.only(top: 20,bottom: 40),
      child: Row(
        children: [
          Container(
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    height: 4,
                    width: MediaQuery.of(context).size.width/6,
                    color: activeStep>=0 ? active : inactive,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => Row(
              children: [
                CircleAvatar(
                  radius: 7,
                  backgroundColor: i <= activeStep ? active : inactive,
                  backgroundImage:i <= activeStep ? AssetImage(svgIconPath.check_circle):null,
                ),
                if (i < 3)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    height: 4,
                    width: MediaQuery.of(context).size.width/6,
                    color: i < activeStep ? active : inactive,
                   
                  )
              ],
            )),
          ),
        ],
      ),
    );
  }
}


Widget leadIcon(context) {
  return InkWell(
              onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back, color: AppColors.primaryColor)
          );
}