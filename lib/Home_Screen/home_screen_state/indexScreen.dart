import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manually.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardStack.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora_last2months_dashboard.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/headsUpAndMoneyMap.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_analytics/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

import '../Home/init_Api_Calls.dart';

class IndexScreen extends StatelessWidget {
  final ScrollController scrollControllerHome;
  const IndexScreen({Key? key, required this.scrollControllerHome})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
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
              // Nextfetch(),
              SizedBox(
                height: height * 0.4,
                child: NumberPickerScreen(),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: height * 0.51,
                child: FinancePage(),
              ),
              SizedBox(
                height: height * 0.16,
                child: Manualtransaction(),
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
              SizedBox(height: height * 0.5, child: InsightsScreen()),
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
