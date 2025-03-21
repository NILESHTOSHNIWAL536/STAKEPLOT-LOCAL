import 'dart:async';
import 'dart:io';
// import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:workmanager/workmanager.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';


String convertToIso8601(String date) {
  // Parse the input date string to a DateTime object
  DateTime dateTime = DateTime.parse(date);
  
  // Convert to UTC
  DateTime dateTimeUtc = dateTime.toUtc();
  
  // Convert the UTC DateTime object to ISO 8601 string
  String isoString = dateTimeUtc.toIso8601String();
  print("iosString");
  return isoString;
}
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
              bool  f=false;
               consentAndHandleDetails.forEach((item)
               {
                           getWeeklyfetchData(
                             item[ "consentId"],
                            item["consendHandleId"],
                            item["sessionId"], 
                            item["custId"],  
                            convertToIso8601("2025-01-05"),  
                            convertToIso8601("2025-03-05"),
                            );  
                             
               });
          }  
    }
  }


  @override
  Widget build(BuildContext context) {
    return Obx(()=> consentAndHandleDetails.isEmpty? SizedBox.shrink():Container(
      width: MediaQuery.of(context).size.width/1.1,
      child: Row(
        children: [
          RotationTransition(
            turns: _controller,
            child: AvatarProfileImage(url: HomePageIcons.fetch, width: 25, height: 25)
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: textStyle(context: context,text: "Your next fetch starts in :",fontWeight: FontWeight.bold,c: AppColors.bg1,fontsize: 13),
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
