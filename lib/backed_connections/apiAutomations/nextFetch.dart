import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      currentTime.value = getTime();
    });

    // Initialize homepage strings
  
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Format nextFetchDate for display
      String formattedNextFetch = '';
      try {
        if (nextFecthDate.value.isNotEmpty) {
          DateTime nextFetchDateTime = DateTime.parse(nextFecthDate.value);
          formattedNextFetch = formatWhatsAppDate2(nextFetchDateTime); // Format the date
        } else {
          formattedNextFetch = HomepageStringsDart().notScheduled; // Updated
        }
      } catch (e) {
        formattedNextFetch = HomepageStringsDart().notScheduled; // Updated
      }

      return consentAndHandleDetails.isEmpty
          ? SizedBox.shrink()
          : Container(
              width: MediaQuery.of(context).size.width / 1,
              child: Row(
                children: [
                  isFected.value
                      ? Container(
                          height: 30,
                          width: 30,
                          child: Lottie.asset("assets/splashScreen/fetchLoad.json"),
                        )
                      : InkWell(
                          onTap: () => showFetchModal(context),
                          child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: Curves.linear,
                                ),
                              ).drive(Tween(begin: 1.0, end: 0.0)),
                              child: AvatarProfileImageNextFetch(
                                  url: HomePageIcons.fetch,
                                  width: 30,
                                  height: 25)),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: textStyle(
                      context: context,
                      text: isFected.value
                          ? HomepageStringsDart().fetchingInProgress // Updated
                          : HomepageStringsDart().nextFetchLabel, // Updated
                      fontWeight: FontWeight.bold,
                      c: AppColors.bg1,
                      fontsize: isFected.value ? 10 : 13,
                    ),
                  ),
                  textStyle(
                    context: context,
                    text: isFected.value ? "" : formattedNextFetch,
                    fontWeight: FontWeight.bold,
                    c: AppColors.primaryColor,
                    fontsize: 13,
                  ),
                ],
              ),
            );
    });
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

  showFetchModal(BuildContext context) {
    if (consentAndHandleDetails.isEmpty || consentAndHandleDetails[0] == null) {
      return; // Exit early if data is invalid
    }

    String nextFetch = nextFecthDate.value;
    String lastFetch = LastFetchDate.value;

    DateTime nextFetchDate;
    DateTime lastFetchDate;

    // Parse nextFetch with fallback
    try {
      nextFetchDate =
          nextFetch.isNotEmpty ? DateTime.parse(nextFetch) : DateTime.now();
    } catch (e) {
      nextFetchDate = DateTime.now(); // Fallback to current date
    }

    // Parse lastFetch with fallback
    try {
      lastFetchDate =
          lastFetch.isNotEmpty ? DateTime.parse(lastFetch) : DateTime.now();
    } catch (e) {
      lastFetchDate = DateTime.now(); // Fallback to current date
    }

    // Format dates
    String formattedNextFetch = formatWhatsAppDate2(nextFetchDate);
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
        return SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width, // Full screen width
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
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Row(
                      children: [
                        SizedBox(width: Colorcodes.borderRadius10),
                        Image.network(
                          BankUrl.value,
                          width: 30,
                          height: 30,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(width: Colorcodes.borderRadius10),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: textStyle(
                              context: context,
                              text: BankName.value,
                              fontsize: 16,
                              c: AppColors.primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    // Info Cards
                    _buildInfoCard(
                      context: context,
                      title: HomepageStringsDart().lastFetchLabel, // Updated
                      value: formattedLastFetch,
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    _buildInfoCard(
                      context: context,
                      title: HomepageStringsDart().nextFetchTitle, // Updated
                      value: formattedNextFetch,
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    _buildInfoCard(
                      context: context,
                      title: HomepageStringsDart().fetchCountTitle, // Updated
                      value: '${fetchCount.value}/5',
                    ),

                    fetchCount.value == "5"
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: textStyle(
                                context: context,
                                text: HomepageStringsDart().fetchingDuration, // Updated
                                fontsize: 13,
                                c: AppColors.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),

                    fetchCount.value == "5"
                        ? SizedBox.shrink()
                        : textStyleOnly2(
                            context: context,
                            text: HomepageStringsDart().fetchPrompt, // Updated
                            fontsize: screenWidth < 400 ? 12 : 14,
                            color: AppColors.bg1,
                            fontWeight: FontWeight.w500,
                          ),

                    // Buttons
                    SizedBox(height: screenWidth * 0.03),

                    fetchCount.value == "5"
                        ? textStyleOnly2(
                            context: context,
                            text: HomepageStringsDart().fetchLimitReached, // Updated
                            fontsize: screenWidth < 400 ? 12 : 14,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  checkAndFetchData();
                                },
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
                                  text: HomepageStringsDart().fetchNowButton, // Updated
                                  fontsize: screenWidth < 400 ? 12 : 14,
                                  color: AppColors.backgroundColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
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
                                  text: HomepageStringsDart().notNowButton, // Updated
                                  fontsize: screenWidth < 400 ? 12 : 14,
                                  color: AppColors.bg1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
    setUpSocketListenerMainPage(context);
    if (consentAndHandleDetails.isNotEmpty) {
      consentAndHandleDetails.forEach((item) {
        getWeeklyfetchData(item["consentId"], item["consendHandleId"],
            item["sessionId"], item["custId"], item['lastFetch']);
      });
    }
    // store data in shared preferences
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("fetchingData", consentAndHandleDetails.toString());
    isFected.value = true;

    Navigator.pop(context);
  }
}