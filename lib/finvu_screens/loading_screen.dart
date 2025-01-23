import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterFillingLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: LiquidCircularProgressIndicator(
                value: 0.25, // Fill level, adjust as needed.
                valueColor: AlwaysStoppedAnimation(Colors.black), // Liquid color.
                backgroundColor: Colors.white, // Background color.
                borderColor: Colors.black, // Border color.
                borderWidth: 5.0, // Border width.
                direction: Axis.vertical, // Liquid movement direction.
               
              ),
            ),
          
          
    );
  }
}


