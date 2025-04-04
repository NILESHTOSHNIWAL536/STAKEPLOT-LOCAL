import 'dart:async';
import 'dart:io';
// import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
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
    // String fetchCount = consentAndHandleDetails[0]['fetchCount'].toString();
    // String nextFetch = consentAndHandleDetails[0]['nextFetch'].toString();
    // String lastFetch = consentAndHandleDetails[0]['lastFetch'].toString();
    if (consentAndHandleDetails.isEmpty || consentAndHandleDetails[0] == null) {
    print("Error: consentAndHandleDetails is empty or null");
    return; // Exit early if data is invalid
  }

  // Safely extract values with fallback
  String fetchCount = consentAndHandleDetails[0]['fetchCount']?.toString() ?? '0';
  String nextFetch = consentAndHandleDetails[0]['nextFetch']?.toString() ?? '';
  String lastFetch = consentAndHandleDetails[0]['lastFetch']?.toString() ?? '';

  DateTime nextFetchDate;
  DateTime lastFetchDate;

  // Parse nextFetch with fallback
  try {
    nextFetchDate = nextFetch.isNotEmpty ? DateTime.parse(nextFetch) : DateTime.now();
  } catch (e) {
    print("Error parsing nextFetch date: $e");
    nextFetchDate = DateTime.now(); // Fallback to current date
  }

  // Parse lastFetch with fallback
  try {
    lastFetchDate = lastFetch.isNotEmpty ? DateTime.parse(lastFetch) : DateTime.now();
  } catch (e) {
    print("Error parsing lastFetch date: $e");
    lastFetchDate = DateTime.now(); // Fallback to current date
  }

  // Format dates (assuming formatWhatsAppDate exists or define it below)
  String formattedNextFetch = formatWhatsAppDate(nextFetchDate);
  String formattedLastFetch = formatWhatsAppDate(lastFetchDate);

  // Get screen width for responsive sizing
  final double screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: double.infinity, // Full screen width
            padding: EdgeInsets.all(screenWidth * 0.06), // Responsive padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Info Cards
                  _buildInfoCard(
                    context: context,
                    title: 'Last Fetch',
                    value: formattedLastFetch,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildInfoCard(
                    context: context,
                    title: 'Next Fetch',
                    value: formattedNextFetch,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildInfoCard(
                    context: context,
                    title: 'Fetch Count',

                    value: '$fetchCount/5',
                    // ...
                  ),

                  // Question
                  SizedBox(height: screenWidth * 0.06),
                  textStyleOnly2(
                    context: context,
                    text: "Would you like to fetch again?",
                    fontsize: screenWidth < 400 ? 12 : 14,
                    color: AppColors.bg1,
                    fontWeight: FontWeight.w500,
                  ),

                  // Buttons
                  SizedBox(height: screenWidth * 0.06),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => checkAndFetchData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06,
                            vertical: screenWidth * 0.04,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          minimumSize: Size(screenWidth * 0.3, 0),
                        ),
                        child: textStyleOnly2(
                          context: context,
                          text: "Yes, Fetch now",
                          fontsize: screenWidth < 400 ? 12 : 14,
                          color: AppColors.backgroundColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.bg1,
                            width: 2,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06,
                            vertical: screenWidth * 0.04,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(screenWidth * 0.3, 0),
                        ),
                        child: textStyleOnly2(
                          context: context,
                          text: "Not Now",
                          fontsize: screenWidth < 400 ? 12 : 14,
                          color: AppColors.bg1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.04),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Info Card widget with full width
  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity, // Full width
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          textStyleOnly2(
            context: context,
            text: title,
            fontsize: screenWidth < 400 ? 12 : 14,
            color: AppColors.bg1.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          textStyleOnly2(
            context: context,
            text: value,
            fontsize: screenWidth < 400 ? 10 : 12,
            color: AppColors.bg1,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  void checkAndFetchData() async {
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
}
