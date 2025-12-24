// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/Home/init_Api_Calls.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../components/shared_utils.dart';
// import '../../model/fips_metric_model.dart';
// import '../../repository/bankinfo.dart';
// import '../../widget_services/widget_service.dart';
// import 'bank_progress.dart';

// RxBool isBankLinked = false.obs;

// class Nextfetch extends StatefulWidget {
//   @override
//   _RotatingIconState createState() => _RotatingIconState();
// }

// class _RotatingIconState extends State<Nextfetch>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Timer _timer;
//   late Timer _timer2;
//   RxString currentTime = "".obs;

//   @override
//   void initState() {
//     super.initState();
//     currentTime.value = getTime();
//     _controller = AnimationController(
//       duration: Duration(seconds: 1), // Rotation duration
//       vsync: this,
//     );

//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       _controller.forward(from: 0.0); // Restart animation every 10 seconds
//     });

//     _timer2 = Timer.periodic(Duration(minutes: 1), (timer) {
//       currentTime.value = getTime();
//     });
// updateNextFetchWidget();
// // Call this whenever nextFecthDate or isFected changes (e.g., in a reactive Obx or post-fetch callback)

//     // Initialize homepage strings
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       // Format nextFetchDate for display
//       String formattedNextFetch = '';
//       try {
//         if (nextFecthDate.value.isNotEmpty) {
//           DateTime nextFetchDateTime = DateTime.parse(nextFecthDate.value);
//           formattedNextFetch =
//               formatWhatsAppDate2(nextFetchDateTime); // Format the date
//         } else {
//           formattedNextFetch = HomepageStringsDart().notScheduled; // Updated
//         }
//       } catch (e) {
//         formattedNextFetch = HomepageStringsDart().notScheduled; // Updated
//       }

//       return !isBankLinked.value
//           ? SizedBox.shrink()
//           : (consentAndHandleDetails.isEmpty)
//               ? textStyle(
//                   context: context,
//                   text: HomepageStringsDart().noBankLinked,
//                   fontsize: 14,
//                   c: AppColors.bg1)
//               : Container(
//                   width: MediaQuery.of(context).size.width / 1,
//                   child: Row(
//                     children: [
//                       isFected.value
//                           ? Container(
//                               height: 30,
//                               width: 30,
//                               child: Lottie.asset(
//                                   "assets/splashScreen/fetchLoad.json"),
//                             )
//                           : InkWell(
//                               onTap: () => showFetchModal(context),
//                               child: RotationTransition(
//                                   turns: Tween(begin: 0.0, end: 1.0)
//                                       .animate(
//                                         CurvedAnimation(
//                                           parent: _controller,
//                                           curve: Curves.linear,
//                                         ),
//                                       )
//                                       .drive(Tween(begin: 1.0, end: 0.0)),
//                                   child: AvatarProfileImageNextFetch(
//                                       url: HomePageIcons.fetch,
//                                       width: 30,
//                                       height: 25)),
//                             ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5),
//                         child: textStyle(
//                           context: context,
//                           text: isFected.value
//                               ? HomepageStringsDart()
//                                   .fetchingInProgress // Updated
//                               : HomepageStringsDart().nextFetchLabel, // Updated
//                           fontWeight: FontWeight.bold,
//                           c: AppColors.bg1,
//                           fontsize: isFected.value ? 10 : 13,
//                         ),
//                       ),
//                       textStyle(
//                         context: context,
//                         text: isFected.value ? "" : formattedNextFetch,
//                         fontWeight: FontWeight.bold,
//                         c: AppColors.primaryColor,
//                         fontsize: 13,
//                       ),
//                     ],
//                   ),
//                 );
//     });
//   }

//   String getTime() {
//     DateTime now = DateTime.now();
//     DateTime next9AM =
//         DateTime(now.year, now.month, now.day, 9, 0); // Today's 9 AM

//     if (now.isAfter(next9AM)) {
//       // If it's already past 9 AM, set it for the next day
//       next9AM = next9AM.add(Duration(days: 1));
//     }

