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

  @override
  void initState() {
    super.initState();
  }

  String _fmt(String d) => DateFormat('d MMM yyyy').format(DateTime.parse(d));

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      bottomNavigationBar: const SafeArea(child: BottomBar()),
      body: SafeArea(
        child: Obx(() {
          if (!flag.value) return const Loader();
          if (showDetails.value) return _detailsView();
          return _mainView();
        }),
      ),
    );
  }

  // ── Main consent view (Image 2) ───────────────────────────────────────────

  Widget _mainView() {
    return Column(
      children: [
        // ── Top bar ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_sharp),
                color: const Color(0xFF1C1C1E),
                onPressed: () {
                  if (showDetails.value) {
                    showDetails.value = false;
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Final Step',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showSkipModal2(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D1D6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.question_mark_rounded,
                      size: 16, color: Color(0xFF8E8E93)),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Purpose text ────────────────────────────────────
                RichText(
                  text: TextSpan(
                    text: FinvuStrings().shareAccountsWithStakeplot,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        fontSize: 15,
                        color: const Color(0xFF1C1C1E),
                        lineHeight: 1.5),
                    children: [
                      TextSpan(
                        text: ' ${FinvuStrings().smartFinanceInsights}',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Accounts Shared card ────────────────────────────
                _InfoCard(
                  icon: Sign.accsShared,
                  title: FinvuStrings().accountsSharedTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${seletedAccountIds.length} ${FinvuStrings().accountsSharedValue}',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 14,
                            color: const Color(0xFF1C1C1E)),
                      ),
                      const SizedBox(height: 6),
                      // Bank logos
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: bankImgMap.entries.map((e) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: Image.network(
                                e.value,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFE8F0FE),
                                  child: const Icon(Icons.account_balance,
                                      size: 14, color: Color(0xFF1A56C4)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Permission Validity card ────────────────────────
                _InfoCard(
                  icon: Sign.permissionValidity,
                  title: FinvuStrings().permissionValidity,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 16, color: Color(0xFF8E8E93)),
                      const SizedBox(width: 5),
                      Text(
                        _fmt(finvuConsentRequestDetailInfo
                            .consentDateTimeRange.from
                            .toString()),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 14,
                            color: const Color(0xFF1C1C1E)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: Color(0xFF8E8E93)),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_month_outlined,
                          size: 16, color: Color(0xFF8E8E93)),
                      const SizedBox(width: 5),
                      Text(
                        _fmt(finvuConsentRequestDetailInfo
                            .consentDateTimeRange.to
                            .toString()),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Frequency of Access card ────────────────────────
                _InfoCard(
                  icon: Sign.frequencyOfAccess,
                  title: FinvuStrings().frequencyOfAccess,
                  child: Text(
                    FinvuStrings().frequencyOfAccessSubText,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500,
                        fontSize: 14,
                        color: const Color(0xFF1C1C1E)),
                  ),
                ),

                const SizedBox(height: 14),

                // ── View more details ───────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => showDetails.value = true,
                    child: Text(
                      FinvuStrings().viewMoreDetails,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.primaryColor),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ── Bottom actions ──────────────────────────────────────────────
        _ConsentActions(
          fipId: fipIdSeleted.value,
          onApprove: _approveConsentRequest,
          onDecline: () => _showDeclineDialog(),
          onShowWarningConfirm: (warnings, onConfirmed) =>
              _showWarningDialog(context, warnings, onConfirmed),
        ),

        // ── Pause info ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 14, color: Color(0xFF8E8E93)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  FinvuStrings().pauseOrCancelSharing,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 11,
                      color: const Color(0xFF8E8E93)),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Powered securely by Ekjut',
            style: TextStyle(fontSize: 11, color: Color(0xFFAEAEB2)),
          ),
        ),
      ],
    );
  }

  // ── Details view (Image 1: "Final Step" details) ──────────────────────────

  Widget _detailsView() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_sharp),
                color: const Color(0xFF1C1C1E),
                onPressed: () => showDetails.value = false,
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Final Step',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E)),
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D1D6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.question_mark_rounded,
                    size: 16, color: Color(0xFF8E8E93)),
              ),
            ],
          ),
        ),

        // ── Bank logos row ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: bankImgMap.entries.take(4).map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Image.network(e.value,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE8F0FE),
                              child: const Icon(Icons.account_balance,
                                  size: 18, color: Color(0xFF1A56C4)),
                            )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details Of Shared Accounts',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: FinvuStrings().approvalRequestedOn,
                      value: _fmt(finvuConsentRequestDetailInfo
                          .consentDateTimeRange.from
                          .toString()),
                      icon: Icons.calendar_month_outlined,
                    ),
                    _DetailRow(
                      label: FinvuStrings().purpose,
                      value:
                          finvuConsentRequestDetailInfo.consentPurposeInfo.text,
                      icon: Icons.description_outlined,
                    ),
                    _DetailRow(
                      label: FinvuStrings().accountDetails,
                      value: FinvuStrings().profileSummaryTransactions,
                      icon: Icons.person_outline_rounded,
                    ),
                    _DetailRow(
                      label: FinvuStrings().dataLife,
                      value:
                          '${finvuConsentRequestDetailInfo.consentDataLifePeriod.value.toInt()} '
                          '${finvuConsentRequestDetailInfo.consentDataLifePeriod.unit}',
                      icon: Icons.access_time_rounded,
                    ),
                    _DetailRow(
                      label: FinvuStrings().approvalExpiry,
                      value: _fmt(finvuConsentRequestDetailInfo
                          .consentDateTimeRange.to
                          .toString()),
                      icon: Icons.event_busy_outlined,
                    ),
                    _DetailRow(
                      label: FinvuStrings().accountTypes,
                      value:
                          finvuConsentRequestDetailInfo.fiTypes?.join(', ') ??
                              '',
                      icon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Got It button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GestureDetector(
            onTap: () => showDetails.value = false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3D3B5E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Got it',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Powered securely by Ekjut',
            style: TextStyle(fontSize: 11, color: Color(0xFFAEAEB2)),
          ),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _approveConsentRequest() async {
    try {
      final info = await finvuManager.getConsentRequestDetails(handleId.value);
      await finvuManager.approveConsentRequest(info, seletedAccountInfomations);
      snackBarCalled(context, SnackbarData().consentApproved);
      FetchTransactionFromFinvuApi(context);
    } catch (e) {
      skipOrLets.value = 'Skip';
      snackBarCalledfail(context, SnackbarData().consentApproveError);
    }
  }

  void _showDeclineDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(FinvuStrings().areYouSure,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryColor)),
              const SizedBox(height: 8),
              Text(FinvuStrings().declineConfirmation,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 14,
                      color: const Color(0xFF8E8E93))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFD1D1D6)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(FinvuStrings().no,
                          style: const TextStyle(color: Color(0xFF1C1C1E))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => _decline(),
                      child: Text(FinvuStrings().yes,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _decline() async {
    try {
      final info = await finvuManager.getConsentRequestDetails(handleId.value);
      finvuManager.denyConsentRequest(info);
      logoutAndDisconnect();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/ShareAccountLogin', (route) => false);
      snackBarCalledfail(context, SnackbarData().consentDeclined);
    } catch (e) {
      snackBarCalledfail(context, SnackbarData().consentDisapproveError);
    }
  }

  void _showWarningDialog(
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
}

// ══════════════════════════════════════════════════════════════════════════════
// Reusable info card
// ══════════════════════════════════════════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;
  const _InfoCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarProfileImageZero(url: icon, width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.primaryColor),
                ),
                const SizedBox(height: 5),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row for details view ───────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DetailRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        fontSize: 13,
                        color: const Color(0xFF8E8E93))),
                const SizedBox(height: 3),
                Text(value,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xFF1C1C1E))),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF4A4F8C)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Consent action buttons with health warnings
