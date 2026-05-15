import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/autopay_detection_screen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardStack.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/dummy_insight_api_screen.dart';
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
import '../Home/home_AppBar.dart';
import '../Home/init_Api_Calls.dart';

class IndexScreen extends StatelessWidget {
  final ScrollController scrollControllerHome;
  IndexScreen({Key? key, required this.scrollControllerHome})
      : super(key: key) {}
//  FinoraController finoraController = ControllerManagement.finoraController;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final colors = context.appColors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p4),
        child: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.background,
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
                      const SizedBox(height: 10),
                      AutoPayQuickAddButton(),

                      const SizedBox(height: 10),
                      _insightDashboardButton(context),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSizes.h10),
                        child: SizedBox(
                          height: AppComponentSizes.h4_5,
                          child: const MonthlySpendingChart(),
                        ),
                      ),

                      Obx(() => isFinoraVisible.value
                          ? FinoraInsightsSection()
                          : FinoraInsightsSection()),

                      Obx(() => isAutoPayFected.value
                          ? GetAutopays(height)
                          : GetAutopays(height)),

                      // SizedBox(height: height * 0.5, child: InsightsScreen()),

                      CategoriseSpending(),
                      const SizedBox(
                        height: 14,
                      ),
                      SizedBox(
                        height: AppComponentSizes.h30,
                        child: Text(HomepageStringsDart().madeWithLove,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: 16,
                                color: colors.primary)),
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
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
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
