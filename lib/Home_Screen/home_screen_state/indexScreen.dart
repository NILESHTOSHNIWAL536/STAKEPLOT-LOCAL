import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manually.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardStack.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora_last2months_dashboard.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/headsUpAndMoneyMap.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_analytics/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../components/helper.dart';
import '../Home/home_AppBar.dart';
import '../Home/init_Api_Calls.dart';

class IndexScreen extends StatelessWidget {
  final ScrollController scrollControllerHome;
  const IndexScreen({Key? key, required this.scrollControllerHome})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
final double sectionHeight = height * 0.52; // adjust as needed

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.backgroundColor,
        strokeWidth: 2.5,
        displacement: 40, // spinner position from top
        edgeOffset: 0, // start right at the top
        onRefresh: () async {
          // Keep refresh indicator visible for at least 2 seconds
          await Future.delayed(const Duration(seconds: 1));
          callApi(context);
        },
        child: SingleChildScrollView(
          controller: scrollControllerHome,
          child: Column(
            children: [
              // Nextfetch(),'
              // inside your parent Column / ListView where you had the three widgets

Stack(
  children: [
    // BACKGROUND IMAGE for the whole section
    SizedBox(
      height: sectionHeight,
      width: double.infinity,
      child: SvgPicture.asset(
        HomePageIcons.background, // <-- verify this path
        fit: BoxFit.cover,
      ),
    ),

    // FOREGROUND content (kept transparent)
    SizedBox(
      height: sectionHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // keep TopRightIconsWidget as-is (shouldn't paint an opaque bg)
            TopRightIconsWidget(),

            // number picker area — wrap in transparent material so it doesn't draw white bg
            SizedBox(
              height: height * 0.4,
              child: Material(
                type: MaterialType.transparency, // IMPORTANT: makes child transparent
                child: NumberPickerScreen(),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  ],
),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, ),
                child: Column(
                  children: [
                    SizedBox(
                     
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        manualTransactionButton(context),
                        historyButton(context)
                        ]
                    
                        
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: height * 0.25,
                      child: SpendingCardTwoPanels(),
                    ),
                   
                    const SizedBox(
                      height: 14,
                    ),
                    Obx(() => isFinoraVisible.value
                        ? GetFinora(height)
                        : GetFinora(height)),
                    const SizedBox(
                      height: 14,
                    ),
                    Obx(() => isAutoPayFected.value
                        ? GetAutopays(height)
                        : GetAutopays(height)),
                    // SizedBox(height: height * 0.5, child: InsightsScreen()),
                    DoughnutChartExample(),
                    const SizedBox(
                      height: 14,
                    ),
                    SizedBox(
                      height: 30,
                      child: Text(HomepageStringsDart().madeWithLove,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.primaryColor)),
                    ),
                  ],
                ),
              )
            
            ],
          ),
        ),
      ),
    );
  }

  Widget GetAutopays(height) {
    return allAutoPayData.isEmpty
        ? SizedBox.shrink()
        : SizedBox(height: height * 0.4, child: CardStackScreen());
  }

  Widget GetFinora(double height) {
    return Obx(() {
      return SizedBox(
        height: height * (totalDebitThisMonth.value <= 0 ? 0.54 : 0.21),
        child: totalDebitThisMonth.value <= 0
            ? FinoraLastTwoMonthsDashboard()
            : SwipeableCardsScreen(),
      );
    });
  }
}