// ══════════════════════════════════════════════════════════════════════════════

class _ConsentActions extends StatelessWidget {
  final String fipId;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final void Function(List<FipUserMessage>, VoidCallback)? onShowWarningConfirm;

  const _ConsentActions({
    required this.fipId,
    required this.onApprove,
    required this.onDecline,
    this.onShowWarningConfirm,
  });

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
    final hasError = false; //errors.isNotEmpty;
    final hasWarning = warnings.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          if (messages.isNotEmpty) ...[
            _HealthBanner(messages: [...errors, ...warnings]),
            const SizedBox(height: 12),
          ],

          // ── Grant Consent ──────────────────────────────────────────
          GestureDetector(
            onTap: () {
              if (hasWarning && onShowWarningConfirm != null) {
                onShowWarningConfirm!(warnings, onApprove);
              } else if (!hasError) {
                onApprove();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: hasError
                    ? const Color(0xFF3D3B5E).withOpacity(0.38)
                    : const Color(0xFF3D3B5E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasWarning && !hasError)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.warning_amber_rounded,
                          size: 18, color: Colors.white),
                    ),
                  if (hasError)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.lock_outline_rounded,
                          size: 16, color: Colors.white70),
                    ),
                  Text(
                    hasError ? 'Permission unavailable' : 'Grant Consent',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasError
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // ── Decline ────────────────────────────────────────────────
          GestureDetector(
            onTap: onDecline,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                FinvuStrings().decline,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.redColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Health banner ─────────────────────────────────────────────────────────

class _HealthBanner extends StatelessWidget {
  final List<FipUserMessage> messages;
  const _HealthBanner({required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();
    final top = messages.first;
    final isError = top.severity == FipMessageSeverity.error;
    final bg = isError ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1);
    final border = isError ? const Color(0xFFEF9A9A) : const Color(0xFFFFCC80);
    final iconColor =
        isError ? const Color(0xFFE53935) : const Color(0xFFFB8C00);
    final icon =
        isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(top.title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: iconColor)),
                const SizedBox(height: 2),
                Text(top.detail,
                    style: TextStyle(
                        fontSize: 12, color: iconColor.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Warning confirm dialog ─────────────────────────────────────────────────

class _WarningConfirmDialog extends StatelessWidget {
  final List<FipUserMessage> warnings;
  final VoidCallback onConfirmed;

  const _WarningConfirmDialog(
      {required this.warnings, required this.onConfirmed});

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
                        color: Color(0xFF1C1C1E)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'We detected issues with this bank. Data access may be affected.',
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF636366), height: 1.5),
            ),
            const SizedBox(height: 16),
            ...warnings.map((w) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFFFCC80), width: 0.8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: Color(0xFFFB8C00)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.title,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE65100))),
                            const SizedBox(height: 3),
                            Text(w.detail,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFFBF360C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
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
                    child: const Text('Go back',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF3C3C3C))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D3B5E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmed();
                    },
                    child: const Text('Proceed anyway',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
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