//     Duration difference = next9AM.difference(now);
//     int hoursLeft = difference.inHours;
//     int minutesLeft = difference.inMinutes.remainder(60);

//     return '$hoursLeft:${minutesLeft.toString().padLeft(2, '0')}';
//   }

//   showFetchModal(BuildContext context) {
//     if (consentAndHandleDetails.isEmpty || consentAndHandleDetails[0] == null) {
//       return; // Exit early if data is invalid
//     }

//     String nextFetch = nextFecthDate.value;
//     String lastFetch = LastFetchDate.value;

//     DateTime nextFetchDate;
//     DateTime lastFetchDate;

//     // Parse nextFetch with fallback
//     try {
//       nextFetchDate =
//           nextFetch.isNotEmpty ? DateTime.parse(nextFetch) : DateTime.now();
//     } catch (e) {
//       nextFetchDate = DateTime.now(); // Fallback to current date
//     }

//     // Parse lastFetch with fallback
//     try {
//       lastFetchDate =
//           lastFetch.isNotEmpty ? DateTime.parse(lastFetch) : DateTime.now();
//     } catch (e) {
//       lastFetchDate = DateTime.now(); // Fallback to current date
//     }

//     // Format dates
//     String formattedNextFetch = formatWhatsAppDate2(nextFetchDate);
//     String formattedLastFetch = formatWhatsAppDate(lastFetchDate);

//     // Get screen width for responsive sizing
//     final double screenWidth = MediaQuery.of(context).size.width;

