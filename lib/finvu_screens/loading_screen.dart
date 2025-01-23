import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterFillingLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
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
                // center: Text(
                //   "Loading...",
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle button action here
                print("Continue button pressed!");
              },
              child: Text(
                "Continue",
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


