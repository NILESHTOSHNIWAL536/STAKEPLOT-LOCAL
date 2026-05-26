import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../Constants/theme_helper.dart';
import '../../components/shared_utils.dart';
import '../../model/bank_model.dart';
import '../../model/fips_metric_model.dart';
// <-- make sure this is imported
import '../../repository/bankinfo.dart';
import '../../widget_services/widget_service.dart';

import 'bank_sync_flow.dart';

RxBool isBankLinked = false.obs;
RxInt modalPage = 0.obs;
final PageController modalPageController = PageController();

class Nextfetch extends StatefulWidget {
  final BankAccountModel bankAccount;

  const Nextfetch({super.key, required this.bankAccount});

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
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCurrentAccountFetching =
          isBankHandleFetching(widget.bankAccount.consendHandleId);
      final String fetchLabel = isCurrentAccountFetching
          ? "${widget.bankAccount.bankName} syncing"
          : HomepageStringsDart().nextFetchLabel;
      String formattedNextFetch = '';
      try {
        if (widget.bankAccount.nextFetch.isNotEmpty) {
          DateTime nextFetchDateTime =
              DateTime.parse(widget.bankAccount.nextFetch);
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
                      isCurrentAccountFetching
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
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 2.4,
                          ),
                          child: Text(
                            fetchLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.backgroundColor,
                              lineHeight: 18 / fontSize,
                            ),
                          ),
                        ),
                      ),
                      textStyle(
                          context: context,
                          text: isCurrentAccountFetching
                              ? ""
                              : formattedNextFetch,
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
    _selectWidgetAccount(context);

    if (modalPageController.hasClients) {
      modalPageController.jumpToPage(0);
    }

    // modalPageController.jumpToPage(0); // 🔑 reset to first page

    if (fipsMetricList.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final FipsMetric metric = fipsMetricList.firstWhere(
              (item) => item.BankName == BankName.value,
              orElse: () => fipsMetricList.first,
            );
            final selectedConsent = _selectedConsentInfo();
            final formattedNextFetch = _formatFetchDate(nextFecthDate.value);
            final formattedLastFetch = _formatFetchDate(LastFetchDate.value);
            final currentFetchCount = int.tryParse(fetchCount.value) ?? 0;
            final bool limit = currentFetchCount >= 5;

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: AppSizes.p24),
                decoration: BoxDecoration(
                  color: context.appColors.dialogBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.58,
                  child: isBankHandleFetching(
                          widget.bankAccount.consendHandleId)
                      ? _buildSyncInProgress(context)
                      : PageView(
                          controller: modalPageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Connected Banks",
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 16,
                                      lWeight: FontWeight.w500,
                                      color: context.appColors.onSurface,
                                      lineHeight: 21 / fontSize,
                                    ),
                                  ),
                                  SizedBox(height: AppSizes.h16),
                                  connectedBanksRow(
                                    context,
                                    onBankChanged: () => setModalState(() {}),
                                  ),
                                  SizedBox(height: AppSizes.h20),
                                  _buildInfoCard(
                                    context: context,
                                    title: "Fetching bank",
                                    value: BankName.value,
                                  ),
                                  SizedBox(height: AppSizes.h12),
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
                                    title:
                                        HomepageStringsDart().fetchCountTitle,
                                    value:
                                        '${!limit ? fetchCount.value : "5"}/5',
                                  ),
                                  SizedBox(height: AppSizes.h20),
                                  _buildContinueButton(context),
                                ],
                              ),
                            ),
                            BankSyncFlow(
                              consentInfo: selectedConsent,
                              bankName: BankName.value,
                              bankLogo: BankUrl.value,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSyncInProgress(BuildContext context) {
    final displayBankName = fetchingBankNameForHandle(
      widget.bankAccount.consendHandleId,
      widget.bankAccount.bankName,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: context.appColors.iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.sync, size: 26, color: context.appColors.primary),
        ),
        SizedBox(height: AppSizes.h20),
        Text(
          "$displayBankName sync in progress",
          textAlign: TextAlign.center,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 16,
            color: context.appColors.onSurface,
          ),
        ),
        SizedBox(height: AppSizes.h10),
        Text(
          "Please wait while we retrieve the latest data from $displayBankName. The process may take a moment depending on the bank's server response.",
          textAlign: TextAlign.center,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w300,
            fontSize: 12,
            color: context.appColors.secondaryText,
            lineHeight: 18 / fontSize,
          ),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height / 30),
        SizedBox(
          width: double.infinity,
          height: AppSizes.h48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "Done",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.backgroundColor,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          modalPageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          width: double.infinity,
          height: AppSizes.h48,
          decoration: BoxDecoration(
            color: context.appColors.primary,
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
    );
  }

  String _formatFetchDate(String value) {
    try {
      return value.isNotEmpty
          ? formatWhatsAppDate(DateTime.parse(value))
          : HomepageStringsDart().notScheduled;
    } catch (_) {
      return HomepageStringsDart().notScheduled;
    }
  }

  ConsentInfoModel? _selectedConsentInfo() {
    if (consentAndHandleDetails.isEmpty) return null;

    final selectedAccount = scrollBankPage.value >= 0 &&
            scrollBankPage.value < bankAccountLinkedList.length
        ? bankAccountLinkedList[scrollBankPage.value]
        : null;

    return consentAndHandleDetails.firstWhereOrNull(
          (item) =>
              selectedAccount != null &&
              item.consendHandleId == selectedAccount.consendHandleId,
        ) ??
        consentAndHandleDetails.firstWhereOrNull(
          (item) => item.accountId == accountId.value,
        ) ??
        consentAndHandleDetails.firstWhereOrNull(
          (item) =>
              selectedAccount != null && item.fipId == selectedAccount.fipId,
        ) ??
        consentAndHandleDetails.firstWhereOrNull(
          (item) => item.bankName == BankName.value,
        );
  }

  void _selectWidgetAccount(BuildContext context) {
    final index = bankAccountLinkedList.indexWhere(
      (item) => item.accountId == widget.bankAccount.accountId,
    );
    if (index == -1) return;
    bankInfoController.selectBankAccount(index, context);
  }

  Widget connectedBanksRow(BuildContext context,
      {VoidCallback? onBankChanged}) {
    if (bankAccountLinkedList.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p6, horizontal: 6),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.appColors.border,
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
            final bool isActive = bank.accountId == accountId.value;

            return GestureDetector(
              onTap: () {
                bankInfoController.selectBankAccount(index, context);
                onBankChanged?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 86,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.p6,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.appColors.iconBackground
                      : AppColors.transparentColor,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontManager().getTextStyle(context,
                          fontSize: 12,
                          lWeight: FontWeight.w500,
                          color: isActive
                              ? context.appColors.primary
                              : context.appColors.onSurface,
                          lineHeight: 18 / fontSize),
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
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: textStyleOnly2(
              context: context,
              text: title,
              fontsize: screenWidth < 400 ? 12 : 14,
              color: context.appColors.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: AppSizes.w10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontManager().getTextStyle(
                context,
                fontSize: screenWidth < 400 ? 10 : 12,
                color: context.appColors.secondaryText,
                lWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