//     bool limit = int.parse(fetchCount.value) >= 5;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       backgroundColor: AppColors.transparentColor,
//       builder: (context) {
//         return SafeArea(
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: Container(
//               width: MediaQuery.of(context).size.width, // Full screen width
//               padding: EdgeInsets.all(screenWidth * 0.06), // Responsive padding
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundColor,
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(24)),
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     AppColors.backgroundColor,
//                     Colors.grey[50]!,
//                   ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.accentColor.withOpacity(0.1),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 4,
//                       margin: EdgeInsets.only(bottom: screenWidth * 0.04),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(width: Colorcodes.borderRadius),
//                         Image.network(
//                           BankUrl.value,
//                           width: 30,
//                           height: 30,
//                           fit: BoxFit.fitWidth,
//                           errorBuilder: getErrorBankLogo(),
//                         ),
//                         SizedBox(width: Colorcodes.borderRadius10),
//                         Container(
//                           alignment: Alignment.topLeft,
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           child: textStyle(
//                               context: context,
//                               text: BankName.value,
//                               fontsize: 16,
//                               c: AppColors.primaryColor,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),

//                     BankProgress(
//                       percent: getPersentage(),
//                     ),

//                     getInfoAboutBank(context),
//                     const SizedBox(
//                       height: 10,
//                     ),

//                     // Info Cards
//                     _buildInfoCard(
//                       context: context,
//                       title: HomepageStringsDart().lastFetchLabel, // Updated
//                       value: formattedLastFetch,
//                     ),
//                     SizedBox(height: screenWidth * 0.04),
//                     _buildInfoCard(
//                       context: context,
//                       title: HomepageStringsDart().nextFetchTitle, // Updated
//                       value: formattedNextFetch,
//                     ),
//                     SizedBox(height: screenWidth * 0.04),
//                     _buildInfoCard(
//                       context: context,
//                       title: HomepageStringsDart().fetchCountTitle, // Updated
//                       value: '${!limit ? fetchCount.value : "5"}/5',
//                     ),

//                     limit
//                         ? SizedBox.shrink()
//                         : Padding(
//                             padding: EdgeInsets.symmetric(vertical: 10),
//                             child: textStyle(
//                                 context: context,
//                                 text: HomepageStringsDart()
//                                     .fetchingDuration, // Updated
//                                 fontsize: 13,
//                                 c: AppColors.primaryColor,
//                                 fontWeight: FontWeight.bold),
//                           ),

//                     limit
//                         ? SizedBox.shrink()
//                         : textStyleOnly2(
//                             context: context,
//                             text: HomepageStringsDart().fetchPrompt, // Updated
//                             fontsize: screenWidth < 400 ? 12 : 14,
//                             color: AppColors.bg1,
//                             fontWeight: FontWeight.w500,
//                           ),

//                     // Buttons
//                     SizedBox(height: screenWidth * 0.03),

//                     fetchCount.value == "5"
//                         ? textStyleOnly2(
//                             context: context,
//                             text: HomepageStringsDart()
//                                 .fetchLimitReached, // Updated
//                             fontsize: screenWidth < 400 ? 12 : 14,
//                             color: AppColors.primaryColor,
//                             fontWeight: FontWeight.bold,
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   if (fetchNow.value) return;
//                                   fetchNow.value = true;
//                                   checkAndFetchData();
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.primaryColor,
//                                   foregroundColor: AppColors.backgroundColor,
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: screenWidth * 0.06,
//                                     vertical: screenWidth * 0.04,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   elevation: 2,
//                                   minimumSize: Size(screenWidth * 0.3, 0),
//                                 ),
//                                 child: Obx(() => fetchNow.value
//                                     ? Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 40),
//                                         child: Spinner(
//                                           size: 10,
//                                           color: Colorcodes.white,
//                                         ),
//                                       )
//                                     : textStyleOnly2(
//                                         context: context,
//                                         text: HomepageStringsDart()
//                                             .fetchNowButton, // Updated
//                                         fontsize: screenWidth < 400 ? 12 : 14,
//                                         color: AppColors.backgroundColor,
//                                         fontWeight: FontWeight.w500,
//                                       )),
//                               ),
//                               SizedBox(width: screenWidth * 0.03),
//                               OutlinedButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 style: OutlinedButton.styleFrom(
//                                   side: BorderSide(
//                                     color: AppColors.bg1,
//                                     width: 2,
//                                   ),
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: screenWidth * 0.06,
//                                     vertical: screenWidth * 0.04,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   minimumSize: Size(screenWidth * 0.3, 0),
//                                 ),
//                                 child: textStyleOnly2(
//                                   context: context,
//                                   text: HomepageStringsDart()
//                                       .notNowButton, // Updated
//                                   fontsize: screenWidth < 400 ? 12 : 14,
//                                   color: AppColors.bg1,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   double getPersentage() {
//     if (BankName.value == "") return 100.0;
//     final FipsMetric metric = fipsMetricList.firstWhere(
//       (item) => item.BankName == BankName.value,
//       orElse: () => fipsMetricList.first,
//     );
//     return metric.successPercent.toDouble();
//   }

//   Widget getInfoAboutBank(BuildContext context) {
//     if (fipsMetricList.isEmpty) return SizedBox();

//     // Example: pick first for demo — adapt as per selection logic
//     final FipsMetric metric = fipsMetricList.firstWhere(
//       (item) => item.BankName == BankName.value,
//       orElse: () => fipsMetricList.first,
//     );

//     final String text = _generateBankFetchInfo(metric) +
//         "\nAverage latency: ${metric.latencyAvgMs + 40}ms. ";
//     final Color textColor = _getColorFromSuccessPercent(metric.successPercent);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//       child: Column(
//         children: [
//           textStyle(
//               context: context,
//               text: text,
//               fontWeight: FontWeight.bold,
//               fontsize: 14,
//               c: AppColors.bg1,
//               iswrap: true)
//         ],
//       ),
//     );
//   }

//   String _generateBankFetchInfo(FipsMetric metric) {
//     String text1 = "Bank server is Up. All systems are working smoothly!";
//     String text2 =
//         "Bank server is responding slowly. Some operations may take longer than usual.";
//     String text3 =
//         "Bank server is currently down. Please try again later or check back shortly.";

//     if (metric.successPercent >= 70)
//       return text1;
//     else if (metric.successPercent <= 40) return text3;
//     return text2;

//     // return "Bank fetch success rate is ${metric.successPercent}%. "
//     //     "Average latency: ${metric.latencyAvgMs}ms. "
//     //     "Timeouts: ${metric.timeoutPercent}%, "
//     //     "Server errors: ${metric.serverErrorPercent}%, "
//     //     "Client errors: ${metric.clientErrorPercent}%.";
//   }

//   Color _getColorFromSuccessPercent(num successPercent) {
//     if (successPercent < 40) {
//       return Colors.red;
//     } else if (successPercent < 70) {
//       return Colors.orange;
//     } else {
//       return Colors.green;
//     }
//   }

//   Widget _buildInfoCard({
//     required BuildContext context,
//     required String title,
//     required String value,
//   }) {
//     final double screenWidth = MediaQuery.of(context).size.width;

//     return Container(
//       width: double.infinity, // Full width
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey, width: 1),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           textStyleOnly2(
//             context: context,
//             text: title,
//             fontsize: screenWidth < 400 ? 12 : 14,
//             color: AppColors.bg1.withOpacity(0.8),
//             fontWeight: FontWeight.w500,
//           ),
//           textStyleOnly2(
//             context: context,
//             text: value,
//             fontsize: screenWidth < 400 ? 10 : 12,
//             color: AppColors.bg1,
//             fontWeight: FontWeight.w500,
//           ),
//         ],
//       ),
//     );
//   }

//   void checkAndFetchData() async {
//     // await getBankAccounts();
//     setUpSocketListenerMainPage(context);
//     if (consentAndHandleDetails.isNotEmpty) {
//       consentAndHandleDetails.forEach((item) {
//         getWeeklyfetchData(
//             item["consentId"],
//             item["consendHandleId"],
//             item["sessionId"],
//             item["custId"],
//             item['lastFetch'],
//             item['bankName'],
//             item['fipId'],
//             item['fetchCount'],
//             item['accountId']);
//       });
//     }
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("fetchingData", consentAndHandleDetails.toString());
//     isFected.value = true;
//     fetchNow.value = false;
//     scrollBankPage.value = 0;
//     callApi(context);
//     Navigator.pop(context);
//   }
// }

// Color getFetchStatusColor(num successPercent) {
//   if (successPercent < 40) {
//     return Colors.redAccent; // Poor
//   } else if (successPercent < 70) {
//     return Colors.orangeAccent; // Average
//   } else {
//     return Colors.green; // Good
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/init_Api_Calls.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/font_manager.dart';
import '../../components/shared_utils.dart';
import '../../model/fips_metric_model.dart';
// <-- make sure this is imported
import '../../repository/bankinfo.dart';
import '../../widget_services/widget_service.dart';
import 'bank_progress.dart';
import 'bank_sync_flow.dart';

RxBool isBankLinked = false.obs;
RxInt modalPage = 0.obs;
final PageController modalPageController = PageController();

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
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _controller.forward(from: 0.0);
    });

    _timer2 = Timer.periodic(Duration(minutes: 1), (timer) {
      currentTime.value = getTime();
    });
  // modalPageController = PageController(initialPage: 0);
    updateNextFetchWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String formattedNextFetch = '';
      try {
        if (nextFecthDate.value.isNotEmpty) {
          DateTime nextFetchDateTime =
              DateTime.parse(nextFecthDate.value);
          formattedNextFetch =
              formatWhatsAppDate2(nextFetchDateTime);
        } else {
          formattedNextFetch = HomepageStringsDart().notScheduled;
        }
      } catch (e) {
        formattedNextFetch = HomepageStringsDart().notScheduled;
      }

      return !isBankLinked.value
          ? SizedBox.shrink()
          : (consentAndHandleDetails.isEmpty)
              ? textStyle(
                  context: context,
                  text: HomepageStringsDart().noBankLinked,
                  fontsize: 14,
                  c: AppColors.bg1,
                )
              : Container(
                // color: Colors.green,
                  width:
                      MediaQuery.of(context).size.width / 1.4,
                  child: Row(
                    children: [
                      isFected.value
                          ? Container(
                              height: 30,
                              width: 30,
                              child: Lottie.asset(
                                  "assets/splashScreen/fetchLoad.json"),
                            )
                          : InkWell(
                              onTap: () => showFetchModal(context),
                              child: RotationTransition(
                                turns: Tween(
                                  begin: 0.0,
                                  end: 1.0,
                                )
                                    .animate(
                                      CurvedAnimation(
                                        parent: _controller,
                                        curve: Curves.linear,
                                      ),
                                    )
                                    .drive(Tween(
                                        begin: 1.0, end: 0.0)),
                                child: AvatarProfileImageNextFetch(
                                  url: HomePageIcons.fetch,
                                  width: 40,
                                  height: 35,
                                ),
                              ),
                            ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 5),
                        child: textStyle(
                          context: context,
                          text: isFected.value
                              ? HomepageStringsDart()
                                  .fetchingInProgress
                              : HomepageStringsDart().nextFetchLabel,
                          fontWeight: FontWeight.bold,
                          c: AppColors.bg1,
                          fontsize: isFected.value ? 10 : 13,
                        ),
                      ),
                      textStyle(
                        context: context,
                        text:
                            isFected.value ? "" : formattedNextFetch,
                        fontWeight: FontWeight.bold,
                        c: AppColors.backgroundColor,
                        fontsize: 13,
                      ),
                    ],
                  ),
                );
    });
  }

  String getTime() {
    DateTime now = DateTime.now();
    DateTime next9AM = DateTime(
      now.year,
      now.month,
      now.day,
      9,
      0,
    );

    if (now.isAfter(next9AM)) {
      next9AM = next9AM.add(Duration(days: 1));
    }

    Duration difference = next9AM.difference(now);
    int hoursLeft = difference.inHours;
    int minutesLeft = difference.inMinutes.remainder(60);

    return '$hoursLeft:${minutesLeft.toString().padLeft(2, '0')}';
  }

   showFetchModal(BuildContext context) {
  if (consentAndHandleDetails.isEmpty) return;

  // modalPageController.jumpToPage(0); // 🔑 reset to first page

  String nextFetch = nextFecthDate.value;
  String lastFetch = LastFetchDate.value;

  DateTime nextFetchDate;
  DateTime lastFetchDate;

  try {
    nextFetchDate =
        nextFetch.isNotEmpty ? DateTime.parse(nextFetch) : DateTime.now();
  } catch (_) {
    nextFetchDate = DateTime.now();
  }

  try {
    lastFetchDate =
        lastFetch.isNotEmpty ? DateTime.parse(lastFetch) : DateTime.now();
  } catch (_) {
    lastFetchDate = DateTime.now();
  }

  String formattedNextFetch = formatWhatsAppDate2(nextFetchDate);
  String formattedLastFetch = formatWhatsAppDate(lastFetchDate);

  final double screenWidth = MediaQuery.of(context).size.width;

  bool limit = int.parse(fetchCount.value) >= 5;
  if (fipsMetricList.isEmpty) return;

  final FipsMetric metric = fipsMetricList.firstWhere(
    (item) => item.BankName == BankName.value,
    orElse: () => fipsMetricList.first,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparentColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.48, 
            child: isFected.value?Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
            child: Icon(Icons.sync, size: 26, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            "Sync in progress",
            textAlign: TextAlign.center,
             style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: 
                  Colors.black,
                                  ),
           
          ),
          const SizedBox(height: 10),
          Text(
            "Please wait while we retrieve the latest data from your bank. The process may take a moment depending on your bank's server response.",
            textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w300,
                                    fontSize: 12,
                                    color: AppColors.grey
                                  ),
          
          ),
           SizedBox(height: MediaQuery.sizeOf(context).height/30),
          SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
        Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Center(
          child: Text("Done", 
           style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color:  AppColors.backgroundColor
                                  ),)
         
        ),
        
      ),
    )
        ],
      ):
            PageView(
              controller: modalPageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                /// ================= PAGE 0 =================
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textStyle(
                        context: context,
                        text: "Connected Banks",
                        fontsize: 16,
                        c: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Column(
                          children: [
                            Image.network(
                              BankUrl.value,
                              width: 30,
                              height: 30,
                              errorBuilder: getErrorBankLogo(),
                            ),
                            const SizedBox(height: 8),
                            textStyle(
                              context: context,
                              text: BankName.value,
                              fontsize: 16,
                              c: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildInfoCard(
                        context: context,
                        title: "Average latency",
                        value: "${metric.latencyAvgMs + 40}ms",
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        context: context,
                        title: HomepageStringsDart().lastFetchLabel,
                        value: formattedLastFetch,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        context: context,
                        title: HomepageStringsDart().nextFetchTitle,
                        value: formattedNextFetch,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        context: context,
                        title: HomepageStringsDart().fetchCountTitle,
                        value: '${!limit ? fetchCount.value : "5"}/5',
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            modalPageController.animateToPage(
                              1,
                              duration:
                                  const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.14,
                            height: MediaQuery.of(context).size.height / 16,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: textStyleOnly2(
                                context: context,
                                text: "Continue",
                                fontsize: 16,
                                color: AppColors.backgroundColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// ================= PAGE 1 =================
                const BankSyncFlow(),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  double getPersentage() {
    if (BankName.value == "") return 100.0;
    final FipsMetric metric = fipsMetricList.firstWhere(
      (item) => item.BankName == BankName.value,
      orElse: () => fipsMetricList.first,
    );
    return metric.successPercent.toDouble();
  }

  Widget getInfoAboutBank(BuildContext context) {
    if (fipsMetricList.isEmpty) return SizedBox();

    final FipsMetric metric = fipsMetricList.firstWhere(
      (item) => item.BankName == BankName.value,
      orElse: () => fipsMetricList.first,
    );

    final String text = _generateBankFetchInfo(metric) +
        "\nAverage latency: ${metric.latencyAvgMs + 40}ms. ";
    

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Column(
        children: [
          textStyle(
            context: context,
            text: text,
            fontWeight: FontWeight.bold,
            fontsize: 14,
            c: AppColors.bg1,
            iswrap: true,
          )
        ],
      ),
    );
  }

  String _generateBankFetchInfo(FipsMetric metric) {
    String text1 =
        "Bank server is Up. All systems are working smoothly!";
    String text2 =
        "Bank server is responding slowly. Some operations may take longer than usual.";
    String text3 =
        "Bank server is currently down. Please try again later or check back shortly.";

    if (metric.successPercent >= 70)
      return text1;
    else if (metric.successPercent <= 40) return text3;
    return text2;
  }

 

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.newbg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          textStyleOnly2(
            context: context,
            text: title,
            fontsize:
                screenWidth < 400 ? 12 : 14,
            color: AppColors.bg1.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          textStyleOnly2(
            context: context,
            text: value,
            fontsize:
                screenWidth < 400 ? 10 : 12,
            color: AppColors.bg1,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  void checkAndFetchData() async {
    setUpSocketListenerMainPage(context);
    if (consentAndHandleDetails.isNotEmpty) {
      for (final item in consentAndHandleDetails) {
        getWeeklyfetchData(
          item.consentId,
          item.consendHandleId,
          item.sessionId,
          item.custId,
          item.lastFetch,
          item.bankName,
          item.fipId,
          item.fetchCount,
          item.accountId,
        );
      }
    }
    final SharedPreferences pref =
        await SharedPreferences.getInstance();
    pref.setString(
        "fetchingData", consentAndHandleDetails.toString());
    isFected.value = true;
    fetchNow.value = false;
    scrollBankPage.value = 0;
    callApi(context);
    Navigator.pop(context);
  }

}


