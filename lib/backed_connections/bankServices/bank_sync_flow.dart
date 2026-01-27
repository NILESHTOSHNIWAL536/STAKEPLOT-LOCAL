import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/booleanFlag.dart';
import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../Home_Screen/Home/init_Api_Calls.dart';
import '../../OneSignal/deviceConfig.dart';
import '../../repository/bankinfo.dart';
import '../apis_connect.dart';

class BankSyncFlow extends StatefulWidget {
  const BankSyncFlow({super.key});

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSizes.p8),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepIndicator(),
           SizedBox(height: MediaQuery.sizeOf(context).height/20),

          /// 🔥 PAGEVIEW (SOURCE OF TRUTH)
          SizedBox(
            
            height: MediaQuery.sizeOf(context).height/3.4,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _StepContent(step: 0),
                _StepContent(step: 1),
                _StepContent(step: 2),
              ],
            ),
          ),

           SizedBox(height: MediaQuery.sizeOf(context).height/30),

          /// 🔥 PROGRESS / CTA
          currentStep == totalSteps - 1
              ? _syncButton()
              : _progressBar(),
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

    return Container(
      width: 37,
      height: 37,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isCompleted || isActive? AppColors.border :AppColors.primaryColor),
        color: isCompleted
            ? AppColors.border
            : isActive
                ? AppColors.border
                : AppColors.backgroundColor,
      ),
      child: Icon(
        step == 0
            ? Icons.sync
            : step == 1
                ? Icons.access_time
                : Icons.check,
        size: 20,
        color: isCompleted || isActive
            ? AppColors.primaryColor
            : AppColors.grey,
      ),
    );
  }

  Widget _line() {
    return Container(
      width: MediaQuery.sizeOf(context).width/6,
      height: 2,
      color:  AppColors.primaryColor,
    );
  }

  /// ---------------- PROGRESS BAR ----------------
  Widget _progressBar() {
    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (currentStep + 1) / totalSteps,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4B4D73),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// ---------------- FINAL CTA ----------------
  Widget _syncButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
         if (fetchNow.value) return;
                                  fetchNow.value = true;
                                  checkAndFetchData(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Center(
          child: Text("Sync now", 
           style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color:  AppColors.backgroundColor
                                  ),)
         
        ),
        
      ),
    );
  }
}
 void checkAndFetchData(BuildContext context) async {
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
    final SharedPreferences pref =
        await SharedPreferences.getInstance();
    pref.setString(
        "fetchingData", consentAndHandleDetails.toString());
    isFected.value = true;
    fetchNow.value = false;
    scrollBankPage.value = 0;
    callApi(context);
    Navigator.pop(context);
  }

class _StepContent extends StatelessWidget {
  final int step;
  const _StepContent({required this.step});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color bg;
    Color iconColor;
    String title;
    String description;

    if (step == 0) {
      icon = Icons.sync;
      bg = const Color(0xFFEDEEF4);
      iconColor = const Color(0xFF4B4D73);
      title =
          "Syncing your bank information can\nfail or be delayed";
      description =
          "Some banks take longer to update and the\nlatest transactions may not show up\nimmediately.";
    } else if (step == 1) {
      icon = Icons.access_time;
      bg = const Color(0xFFEDEEF4);
      iconColor = const Color(0xFF4B4D73);
      title =
          "The syncing process may take\nsome time depending on the bank";
      description =
          "You may continue using the app while the sync\nis in progress. If you leave the app, we will\nnotify you once the sync is complete.";
    } else {
      icon = Icons.check;
      bg = const Color(0xFFE6F6EC);
      iconColor = const Color(0xFF2EAD65);
      title = "You're all set";
      description = "Ready to start syncing your bank information";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
      BoxShadow(
        color: const Color(0xFFE3E3E3),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ],
        border: Border.all(color: const Color(0xFFE6E9EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: iconColor),
          ),
           SizedBox(height: AppSizes.h20),
          Text(
            title,
            textAlign: TextAlign.center,
             style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color:  step == 2
                  ? const Color(0xFF2EAD65)
                  : AppColors.accentColor,
                  lineHeight: 21/fontSize
                                  ),
           
          ),
          SizedBox(height: AppSizes.h10),
          Text(
            description,
            textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.grey,
                                    lineHeight: 19/fontSize,
                                    letterSpacing: -0.5
                                  ),
          
          ),
        ],
      ),
    );
  }
}
