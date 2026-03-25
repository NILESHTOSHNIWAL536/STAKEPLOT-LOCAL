import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardStack.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora_last2months_dashboard.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_analytics/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:get/get.dart';

import '../../Constants/core/app_component_sizes.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../components/helper.dart';
import '../../controllers/controllerManagement.dart';
import '../../controllers/finora_controller.dart';
import '../Home/home_AppBar.dart';
import '../Home/init_Api_Calls.dart';

class IndexScreen extends StatelessWidget {
  final ScrollController scrollControllerHome;
   IndexScreen({Key? key, required this.scrollControllerHome})
      : super(key: key){
       
      }
//  FinoraController finoraController = ControllerManagement.finoraController;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p4),
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
                buildTopSection(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            manualTransactionButton(context),
                            historyButton(context)
                          ]),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSizes.h10),
                        child: SizedBox(
                          height: AppComponentSizes.h5,
                          child: const SpendingCardTwoPanels(),
                        ),
                      ),

                      Obx(() => isFinoraVisible.value
                          ? const SwipeableCardsScreen()
                          : const SwipeableCardsScreen()),

                      Obx(() => isAutoPayFected.value
                          ? GetAutopays(height)
                          : GetAutopays(height)),

                      // SizedBox(height: height * 0.5, child: InsightsScreen()),

                      DoughnutChartExample(),
                      const SizedBox(
                        height: 14,
                      ),
                      SizedBox(
                        height: AppComponentSizes.h30,
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
      ),
    );
  }

  Widget GetAutopays(height) {
    return allAutoPayData.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(height: AppComponentSizes.h3, child: CardStackScreen());
  }

  // Widget GetFinora(double height) {
  //   return Obx(() {
  //     return SizedBox(
  //       height: height * (totalDebitThisMonth.value <= 0 ? 0.54 : 0.2),
  //       child: totalDebitThisMonth.value <= 0
  //           ? FinoraLastTwoMonthsDashboard()
  //           : const SwipeableCardsScreen(),
  //     );
  //   });
  // }
}

Widget buildTopSection(BuildContext context) {
  final height = MediaQuery.of(context).size.height;

  return Stack(
    children: [
      Positioned.fill(
        top: -100,
        child: AvatarProfileImageZero(
          url: HomePageIcons.background,
          width: 1,
          height: 1.2, // tweak for fit
        ),
      ),
      Container(
        height: height / 3,
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopRightIconsWidget(),
            NumberPickerScreen(),
          ],
        ),
      ),
    ],
  );
}
