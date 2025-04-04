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

class _RotatingIconState extends State<Nextfetch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  late Timer _timer2;
  RxString currentTime = "".obs;

  @override
  void initState() {
    super.initState();
    currentTime.value = getTime();
    _controller = AnimationController(
      duration: Duration(seconds: 1), // Rotation duration
      vsync: this,
    );

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _controller.forward(from: 0.0); // Restart animation every 10 seconds
    });

    _timer2 = Timer.periodic(Duration(minutes: 1), (timer) {
      // Restart animation every 10 seconds
      currentTime.value = getTime();
    });

    // checkAndFetchData();
  }

  

  @override
  Widget build(BuildContext context) {
    return Obx(() => consentAndHandleDetails.isEmpty
        ? SizedBox.shrink()
        : Container(
            //color: Colors.red,
            width: MediaQuery.of(context).size.width / 1.1,
            child: Row(
              children: [
                InkWell(
                   onTap: () => showFetchModal(context),
                  child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                            parent: _controller,
                            curve: Curves.linear,
                          ))
                          .drive(Tween(
                              begin: 1.0, end: 0.0)), // Reverse the rotation
                      child: AvatarProfileImage(
                          url: HomePageIcons.fetch, width: 25, height: 25)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: textStyle(
                      context: context,
                      text: "Your next fetch starts in :",
                      fontWeight: FontWeight.bold,
                      c: AppColors.bg1,
                      fontsize: 13),
                ),
                Obx(() => textStyle(
                    context: context,
                    text: currentTime.value,
                    fontWeight: FontWeight.bold,
                    c: AppColors.primaryColor,
                    fontsize: 13)),
              ],
            ),
          ));
  }

  String getTime() {
    DateTime now = DateTime.now();
    DateTime next9AM =
        DateTime(now.year, now.month, now.day, 9, 0); // Today's 9 AM

    if (now.isAfter(next9AM)) {
      // If it's already past 9 AM, set it for the next day
      next9AM = next9AM.add(Duration(days: 1));
    }

    Duration difference = next9AM.difference(now);
    int hoursLeft = difference.inHours;
    int minutesLeft = difference.inMinutes.remainder(60);

    return '$hoursLeft:${minutesLeft.toString().padLeft(2, '0')}';
  }



    void showFetchModal(BuildContext context) {
    String fetchCount = consentAndHandleDetails[0]['fetchCount'].toString();
    String nextFetch = consentAndHandleDetails[0]['nextFetch'].toString();
    String lastFetch = consentAndHandleDetails[0]['lastFetch'].toString();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your ladt fetch wad on: ${lastFetch}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Your next fetch is on: ${nextFetch}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("Number of fetches completed: $fetchCount"),
              SizedBox(height: 20),
              Text("Do you want to fetch again?", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => checkAndFetchData(),
                    child: Text("Yes"),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("No"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}


void checkAndFetchData() async 
{
   
      await getBankAccounts();
      if (consentAndHandleDetails.isNotEmpty) {

        consentAndHandleDetails.forEach((item) {
          getWeeklyfetchData(
            item["consentId"],
            item["consendHandleId"],
            item["sessionId"],
            item["custId"],
            convertToIso8601("2025-01-05"),
            convertToIso8601("2025-03-05"),
          );
        });
      }

  }