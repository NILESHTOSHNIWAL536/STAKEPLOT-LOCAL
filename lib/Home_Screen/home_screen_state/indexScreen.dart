// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/autopay_detection_screen.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardStack.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/dummy_insight_api_screen.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/finance_analytics/finance_chart.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:get/get.dart';
// import '../../Constants/core/app_component_sizes.dart';
// import '../../Constants/core/app_padding_sizes.dart';
// import '../../components/helper.dart';
// import '../Home/home_AppBar.dart';
// import '../Home/init_Api_Calls.dart';

// class IndexScreen extends StatelessWidget {
//   final ScrollController scrollControllerHome;
//   IndexScreen({Key? key, required this.scrollControllerHome})
//       : super(key: key) {}
// //  FinoraController finoraController = ControllerManagement.finoraController;
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     final colors = context.appPalette;
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: AppSizes.p4),
//         child: RefreshIndicator(
//           color: colors.blackColor,
//           backgroundColor: colors.whiteColor,
//           strokeWidth: 2.5,
//           displacement: 40, // spinner position from top
//           edgeOffset: 0, // start right at the top
//           onRefresh: () async {
//             // Keep refresh indicator visible for at least 2 seconds
//             await Future.delayed(const Duration(seconds: 1));
//             callApi(context);
//           },
//           child: SingleChildScrollView(
//             controller: scrollControllerHome,
//             child: Column(
//               children: [
//                 buildTopSection(context),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 13),
//                   child: Column(
//                     children: [
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             manualTransactionButton(context),
//                             historyButton(context)
//                           ]),
//                       const SizedBox(height: 10),
//                       AutoPayQuickAddButton(),

//                       const SizedBox(height: 10),
//                       _insightDashboardButton(context),

//                       Padding(
//                         padding:
//                             const EdgeInsets.symmetric(vertical: AppSizes.h10),
//                         child: SizedBox(
//                           height: AppComponentSizes.h4_5,
//                           child: const MonthlySpendingChart(),
//                         ),
//                       ),

//                       Obx(() => isFinoraVisible.value
//                           ? FinoraInsightsSection()
//                           : FinoraInsightsSection()),

//                       Obx(() => isAutoPayFected.value
//                           ? GetAutopays(height)
//                           : GetAutopays(height)),

//                       // SizedBox(height: height * 0.5, child: InsightsScreen()),

//                       CategoriseSpending(),
//                       const SizedBox(
//                         height: 14,
//                       ),
//                       SizedBox(
//                         height: AppComponentSizes.h30,
//                         child: Text(HomepageStringsDart().madeWithLove,
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.w500,
//                                 fontSize: 16,
//                                 color: colors.blackColor)),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _insightDashboardButton(BuildContext context) {
//     final colors = context.appColors;
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const DummyInsightApiScreen(),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//         decoration: BoxDecoration(
//           color: colors.primary.withValues(alpha: 0.08),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.insights, color: colors.primary, size: 22),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "Spending insights",
//                 style: FontManager().getTextStyle(
//                   context,
//                   fontSize: 15,
//                   lWeight: FontWeight.w700,
//                   color: colors.primary,
//                 ),
//               ),
//             ),
//             Icon(Icons.chevron_right, color: colors.primary),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget GetAutopays(height) {
//     return allAutoPayData.isEmpty
//         ? const SizedBox.shrink()
//         : SizedBox(height: AppComponentSizes.h3, child: AutoPayCarousel());
//   }
// }

// class AutoPayQuickAddButton extends StatelessWidget {
//   const AutoPayQuickAddButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appColors;
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const AutoPayDetectionScreen(),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//         decoration: BoxDecoration(
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: colors.border),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: colors.primary.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.add, color: colors.primary, size: 22),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "Autopay & repeating transactions",
//                 style: FontManager().getTextStyle(
//                   context,
//                   fontSize: 14,
//                   lWeight: FontWeight.w700,
//                   color: colors.onBackground,
//                 ),
//               ),
//             ),
//             Icon(Icons.chevron_right, color: colors.secondaryText),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget buildTopSection(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
//     // width: MediaQuery.of(context).size.width,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const TopRightIconsWidget(),
//         Bankscardsslider(),
//       ],
//     ),
//   );
// }



