import 'dart:async';
import 'dart:math';
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

import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../components/shared_utils.dart';
import '../../model/fips_metric_model.dart';
// <-- make sure this is imported
import '../../repository/bankinfo.dart';
import '../../widget_services/widget_service.dart';

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
          DateTime nextFetchDateTime = DateTime.parse(nextFecthDate.value);
          formattedNextFetch = formatWhatsAppDate(nextFetchDateTime);
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
                  width: MediaQuery.of(context).size.width / 1.4,
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
                              child: RotatingStopwatchIcon(
                                size: 22,
                                color: AppColors.backgroundColor,
                              ),
                              //  RotationTransition(
                              //   turns: Tween(
                              //     begin: 0.0,
                              //     end: 1.0,
                              //   )
                              //       .animate(
                              //         CurvedAnimation(
                              //           parent: _controller,
                              //           curve: Curves.linear,
                              //         ),
                              //       )
                              //       .drive(Tween(
                              //           begin: 1.0, end: 0.0)),
                              //   child:

                              //    AvatarProfileImageNextFetch(
                              //     url: HomePageIcons.fetch,
                              //     width: 40,
                              //     height: 35,
                              //   ),
                              // ),
                            ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        // const EdgeInsets.only(right:10,left:6,bottom: 2),
                        child: textStyle(
                            context: context,
                            text: isFected.value
                                ? HomepageStringsDart().fetchingInProgress
                                : HomepageStringsDart().nextFetchLabel,
                            fontWeight: FontWeight.w500,
                            c: AppColors.backgroundColor,
                            fontsize: 14,
                            lineHeight: 18 / fontSize),
                      ),
                      textStyle(
                          context: context,
                          text: isFected.value ? "" : formattedNextFetch,
                          fontWeight: FontWeight.w500,
                          c: AppColors.backgroundColor,
                          fontsize: 14,
                          lineHeight: 18 / fontSize),
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

    String formattedNextFetch = formatWhatsAppDate(nextFetchDate);
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
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: AppSizes.p30),
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: isFected.value
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: AppColors.border, shape: BoxShape.circle),
                          child: const Icon(Icons.sync,
                              size: 26, color: AppColors.primaryColor),
                        ),
                        SizedBox(height: AppSizes.h20),
                        Text(
                          "Sync in progress",
                          textAlign: TextAlign.center,
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.bg1,
                          ),
                        ),
                        SizedBox(height: AppSizes.h10),
                        Text(
                          "Please wait while we retrieve the latest data from your bank. The process may take a moment depending on your bank's server response.",
                          textAlign: TextAlign.center,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w300,
                              fontSize: 12,
                              color: AppColors.grey),
                        ),
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height / 30),
                        SizedBox(
                          width: double.infinity,
                          height: AppSizes.h48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Center(
                                child: Text(
                              "Done",
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.backgroundColor),
                            )),
                          ),
                        )
                      ],
                    )
                  : PageView(
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
                                  c: AppColors.bg1,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 21 / fontSize),
                              SizedBox(height: AppSizes.h16),
                              connectedBanksRow(context),
                              SizedBox(height: AppSizes.h20),
                              _buildInfoCard(
                                context: context,
                                title: "Average latency",
                                value: "${metric.latencyAvgMs + 40}ms",
                              ),
                              SizedBox(height: AppSizes.h12),
                              _buildInfoCard(
                                context: context,
                                title: HomepageStringsDart().lastFetchLabel,
                                value: formattedLastFetch,
                              ),
                              SizedBox(height: AppSizes.h12),
                              _buildInfoCard(
                                context: context,
                                title: HomepageStringsDart().nextFetchTitle,
                                value: formattedNextFetch,
                              ),
                              SizedBox(height: AppSizes.h12),
                              _buildInfoCard(
                                context: context,
                                title: HomepageStringsDart().fetchCountTitle,
                                value: '${!limit ? fetchCount.value : "5"}/5',
                              ),
                              SizedBox(height: AppSizes.h20),
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
                                    width: MediaQuery.of(context).size.width /
                                        1.14,
                                    height:
                                        MediaQuery.of(context).size.height / 16,
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

  Widget connectedBanksRow(BuildContext context) {
    if (bankAccountLinkedList.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p6, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.button,
          width: 1,
        ),
      ),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: bankAccountLinkedList.length,
          separatorBuilder: (_, __) => const SizedBox(width: 2),
          itemBuilder: (context, index) {
            final bank = bankAccountLinkedList[index];
            final bool isActive = bank.bankName == BankName.value;

            return GestureDetector(
              onTap: () {
                BankName.value = bank.bankName;
                BankUrl.value = bank.bankLogo;
                accountId.value = bank.accountId;
                LastFetchDate.value = bank.lastFetch;
                nextFecthDate.value = bank.nextFetch;
                fetchCount.value = bank.fetchCount.toString();

                calledFunctionToFetchData(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.p6,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.transparentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      bank.bankLogo,
                      width: 28,
                      height: 28,
                      errorBuilder: getErrorBankLogo(),
                    ),
                    SizedBox(height: AppSizes.h4),
                    Text(
                      bank.bankName,
                      style: FontManager().getTextStyle(context,
                          fontSize: 14,
                          lWeight: FontWeight.w500,
                          color: AppColors.accentColor,
                          lineHeight: 20 / fontSize),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
          const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p2),
      child: Column(
        children: [
          textStyle(
            context: context,
            text: text,
            fontWeight: FontWeight.w400,
            fontsize: 14,
            c: AppColors.accentColor,
            iswrap: true,
          )
        ],
      ),
    );
  }

  String _generateBankFetchInfo(FipsMetric metric) {
    String text1 = "Bank server is Up. All systems are working smoothly!";
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.newbg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          textStyleOnly2(
            context: context,
            text: title,
            fontsize: screenWidth < 400 ? 12 : 14,
            color: AppColors.accentColor,
            fontWeight: FontWeight.w400,
          ),
          textStyleOnly2(
            context: context,
            text: value,
            fontsize: screenWidth < 400 ? 10 : 12,
            color: AppColors.grey,
            fontWeight: FontWeight.w400,
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
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("fetchingData", consentAndHandleDetails.toString());
    isFected.value = true;
    fetchNow.value = false;
    scrollBankPage.value = 0;
    callApi(context);
    Navigator.pop(context);
  }
}
