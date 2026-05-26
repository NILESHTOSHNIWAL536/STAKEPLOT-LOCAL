import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/booleanFlag.dart';
import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../Constants/theme_helper.dart';
import '../../Home_Screen/Home/init_Api_Calls.dart';
import '../../OneSignal/deviceConfig.dart';
import '../../model/bank_model.dart';
import '../../repository/bankinfo.dart';
import '../apis_connect.dart';

class BankSyncFlow extends StatefulWidget {
  final ConsentInfoModel? consentInfo;
  final String bankName;
  final String bankLogo;

  const BankSyncFlow({
    super.key,
    required this.consentInfo,
    required this.bankName,
    required this.bankLogo,
  });

  @override
  State<BankSyncFlow> createState() => _BankSyncFlowState();
}

class _BankSyncFlowState extends State<BankSyncFlow> {
  late final PageController _pageController;
  int currentStep = 0;
  Timer? _timer;

  static const int totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentStep < totalSteps - 1) {
        _goToStep(currentStep + 1);
      } else {
        timer.cancel();
      }
    });
  }

  void _goToStep(int step) {
    if (!mounted) return;
    setState(() => currentStep = step);

    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: AppSizes.p12),
      decoration: BoxDecoration(
        color: colors.dialogBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _bankHeader(),
          const SizedBox(height: AppSizes.h16),
          _stepIndicator(),
          const SizedBox(height: AppSizes.h16),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StepContent(step: 0, bankName: widget.bankName),
                _StepContent(step: 1, bankName: widget.bankName),
                _StepContent(step: 2, bankName: widget.bankName),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.h16),
          currentStep == totalSteps - 1 ? _syncButton() : _progressBar(),
        ],
      ),
    );
  }

  Widget _bankHeader() {
    final colors = context.appColors;
    final displayBankName =
        widget.bankName.trim().isEmpty ? "Selected bank" : widget.bankName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              widget.bankLogo,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.account_balance,
                size: 24,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayBankName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 15,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) return _line();

        final stepIndex = index ~/ 2;
        return _stepIcon(stepIndex);
      }),
    );
  }

  Widget _stepIcon(int step) {
    final isCompleted = currentStep > step;
    final isActive = currentStep == step;
    final colors = context.appColors;

    return Container(
      width: 37,
      height: 37,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted || isActive ? colors.border : colors.primary,
        ),
        color: isCompleted || isActive
            ? colors.iconBackground
            : colors.dialogBackground,
      ),
      child: Icon(
        step == 0
            ? Icons.sync
            : step == 1
                ? Icons.access_time
                : Icons.check,
        size: 20,
        color: isCompleted || isActive ? colors.primary : colors.secondaryText,
      ),
    );
  }

  Widget _line() {
    return Container(
      width: MediaQuery.sizeOf(context).width / 6,
      height: 2,
      color: context.appColors.primary,
    );
  }

  Widget _progressBar() {
    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: context.appColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (currentStep + 1) / totalSteps,
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _syncButton() {
    final colors = context.appColors;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _checkAndFetchData(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: AppColors.backgroundColor,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          "Sync now",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.backgroundColor,
          ),
        ),
      ),
    );
  }

  ConsentInfoModel? _selectedConsentInfo() {
    if (widget.consentInfo != null) return widget.consentInfo;
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

  Future<void> _checkAndFetchData(BuildContext context) async {
    if (fetchNow.value) return;

    final item = _selectedConsentInfo();
    if (item == null) return;

    fetchNow.value = true;
    markBankFetchStarted(item.consendHandleId, item.bankName);
    setUpSocketListenerMainPage(context);

    await getWeeklyfetchData(
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

    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("fetchingData", item.toJson().toString());
    fetchNow.value = false;

    if (!context.mounted) return;
    callApi(context);
    Navigator.pop(context);
  }
}

class _StepContent extends StatelessWidget {
  final int step;
  final String bankName;

  const _StepContent({
    required this.step,
    required this.bankName,
  });

  @override
  Widget build(BuildContext context) {
    final displayBankName = bankName.trim().isEmpty ? "your bank" : bankName;

    late final IconData icon;
    late final Color bg;
    late final Color iconColor;
    late final String title;
    late final String description;

    if (step == 0) {
      icon = Icons.sync;
      bg = const Color(0xFFEDEEF4);
      iconColor = const Color(0xFF4B4D73);
      title = "Syncing $displayBankName can fail or be delayed";
      description =
          "Some banks take longer to update and the latest transactions may not show up immediately.";
    } else if (step == 1) {
      icon = Icons.access_time;
      bg = const Color(0xFFEDEEF4);
      iconColor = const Color(0xFF4B4D73);
      title = "The syncing process may take some time";
      description =
          "You may continue using the app while $displayBankName sync is in progress. If you leave the app, we will notify you once it is complete.";
    } else {
      icon = Icons.check;
      bg = const Color(0xFFE6F6EC);
      iconColor = const Color(0xFF2EAD65);
      title = "You're all set";
      description = "Ready to start syncing $displayBankName";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.18)
                : const Color(0xFFE3E3E3),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border.all(color: context.appColors.border),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: 30, color: iconColor),
            ),
            SizedBox(height: AppSizes.h16),
            Text(
              title,
              textAlign: TextAlign.center,
              softWrap: true,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 15,
                color: step == 2
                    ? const Color(0xFF2EAD65)
                    : context.appColors.onSurface,
                lineHeight: 20 / fontSize,
              ),
            ),
            SizedBox(height: AppSizes.h10),
            Text(
              description,
              textAlign: TextAlign.center,
              softWrap: true,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: 13,
                color: context.appColors.secondaryText,
                lineHeight: 18 / fontSize,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
