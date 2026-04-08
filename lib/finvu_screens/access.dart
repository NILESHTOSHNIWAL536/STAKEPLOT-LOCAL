import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/integration.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_padding_sizes.dart';
import 'package:flutter_application_code_stakeplot/controllers/fipmetrics-controller.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/skipFInvuProcess.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Constants/app_styles.dart';
import '../loginservices/login.dart';
import '../onboarding_screens/onboarding_screen.dart';
import 'LinkingAccount.dart';

class Access extends StatefulWidget {
  const Access({super.key});

  @override
  State<Access> createState() => _AccessState();
}

class _AccessState extends State<Access> {
  RxBool flag = true.obs;
  RxBool showDetails = false.obs;

  double spaceSmall = 8;
  double spaceMedium = 10;
  double spaceLarge = 30;

  @override
  void initState() {
    super.initState();
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMM yyyy').format(date);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
      bottomNavigationBar: const SafeArea(child: BottomBar()),
      appBar: AppBar(
        backgroundColor: AppColors.newbg,
        toolbarHeight: 40,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => showSkipModal2(context),
              child: Icon(Icons.login, color: Colorcodes.black, size: 30),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          color: Colorcodes.black,
          onPressed: () {
            if (showDetails.value) {
              showDetails.value = false;
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10.0, 16, 16, 0),
          child: Obx(() {
            if (!flag.value) return const Loader();

            if (showDetails.value) return getInfomationsAboutUserConsnt();
            return Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          topHeader(),
                          informationBankAccount(),
                          pauseOrCancle(),
                        ],
                      ),
                      // ── GivePermissionWidget with warning confirmation ────
                      GivePermissionWidget(
                        fipId: fipIdSeleted.value,
                        onApprove: approveConsentRequest,
                        onDecline: () => showDialogBoxForDecline(context),
                        onShowWarningConfirm: (warnings, onConfirmed) =>
                            _showWarningConfirmDialog(
                                context, warnings, onConfirmed),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Warning confirmation dialog ──────────────────────────────────────────

  void _showWarningConfirmDialog(
    BuildContext context,
    List<FipUserMessage> warnings,
    VoidCallback onConfirmed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _WarningConfirmDialog(
        warnings: warnings,
        onConfirmed: onConfirmed,
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget topHeader() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: FinvuStrings().shareAccountsWithStakeplot,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 16,
                  color: AppColors.accentColor,
                  lineHeight: 2.0,
                ),
                children: [
                  TextSpan(
                    text: FinvuStrings().smartFinanceInsights,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )
    ]);
  }

  // ── Date range widget ─────────────────────────────────────────────────────

  Widget vSpace(double height) => SizedBox(height: height);

  Widget dateRangeWidget() {
    final fromDate = formatDate(
      finvuConsentRequestDetailInfo.consentDateTimeRange.from.toString(),
    );
    final toDate = formatDate(
      finvuConsentRequestDetailInfo.consentDateTimeRange.to.toString(),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.grey),
        const SizedBox(width: 6),
        Text(fromDate,
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w500, fontSize: 16, color: AppColors.bg1)),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward, size: 14, color: AppColors.grey),
        const SizedBox(width: 8),
        Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.grey),
        const SizedBox(width: 6),
        Text(toDate,
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.accentColor)),
      ],
    );
  }

  // ── Info card list ────────────────────────────────────────────────────────

  Widget informationBankAccount() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8)),
              child: accounts(
                FinvuStrings().accountsSharedTitle,
                "${seletedAccountIds.length} ${FinvuStrings().accountsSharedValue}",
                Sign.accsShared,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8)),
              child: accountsWithWidget(
                FinvuStrings().permissionValidity,
                dateRangeWidget(),
                Sign.permissionValidity,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8)),
              child: accounts(
                FinvuStrings().frequencyOfAccess,
                FinvuStrings().frequencyOfAccessSubText,
                Sign.frequencyOfAccess,
              ),
            ),
            const SizedBox(height: 22),
            viewMoreDetailsButton(),
          ],
        ),
      ),
    );
  }

  Widget viewMoreDetailsButton() {
    return GestureDetector(
      onTap: () => showDetails.value = true,
      child: Center(
        child: Text(
          FinvuStrings().viewMoreDetails,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget accountLikedInfo() {
    return Column(
      children: seletedAccountInfomations
          .map((data) => accountInfoDetailsUi(data))
          .toList(),
    );
  }

  Widget accountInfoDetailsUi(FinvuLinkedAccountDetailsInfo data) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: Wrap(
        runAlignment: WrapAlignment.spaceAround,
        children: [
          textStyle(data.fipName, 14, AppColors.bg3),
          const SizedBox(width: 5),
          textStyle(data.accountType, 14, AppColors.bg3),
          const SizedBox(width: 5),
          textStyle(data.maskedAccountNumber, 14, AppColors.bg3),
        ],
      ),
    );
  }

  Widget sectionHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w400, fontSize: 16, color: AppColors.grey)),
        squareIcon(icon),
      ],
    );
  }

  Widget sectionValue(String value) {
    return Text(value,
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.accentColor));
  }

  Widget getInfomationsAboutUserConsnt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  vSpace(spaceMedium),
                  Text("Details Of Shared Accounts",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColors.primaryColor)),
                  vSpace(Colorcodes.space),
                  sectionHeader(FinvuStrings().approvalRequestedOn,
                      Icons.calendar_month_outlined),
                  vSpace(spaceSmall),
                  sectionValue(formatDate(finvuConsentRequestDetailInfo
                      .consentDateTimeRange.from
                      .toString())),
                  vSpace(spaceMedium),
                  sectionHeader(FinvuStrings().purpose, Icons.description),
                  vSpace(spaceSmall),
                  sectionValue(
                      finvuConsentRequestDetailInfo.consentPurposeInfo.text),
                  vSpace(spaceMedium),
                  sectionHeader(FinvuStrings().accountDetails, Icons.person),
                  vSpace(spaceSmall),
                  sectionValue(FinvuStrings().profileSummaryTransactions),
                  vSpace(spaceMedium),
                  sectionHeader(
                      FinvuStrings().dataLife, Icons.access_time_filled),
                  vSpace(spaceSmall),
                  sectionValue(
                      "${finvuConsentRequestDetailInfo.consentDataLifePeriod.value} "
                      "${finvuConsentRequestDetailInfo.consentDataLifePeriod.unit}"),
                  vSpace(spaceMedium),
                  sectionHeader(
                      FinvuStrings().approvalExpiry, Icons.event_busy),
                  vSpace(spaceSmall),
                  sectionValue(formatDate(finvuConsentRequestDetailInfo
                      .consentDateTimeRange.to
                      .toString())),
                  vSpace(spaceMedium),
                  sectionHeader(
                      FinvuStrings().accountTypes, Icons.android_sharp),
                  vSpace(spaceSmall),
                  Wrap(
                    children: finvuConsentRequestDetailInfo.fiTypes!
                        .map((e) => Text("$e, ",
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: 16,
                                color: AppColors.accentColor)))
                        .toList(),
                  ),
                  vSpace(spaceLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
          InkWell(
            onTap: () => showDetails.value = false,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.1,
              padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text("Got it",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.backgroundColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget squareIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: const Color(0xFF4A4F8C)),
    );
  }

  Widget accountsWithWidget(String title, Widget valueWidget, String icon) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarProfileImageZero(url: icon, width: 40, height: 40),
              const SizedBox(width: 10),
              Text(title,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.primaryColor)),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: valueWidget),
          ),
        ],
      ),
    );
  }

  Widget accounts(String title, String value, String url) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarProfileImageZero(url: url, width: 40, height: 40),
              const SizedBox(width: 10),
              Text(title,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.primaryColor)),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text(value,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.accentColor),
                  overflow: TextOverflow.clip),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: title == "Accounts Shared"
                ? accountLikedInfo()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget pauseOrCancle() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: AppSizes.p20, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.3,
            child: Text(
              FinvuStrings().pauseOrCancelSharing,
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w400, fontSize: 15, color: AppColors.bg3),
            ),
          ),
        ],
      ),
    );
  }

  Widget textStyle(
    text, [
    double fontsize = 12,
    Color c = AppColors.bg1,
    FontWeight fontWeight = FontWeight.w500,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 7),
          Text(
            text.toString(),
            style: FontManager().getTextStyle(context,
                lWeight: fontWeight, fontSize: fontsize, color: c),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Consent actions ───────────────────────────────────────────────────────

  void approveConsentRequest() async {
    try {
      
      FinvuConsentRequestDetailInfo info = await finvuManager.getConsentRequestDetails(handleId.value);
      await finvuManager.approveConsentRequest(info, seletedAccountInfomations);
      snackBarCalled(context, SnackbarData().consentApproved);
      FetchTransactionFromFinvuApi(context);

    } catch (e) {
      skipOrLets.value = "Skip";
      snackBarCalledfail(context, SnackbarData().consentApproveError);
    }
  }

  void showDialogBoxForDecline(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 300,
          height: 180,
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textStyle(FinvuStrings().areYouSure, 20, AppColors.primaryColor,
                  FontWeight.bold),
              const SizedBox(height: 10),
              textStyle(FinvuStrings().declineConfirmation, 15),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: AppColors.bg1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: textStyle(FinvuStrings().no, 15),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => decline(),
                    child: textStyle(FinvuStrings().yes, 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void decline() async {
    try {
      FinvuConsentRequestDetailInfo consentInfo =
          await finvuManager.getConsentRequestDetails(handleId.value);
      finvuManager.denyConsentRequest(consentInfo);
      logoutAndDisconnect();
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/ShareAccountLogin', (Route<dynamic> route) => false);
      Navigator.pushNamed(context, "/ShareAccountLogin");
      snackBarCalledfail(context, SnackbarData().consentDeclined);
    } catch (e) {
      snackBarCalledfail(context, SnackbarData().consentDisapproveError);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GivePermissionWidget
// ══════════════════════════════════════════════════════════════════════════════

class GivePermissionWidget extends StatelessWidget {
  final String fipId;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  /// Called when the user taps "Give Permission" but warnings exist.
  /// Parent must show a dialog then call onConfirmed if the user proceeds.
  final void Function(
    List<FipUserMessage> warnings,
    VoidCallback onConfirmed,
  )? onShowWarningConfirm;

  const GivePermissionWidget({
    Key? key,
    required this.fipId,
    required this.onApprove,
    required this.onDecline,
    this.onShowWarningConfirm,
  }) : super(key: key);

  FipMetricsController? get _metrics =>
      Get.isRegistered<FipMetricsController>() ? FipMetricsController.to : null;

  @override
  Widget build(BuildContext context) {
    final messages = _metrics?.dataReadinessMessages(fipId) ?? [];

    final errors =
        messages.where((m) => m.severity == FipMessageSeverity.error).toList();
    final warnings = messages
        .where((m) => m.severity == FipMessageSeverity.warning)
        .toList();
    final infoMsgs =
        messages.where((m) => m.severity == FipMessageSeverity.info).toList();

    final hasError = errors.isNotEmpty;
    final hasWarning = warnings.isNotEmpty;
    final blocking = [...errors, ...warnings];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Error / warning banner ────────────────────────────────────
          if (blocking.isNotEmpty) ...[
            _DataReadinessBanner(messages: blocking),
            const SizedBox(height: 16),
          ],

          // ── Give Permission button ─────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (hasWarning && onShowWarningConfirm != null || hasError) {
                // Tap with warnings → show confirmation dialog first
                onShowWarningConfirm!(warnings, onApprove);
              } else {
                onApprove();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width / 1.1,
              padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p14),
              decoration: BoxDecoration(
                color: hasError
                    ? AppColors.primaryColor.withOpacity(0.38)
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Warning icon badge on button when warnings exist
                  if (hasWarning && !hasError) ...[
                    const Icon(Icons.warning_amber_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  // Lock icon when hard error
                  if (hasError) ...[
                    const Icon(Icons.lock_outline_rounded,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    hasError
                        ? 'Permission unavailable'
                        : FinvuStrings().givePermission,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: hasError
                          ? AppColors.backgroundColor.withOpacity(0.6)
                          : AppColors.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info messages between buttons ─────────────────────────────
          if (infoMsgs.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...infoMsgs.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _InfoRow(message: m),
                )),
          ],

          // ── Decline button ─────────────────────────────────────────────
          InkWell(
            onTap: onDecline,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: MediaQuery.of(context).size.width / 1.1,
              padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p20),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Center(
                child: Text(
                  FinvuStrings().decline,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.redColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Warning confirmation dialog
// ══════════════════════════════════════════════════════════════════════════════

class _WarningConfirmDialog extends StatelessWidget {
  final List<FipUserMessage> warnings;
  final VoidCallback onConfirmed;

  const _WarningConfirmDialog({
    required this.warnings,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      size: 20, color: Color(0xFFFB8C00)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Proceed with caution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'We detected the following issues with this bank. You can still proceed, but data access may be affected.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF636366),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            // ── Warning list ──────────────────────────────────────────────
            ...warnings.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFFFCC80), width: 0.8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.warning_amber_rounded,
                            size: 14, color: Color(0xFFFB8C00)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              w.detail,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFBF360C),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFD1D1D6), width: 0.8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Go back',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3C3C3C)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmed();
                    },
                    child: const Text(
                      'Proceed anyway',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared sub-widgets
// ══════════════════════════════════════════════════════════════════════════════

class _DataReadinessBanner extends StatefulWidget {
  final List<FipUserMessage> messages;
  const _DataReadinessBanner({required this.messages});

  @override
  State<_DataReadinessBanner> createState() => _DataReadinessBannerState();
}

class _DataReadinessBannerState extends State<_DataReadinessBanner> {
  bool _expanded = false;

  FipUserMessage get _top {
    final errors =
        widget.messages.where((m) => m.severity == FipMessageSeverity.error);
    return errors.isNotEmpty ? errors.first : widget.messages.first;
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.messages.length > 1;
    final topCfg = _cfg(_top.severity);

    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      decoration: BoxDecoration(
        color: topCfg.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: topCfg.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(topCfg.icon, size: 16, color: topCfg.iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_top.title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: topCfg.titleColor)),
                      const SizedBox(height: 3),
                      Text(_top.detail,
                          style: TextStyle(
                              fontSize: 12,
                              color: topCfg.detailColor,
                              height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_expanded && hasMultiple) ...[
            const SizedBox(height: 8),
            const Divider(
                height: 1,
                thickness: 0.5,
                indent: 12,
                endIndent: 12,
                color: Color(0x22000000)),
            const SizedBox(height: 4),
            ...widget.messages.skip(1).map((m) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: _SubMessage(message: m),
                )),
            const SizedBox(height: 8),
          ],
          if (hasMultiple)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded
                          ? 'Show less'
                          : '+${widget.messages.length - 1} more issue${widget.messages.length > 2 ? 's' : ''}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: topCfg.iconColor),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: topCfg.iconColor,
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  _MsgStyle _cfg(FipMessageSeverity s) {
    switch (s) {
      case FipMessageSeverity.error:
        return _MsgStyle(
            bg: const Color(0xFFFFEBEE),
            border: const Color(0xFFEF9A9A),
            icon: Icons.error_outline_rounded,
            iconColor: const Color(0xFFE53935),
            titleColor: const Color(0xFFC62828),
            detailColor: const Color(0xFFB71C1C));
      case FipMessageSeverity.warning:
        return _MsgStyle(
            bg: const Color(0xFFFFF8E1),
            border: const Color(0xFFFFCC80),
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFB8C00),
            titleColor: const Color(0xFFE65100),
            detailColor: const Color(0xFFBF360C));
      case FipMessageSeverity.info:
        return _MsgStyle(
            bg: const Color(0xFFE3F2FD),
            border: const Color(0xFF90CAF9),
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF1976D2),
            titleColor: const Color(0xFF0D47A1),
            detailColor: const Color(0xFF1565C0));
    }
  }
}

class _SubMessage extends StatelessWidget {
  final FipUserMessage message;
  const _SubMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final isError = message.severity == FipMessageSeverity.error;
    final color = isError ? const Color(0xFFE53935) : const Color(0xFFFB8C00);
    final icon =
        isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.title,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: color)),
              const SizedBox(height: 2),
              Text(message.detail,
                  style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.85),
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final FipUserMessage message;
  const _InfoRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 13, color: Color(0xFF1976D2)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(message.detail,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF1565C0), height: 1.4)),
        ),
      ],
    );
  }
}

class _MsgStyle {
  final Color bg, border, iconColor, titleColor, detailColor;
  final IconData icon;
  const _MsgStyle({
    required this.bg,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.detailColor,
  });
}