import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/autopay_detection_screen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardStack.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/dummy_insight_api_screen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_analytics/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/finora_controller.dart';
import 'package:get/get.dart';
import '../../Constants/app_assets.dart';
import '../../Constants/app_svgs.dart';
import '../../Constants/core/app_component_sizes.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';
import '../Home/home_AppBar.dart';
import '../Home/init_Api_Calls.dart';
import '../finora_analytics/finora_dashboard.dart';

class IndexScreen extends StatelessWidget {
  final ScrollController scrollControllerHome;
  IndexScreen({Key? key, required this.scrollControllerHome})
      : super(key: key) {}
//  FinoraController finoraController = ControllerManagement.finoraController;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final colors = context.appPalette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: RefreshIndicator(
          color: colors.blackColor,
          backgroundColor: colors.whiteColor,
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
                Column(
                  children: [

                    // const SizedBox(height: 10),

                    _last7DaysHeader(context),

                    Container(
                      decoration: BoxDecoration(
                        color: colors.whiteColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50)),
                        border: Border.all(color: colors.whiteColor),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const FinanceSummaryDashboard(),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: AppSizes.h10),
                            child: SizedBox(
                              height: AppComponentSizes.h4_5,
                              child: const MonthlySpendingChart(),
                            ),
                          ),



                          Obx(() => isAutoPayFected.value
                              ? GetAutopays(height)
                              : GetAutopays(height)),

                          // SizedBox(height: height * 0.5, child: InsightsScreen()),
 AutoPayQuickAddButton(),

                    const SizedBox(height: 10),
                    _insightDashboardButton(context),
                    const SizedBox(height: 10),
                          CategoriseSpending(),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),
                    SizedBox(
                      height: AppComponentSizes.h30,
                      child: Text(HomepageStringsDart().madeWithLove,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 16,
                              color: colors.blackColor)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _last7DaysHeader(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<FinoraController>();

    return Obx(() {
      final weekDebit = controller.totalDebitThisWeek.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.iconFillColor.withValues(alpha: 0.02),
            border: Border(
              top: BorderSide(color: colors.bottomText, width: 1),
              left: BorderSide(color: colors.bottomText, width: 1),
              right: BorderSide(color: colors.bottomText, width: 1),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last 7 Days',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 13,
                      lWeight: FontWeight.w500,
                      color: colors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.arrow_downward_rounded,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '₹${formatMoneyIndian(weekDebit.toStringAsFixed(0))}',
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 15,
                          lWeight: FontWeight.w700,
                          color: colors.blackColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.arrow_upward_rounded,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '₹${formatMoneyIndian(weekDebit.toStringAsFixed(0))}',
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 15,
                          lWeight: FontWeight.w700,
                          color: colors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: ResponsiveSvg(
                  asset: HomeSvgs.lastSevenDays,
                  widthFactor: 2,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _insightDashboardButton(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DummyInsightApiScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.insights, color: colors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Spending insights",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 15,
                  lWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: colors.primary),
          ],
        ),
      ),
    );
  }

  Widget GetAutopays(height) {
    return allAutoPayData.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(height: AppComponentSizes.h3, child: AutoPayCarousel());
  }
}

class AutoPayQuickAddButton extends StatelessWidget {
  const AutoPayQuickAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AutoPayDetectionScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, color: colors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Autopay & repeating transactions",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w700,
                  color: colors.onBackground,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: colors.secondaryText),
          ],
        ),
      ),
    );
  }
}

Widget buildTopSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
    // width: MediaQuery.of(context).size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TopRightIconsWidget(),
        Bankscardsslider(),
      ],
    ),
  );
}

