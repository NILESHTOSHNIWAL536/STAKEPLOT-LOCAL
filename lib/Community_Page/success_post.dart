import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class SuccessPost extends StatefulWidget {
  const SuccessPost({super.key});

  @override
  State<SuccessPost> createState() => _SuccessPostState();
}

class _SuccessPostState extends State<SuccessPost> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 16),
          Text(
            'Posted Successfully',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 30),
          DecoratedContainer(
            borderRadius: 24,
            height: MediaQuery.of(context).size.height *
                0.07, // 7% of screen height
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Return to the previous screen
              },
              child: Text('Continue',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}
