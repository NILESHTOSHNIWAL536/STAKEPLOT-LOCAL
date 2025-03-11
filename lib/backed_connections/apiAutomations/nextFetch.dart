import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart' as http;

class Nextfetch extends StatefulWidget {
  @override
  _RotatingIconState createState() => _RotatingIconState();
}

class _RotatingIconState extends State<Nextfetch> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  late Timer _timer2;
  RxString currentTime="".obs;

  @override
  void initState() {
    super.initState();
     currentTime.value=getTime();
    _controller = AnimationController(
      duration: Duration(seconds: 1), // Rotation duration
      vsync: this,
    );

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _controller.forward(from: 0.0); // Restart animation every 10 seconds
    });

    _timer2 = Timer.periodic(Duration(minutes: 1), (timer) {
        // Restart animation every 10 seconds
         currentTime.value=getTime();
    });

    checkAndFetchData(); 
  }

   void checkAndFetchData()async {
    DateTime now = DateTime.now();

    if ((now.hour == 9 && now.minute == 0 )) {
            await getBankAccounts();
          if( consentAndHandleDetails.isNotEmpty)
          {
               consentAndHandleDetails.forEach((item)
               {
                           getWeeklyfetchData(
                             item[ "consentId"],
                            item["consendHandleId"],
                            item["sessionId"], 
                            item["custId"],  
                            "2024-08-05",
                             "2026-02-05"
                            );  
               });
          }  
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=> consentAndHandleDetails.isEmpty? SizedBox.shrink():Container(
      width: MediaQuery.of(context).size.width/1.1,
      child: Row(
        children: [
          RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.restore_outlined,
              color: Colors.black,
              size: 30,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: textStyle(context: context,text: "Your Next Fetch Starts in : ",fontWeight: FontWeight.bold,c: AppColors.bg1,fontsize: 13),
          ),
        Obx(()=>  textStyle(context: context,text: currentTime.value ,fontWeight: FontWeight.bold,c: AppColors.primaryColor,fontsize: 13)),
        ],
      ),
    ));
  }

 String getTime() {
  DateTime now = DateTime.now();
  DateTime next9AM = DateTime(now.year, now.month, now.day, 9, 0); // Today’s 9 AM

  if (now.isAfter(next9AM)) {
    // If it's already past 9 AM, set it for the next day
    next9AM = next9AM.add(Duration(days: 1));
  }

  Duration difference = next9AM.difference(now);
  int hoursLeft = difference.inHours;
  int minutesLeft = difference.inMinutes.remainder(60);

  return '$hoursLeft:${minutesLeft.toString().padLeft(2, '0')}';
}
}
