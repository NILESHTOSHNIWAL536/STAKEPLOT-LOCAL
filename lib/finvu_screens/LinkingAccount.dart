import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/loginservices/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import '../Constants/core/app_padding_sizes.dart';

// Reactive variables (unchanged)
RxMap<String, List<FinvuDiscoveredAccountInfo>> listOfAccountAdded =
    <String, List<FinvuDiscoveredAccountInfo>>{}.obs;
RxMap<String, String> bankImgMap = <String, String>{}.obs;
RxMap<String, FinvuFIPDetails> FinvuFIPDetailsList =
    <String, FinvuFIPDetails>{}.obs;
RxMap<String, int> accountCountList = <String, int>{}.obs;
RxList accountAdded = [].obs;
RxList accountLinked = [].obs;
RxInt count = 0.obs;
List<FinvuFIPInfo> fipDis = [];
List<FinvuFIPInfo> fipDisOrginal = [];
RxList isSeletedBankAccout = [].obs;
RxMap<String, String> bankImageAndid = RxMap();
RxList<FinvuFIPInfo> listOfBankAccount = <FinvuFIPInfo>[].obs;
RxBool getBanks = false.obs;
RxBool addBank = false.obs;
RxBool addCheck = false.obs;
List<FinvuLinkedAccountDetailsInfo> fetchAccountData = [];
List<FinvuLinkedAccountDetailsInfo> seletedAccountInfomations = [];
List<FinvuDiscoveredAccountInfo> info = [];
RxMap<String, List<FinvuDiscoveredAccountInfo>> discoverAccountMap =
    <String, List<FinvuDiscoveredAccountInfo>>{}.obs;
List<String> seletedAccountIds = [];
RxBool addAccount = false.obs;
RxBool getFetch = false.obs;
RxBool directFetch = false.obs;
RxInt otpCount = 0.obs;
RxInt loopCount = 0.obs;

class LinkingAccount extends StatefulWidget {
  final List<FinvuFIPInfo> listOfBankAccount;
  LinkingAccount({Key? key, required this.listOfBankAccount}) : super(key: key);

  @override
  _LinkingAccountState createState() => _LinkingAccountState();
}

class _LinkingAccountState extends State<LinkingAccount>
    with TickerProviderStateMixin {
  final int _otpCodeLength = 6;
  RxString _otpCode = "".obs;
  RxBool _isOtpValid = false.obs;
  TextEditingController otpController = TextEditingController();
  late double textScale;

  // Track swipe reveal state per account
  final Map<String, bool> _swipeRevealed = {};
  final Map<String, AnimationController> _swipeControllers = {};
  final Map<String, Animation<double>> _swipeAnimations = {};

  @override
  void initState() {
    super.initState();
    count.value = 0;
    otpCount.value = 0;
    loopCount.value = 0;
    discoverAccountMap.clear();
    seletedAccountIds.clear();
    bankImgMap.clear();
    getData();
    getinfo();
    accountAdded.clear();
    getFetch.value = false;
  }

  void getinfo() async {
    finvuConsentRequestDetailInfo =
        await finvuManager.getConsentRequestDetails(handleId.value);
  }

  void getData() async {
    fipDis = await finvuManager.fipsAllFIPOptions();
    fipDisOrginal.clear();
    fipDisOrginal.addAll(fipDis);
    getBanks.value = !getBanks.value;
  }

  AnimationController _getSwipeController(String id) {
    if (!_swipeControllers.containsKey(id)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _swipeControllers[id] = controller;
      _swipeAnimations[id] = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }
    return _swipeControllers[id]!;
  }

  Animation<double> _getSwipeAnimation(String id) {
    _getSwipeController(id);
    return _swipeAnimations[id]!;
  }

  void _handleSwipeReveal(String id) {
    final controller = _getSwipeController(id);
    if (_swipeRevealed[id] == true) {
      controller.reverse();
      _swipeRevealed[id] = false;
    } else {
      controller.forward();
      _swipeRevealed[id] = true;
    }
    setState(() {});
  }

  @override
  void dispose() {
    otpController.dispose();
    for (final c in _swipeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    textScale = screenWidth / 375;
    count.value = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      bottomNavigationBar: SafeArea(child: BottomBar()),
      appBar: _buildModernAppBar(context),
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18 * textScale,
                    vertical: 8 * textScale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 16 * textScale),
                      _buildInfoDropdown(screenWidth),
                      SizedBox(height: 20 * textScale),
                      BankInfoUiContainer(),
                      bankAccountList(screenWidth, screenHeight),
                      SizedBox(height: 12 * textScale),
                    ],
                  ),
                ),
              ),
              _buildBottomSection(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF5F3EE),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(10 * textScale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * textScale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16 * textScale, color: const Color(0xFF1A1A2E)),
        ),
      ),
      title: Text(
        'Select Account To Share',
        style: FontManager().getTextStyle(context,
            fontSize: 17 * textScale,
            lWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
            letterSpacing: -0.3),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.all(10 * textScale),
          width: 36 * textScale,
          height: 36 * textScale,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * textScale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.help_outline_rounded,
              size: 18 * textScale, color: const Color(0xFF8A8A9A)),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10 * textScale),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14 * textScale),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_rounded,
                  color: AppColors.primaryColor, size: 22 * textScale),
              SizedBox(width: 8 * textScale),
              Text(
                'Bank Accounts',
                style: FontManager().getTextStyle(context,
                    fontSize: 15 * textScale,
                    lWeight: FontWeight.w700,
                    color: AppColors.primaryColor),
              ),
              SizedBox(width: 6 * textScale),
              Obx(() => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8 * textScale, vertical: 2 * textScale),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20 * textScale),
                    ),
                    child: Text(
                      '${count.value} discovered',
                      style: FontManager().getTextStyle(context,
                          fontSize: 10 * textScale,
                          lWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoDropdown(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(
          horizontal: 16 * textScale, vertical: 14 * textScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * textScale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined,
              color: const Color(0xFF8A8A9A), size: 18 * textScale),
          SizedBox(width: 10 * textScale),
          Text(
            'See what you will share',
            style: FontManager().getTextStyle(context,
                fontSize: 14 * textScale,
                color: const Color(0xFF8A8A9A),
                lWeight: FontWeight.w500),
          ),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF8A8A9A), size: 20 * textScale),
        ],
      ),
    );
  }

  Widget _buildMissingAccountsRow(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Missing any accounts?',
          style: FontManager().getTextStyle(context,
              fontSize: 13 * textScale,
              color: const Color(0xFF8A8A9A),
              lWeight: FontWeight.w500),
        ),
        GestureDetector(
          child: Text(
            '+ Add More',
            style: FontManager().getTextStyle(context,
                fontSize: 13 * textScale,
                color: AppColors.primaryColor,
                lWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(double screenWidth) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          18 * textScale, 12 * textScale, 18 * textScale, 16 * textScale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3EE),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.06), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 13 * textScale, color: const Color(0xFF8A8A9A)),
              SizedBox(width: 4 * textScale),
              Text(
                'Double check your selection before authorising',
                style: FontManager().getTextStyle(context,
                    fontSize: 11 * textScale,
                    color: const Color(0xFF8A8A9A),
                    lWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 10 * textScale),
          buttonLinkNow(screenWidth),
          SizedBox(height: 6 * textScale),
        ],
      ),
    );
  }

  Widget buttonLinkNow(double screenWidth) {
    return Obx(() {
      bool shouldShowButton = (accountLinked.isNotEmpty ||
              loopCount.value == widget.listOfBankAccount.length) &&
          count.value > 0;

      if (!shouldShowButton) {
        return _buildContinueButton(screenWidth, enabled: false);
      }

      return GestureDetector(
        onTap: () {
          if (accountAdded.isNotEmpty) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => accountLinkedUi(screenWidth),
          );
        },
        child: _buildContinueButton(
          screenWidth,
          enabled: accountAdded.isEmpty,
        ),
      );
    });
  }

  Widget _buildContinueButton(double screenWidth, {required bool enabled}) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(vertical: 16 * textScale),
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : const Color(0xFFCBCBD4),
        borderRadius: BorderRadius.circular(16 * textScale),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          FinvuStrings().authorise,
          style: FontManager().getTextStyle(context,
              fontSize: 16 * textScale,
              lWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3),
        ),
      ),
    );
  }

  Widget accountLinkedUi(double screenWidth) {
    return Container(
      margin: EdgeInsets.all(16 * textScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * textScale),
      ),
      padding: EdgeInsets.all(20 * textScale),
      child: accountAdded.isNotEmpty
          ? getLinkNow(BankText.linkNow, BankText.linkNowproceeding,
              FinvuStrings().linkNow, screenWidth)
          : seletedAccountIds.isEmpty
              ? getLinkNow(BankText.checkNow, BankText.checkNowproceeding,
                  FinvuStrings().checkNow, screenWidth)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16 * textScale),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.primaryColor, size: 36 * textScale),
                    ),
                    SizedBox(height: 16 * textScale),
                    Text(
                      "${seletedAccountIds.length} ${FinvuStrings().bankAccountsShared}",
                      style: FontManager().getTextStyle(context,
                          fontSize: 16 * textScale,
                          lWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E)),
                    ),
                    SizedBox(height: 20 * textScale),
                    GestureDetector(
                      onTap: () async {
                        directFetch.value = false;
                        await getAccountShared();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Access()),
                        );
                      },
                      child: _buildContinueButton(screenWidth, enabled: true),
                    ),
                    SizedBox(height: 12 * textScale),
                    Text(
                      FinvuStrings().fetchAccountTransactions,
                      style: FontManager().getTextStyle(context,
                          fontSize: 11 * textScale,
                          color: const Color(0xFF8A8A9A)),
                    ),
                  ],
                ),
    );
  }

  Widget getLinkNow(
      String title, String des, String btnText, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(14 * textScale),
          decoration: BoxDecoration(
            color: AppColors.redColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded,
              color: AppColors.redColor, size: 32 * textScale),
        ),
        SizedBox(height: 16 * textScale),
        Text(title,
            style: FontManager().getTextStyle(context,
                fontSize: 15 * textScale,
                lWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E))),
        SizedBox(height: 8 * textScale),
        Text(
          des,
          style: FontManager().getTextStyle(context,
              fontSize: 13 * textScale,
              lWeight: FontWeight.w500,
              color: AppColors.redColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20 * textScale),
        if (btnText != "check Now")
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _buildContinueButton(screenWidth, enabled: true),
          ),
      ],
    );
  }

  Widget BankInfoUiContainer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * textScale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FinvuStrings().bankAccounts,
            style: FontManager().getTextStyle(context,
                fontSize: 13 * textScale,
                lWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                letterSpacing: 0.5),
          ),
          SizedBox(height: 4 * textScale),
          Text(
            FinvuStrings().selectAtLeastOneAccount,
            style: FontManager().getTextStyle(context,
                fontSize: 13 * textScale,
                color: const Color(0xFF6B6B80),
                lWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget bankAccountList(double screenWidth, double screenHeight) {
    count.value = 0;
    loopCount.value = 0;
    return Column(
      children: widget.listOfBankAccount.asMap().entries.map((entry) {
        int index = entry.key;
        var account = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getBankNameAndImage(account),
            FutureBuilder<Widget>(
              future: linkedaccoutnData(account, index),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12 * textScale),
                    child: Center(
                      child: SizedBox(
                        width: 24 * textScale,
                        height: 24 * textScale,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return snapshot.data ?? SizedBox(height: 0);
                }
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget getListOfFinvuBanksAccounts(List<FinvuDiscoveredAccountInfo> account,
      FinvuFIPDetails fipDetails, FinvuFIPInfo bankInfo) {
    loopCount.value++;
    return account.isEmpty
        ? getNoBankAccount()
        : Column(
            children: account
                .map((bankData) => getBackUi(bankData, fipDetails, bankInfo))
                .toList());
  }

  void LinkingBank(
      FinvuFIPDetails fipDetails, String fipId, FinvuFIPInfo info) async {
    try {
      List<FinvuDiscoveredAccountInfo> bankData =
          listOfAccountAdded[fipId] ?? [];
      if (bankData.isEmpty) {
        snackBarCalled(context, SnackbarData().accountAdded);
        return;
      }
      linkingReference = await finvuManager.linkAccounts(fipDetails, bankData);
      isOtpWrong.value = false;
      startOtpTimer();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) =>
            verify(fipId, fipDetails, info, context),
      );
    } catch (e) {
      snackBarCalledfail(context, SnackbarData().maxRetries);
    }
  }

  Widget verify(String fid, FinvuFIPDetails fipDetails, FinvuFIPInfo info,
      BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        margin: EdgeInsets.fromLTRB(
            12 * textScale, 0, 12 * textScale, 12 * textScale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * textScale),
        ),
        padding: EdgeInsets.all(20 * textScale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40 * textScale,
                height: 4 * textScale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2 * textScale),
                ),
              ),
            ),
            SizedBox(height: 16 * textScale),
            Center(
              child: Text(
                FinvuStrings().securelyAuthorize,
                style: FontManager().getTextStyle(context,
                    fontSize: 15 * textScale,
                    lWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E)),
              ),
            ),
            SizedBox(height: 16 * textScale),
            getBankNameAndImage(info, false),
            SizedBox(height: 16 * textScale),
            Text(
              FinvuStrings().otpVerification,
              style: FontManager().getTextStyle(context,
                  fontSize: 20 * textScale,
                  lWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: -0.5),
            ),
            SizedBox(height: 6 * textScale),
            Text(
              "${FinvuStrings().enterOtpSentTo} ${number.value}",
              style: FontManager().getTextStyle(context,
                  fontSize: 13 * textScale,
                  color: const Color(0xFF6B6B80),
                  lWeight: FontWeight.w400),
            ),
            SizedBox(height: 16 * textScale),
            Obx(() => TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    linkAccount(_otpCode.value, fid, context, fipDetails);
                  },
                  style: TextStyle(
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4),
                  decoration: InputDecoration(
                    hintText: FinvuStrings().enterOtp,
                    hintStyle: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFBBBBC8)),
                    filled: true,
                    fillColor: const Color(0xFFF8F8FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14 * textScale),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14 * textScale),
                      borderSide: BorderSide(
                        color: isOtpWrong.value
                            ? AppColors.redColor.withOpacity(0.4)
                            : const Color(0xFFEEEEF5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14 * textScale),
                      borderSide: BorderSide(
                        color: isOtpWrong.value
                            ? AppColors.redColor
                            : AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _otpCode.value = value;
                    _isOtpValid.value = value.length > 4;
                    isOtpWrong.value = false;
                  },
                )),
            Obx(() => isOtpWrong.value
                ? Padding(
                    padding: EdgeInsets.only(top: 6 * textScale),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 14 * textScale, color: AppColors.redColor),
                        SizedBox(width: 4 * textScale),
                        Text(
                          FinvuStrings().incorrectOtp,
                          style: FontManager().getTextStyle(context,
                              fontSize: 12 * textScale,
                              color: AppColors.redColor,
                              lWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: 0)),
            SizedBox(height: 12 * textScale),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  FinvuStrings().didntReceiveOtp,
                  style: FontManager().getTextStyle(context,
                      fontSize: 13 * textScale,
                      color: const Color(0xFF8A8A9A),
                      lWeight: FontWeight.w400),
                ),
                SizedBox(width: 4 * textScale),
                Obx(() => GestureDetector(
                      onTap: canResendOtp.value
                          ? () async => reSendOtp(fipDetails, fid)
                          : null,
                      child: Text(
                        canResendOtp.value
                            ? FinvuStrings().resendOtp
                            : "${FinvuStrings().resendInSeconds} ${otpCountdown.value}s",
                        style: FontManager().getTextStyle(context,
                            fontSize: 13 * textScale,
                            lWeight: FontWeight.w700,
                            color: canResendOtp.value
                                ? AppColors.primaryColor
                                : const Color(0xFFBBBBC8)),
                      ),
                    )),
              ],
            ),
            SizedBox(height: 16 * textScale),
            GestureDetector(
              onTap: () {
                if (_otpCode.value.length < 6) {
                  snackBarCalledfail(context, SnackbarData().enterValidOtp);
                } else {
                  otpCount.value++;
                  linkAccount(_otpCode.value, fid, context, fipDetails);
                }
              },
              child: Obx(() => getColorVerify()),
            ),
          ],
        ),
      ),
    );
  }

  Widget getColorVerify() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16 * textScale),
      decoration: BoxDecoration(
        gradient: _isOtpValid.value
            ? LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.85)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: _isOtpValid.value ? null : const Color(0xFFCBCBD4),
        borderRadius: BorderRadius.circular(16 * textScale),
        boxShadow: _isOtpValid.value
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Center(
        child: Text(
          FinvuStrings().verify,
          style: FontManager().getTextStyle(context,
              fontSize: 16 * textScale,
              lWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
    );
  }

  void reSendOtp(fipDetails, fid) async {
    otpCount.value = 0;
    List<FinvuDiscoveredAccountInfo> bankData = listOfAccountAdded[fid] ?? [];
    linkingReference = await finvuManager.linkAccounts(fipDetails, bankData);
    startOtpTimer();
    isOtpWrong.value = false;
  }

  void linkAccount(String otp, String fid, BuildContext context,
      FinvuFIPDetails fipDetails) async {
    try {
      isOtpWrong.value = false;
      FinvuConfirmAccountLinkingInfo data = await finvuManager
          .confirmAccountLinking(linkingReference, otpController.text.trim());
      snackBarCalled(context, SnackbarData().bankLinkedSuccess);

      Navigator.pop(context);
      count.value = 0;
      data.linkedAccounts.forEach((finvu) {
        listofLinkedAccount.add(finvu.accountReferenceNumber.toString());
      });

      listOfAccountAdded.remove(fid);
      listofLinkedAccount.refresh();
      accountLinked.add(fid);
      otpController.clear();
      _otpCode.value = "";
      accountAdded.clear();
      _isOtpValid.value = false;
    } catch (e) {
      isOtpWrong.value = true;
      if (otpCount.value == 2) reSendOtp(fipDetails, fid);
    }
  }

  /// Swipe-to-reveal account card
  Widget getBackUi(FinvuDiscoveredAccountInfo bankData,
      FinvuFIPDetails fipDetails, FinvuFIPInfo bankInfo) {
    String id = bankData.accountReferenceNumber.toString();
    String maskedAccountNumber = bankData.maskedAccountNumber.toString();

    final animation = _getSwipeAnimation(id);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * textScale),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 100) {
              // swipe right — reveal checkbox
              _handleSwipeReveal(id);
            } else if (details.primaryVelocity! < -100) {
              // swipe left — hide
              if (_swipeRevealed[id] == true) _handleSwipeReveal(id);
            }
          }
        },
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background checkbox reveal layer
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16 * textScale),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 8),
                    child: Opacity(
                      opacity: animation.value,
                      child: checkBoxForAccountLink(bankData, fipDetails, id,
                          maskedAccountNumber, bankInfo),
                    ),
                  ),
                ),
                // Foreground card slides right
                Transform.translate(
                  offset: Offset(60 * animation.value * textScale, 0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 14 * textScale, vertical: 14 * textScale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16 * textScale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: accountAdded
                                .contains(bankData.accountReferenceNumber)
                            ? AppColors.primaryColor.withOpacity(0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildAccountTypeIcon(bankData),
                        SizedBox(width: 12 * textScale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              formatMaskedAccount(bankData),
                              SizedBox(height: 3 * textScale),
                              Obx(() => (listofLinkedAccount.contains(id))
                                  ? _buildStatusChip(
                                      FipIdsConnected.contains(
                                              maskedAccountNumber)
                                          ? FinvuStrings().shared
                                          : FinvuStrings().linked,
                                      FipIdsConnected.contains(
                                          maskedAccountNumber))
                                  : SizedBox(height: 0)),
                            ],
                          ),
                        ),
                        // Swipe hint when not revealed
                        if (_swipeRevealed[id] != true)
                          Row(
                            children: [
                              Text(
                                'Swipe',
                                style: FontManager().getTextStyle(context,
                                    fontSize: 10 * textScale,
                                    color: const Color(0xFFBBBBC8),
                                    lWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 3 * textScale),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10 * textScale,
                                  color: const Color(0xFFBBBBC8)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountTypeIcon(FinvuDiscoveredAccountInfo bankData) {
    return Container(
      width: 42 * textScale,
      height: 42 * textScale,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12 * textScale),
      ),
      child: Icon(
        bankData.accountType.toString().toLowerCase().contains('fixed')
            ? Icons.savings_outlined
            : Icons.account_balance_wallet_outlined,
        color: AppColors.primaryColor,
        size: 20 * textScale,
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isShared) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 8 * textScale, vertical: 2 * textScale),
      decoration: BoxDecoration(
        color: isShared
            ? Colorcodes.graphColor2.withOpacity(0.12)
            : AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20 * textScale),
      ),
      child: Text(
        label,
        style: FontManager().getTextStyle(context,
            fontSize: 10 * textScale,
            lWeight: FontWeight.w600,
            color: isShared ? Colorcodes.graphColor2 : AppColors.primaryColor),
      ),
    );
  }

  Widget formatMaskedAccount(FinvuDiscoveredAccountInfo bankData) {
    int length = bankData.maskedAccountNumber.toString().length;
    final accountType =
        toUpperCase(bankData.accountType.toLowerCase()) + ' Account';
    final maskedNum = length > 7
        ? '${bankData.maskedAccountNumber.substring(length - 7)}'
        : 'XXXX ${bankData.maskedAccountNumber}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          accountType,
          style: FontManager().getTextStyle(context,
              fontSize: 14 * textScale,
              lWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E)),
        ),
        SizedBox(height: 2 * textScale),
        Text(
          // bankData.maskedAccountNumber,
          maskedNum,
          style: FontManager().getTextStyle(context,
              fontSize: 12 * textScale,
              lWeight: FontWeight.w500,
              color: const Color(0xFF8A8A9A),
              letterSpacing: 1),
        ),
      ],
    );
  }

  Widget checkBoxForAccountLink(bankData, FinvuFIPDetails fipDetails, id,
      String maskedAccountNumber, FinvuFIPInfo bankInfo) {
    return Obx(() => FipIdsConnected.contains(maskedAccountNumber)
        ? SizedBox.shrink()
        : listofLinkedAccount.contains(id)
            ? Obx(() => addAccount.value
                ? getcheckBox(id, bankInfo)
                : getcheckBox(id, bankInfo))
            : Checkbox(
                value: accountAdded.contains(bankData.accountReferenceNumber),
                onChanged: (b) => addAccountToMap(fipDetails.fipId,
                    bankData.accountReferenceNumber, bankData, bankInfo),
                activeColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4 * textScale)),
              ));
  }

  // Widget checkBoxForAccountLink(bankData, FinvuFIPDetails fipDetails, id,
  //     String maskedAccountNumber, FinvuFIPInfo bankInfo) {
  //   return FipIdsConnected.contains(maskedAccountNumber)
  //       ? SizedBox(
  //           width: count.value * 0,
  //         )
  //       : listofLinkedAccount.contains(id)
  //           ? addAccount.value
  //               ? getcheckBox(id, bankInfo)
  //               : getcheckBox(id, bankInfo)
  //           : _buildModernCheckbox(bankData, fipDetails, bankInfo);
  // }

  Widget _buildModernCheckbox(FinvuDiscoveredAccountInfo bankData,
      FinvuFIPDetails fipDetails, FinvuFIPInfo bankInfo) {
    return Obx(() {
      final isSelected = accountAdded.contains(bankData.accountReferenceNumber);
      return GestureDetector(
        onTap: () => addAccountToMap(fipDetails.fipId,
            bankData.accountReferenceNumber, bankData, bankInfo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28 * textScale,
          height: 28 * textScale,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8 * textScale),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryColor : const Color(0xFFDDDDE8),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: isSelected
              ? Icon(Icons.check_rounded,
                  color: Colors.white, size: 16 * textScale)
              : null,
        ),
      );
    });
  }

  Widget textStyle(String text, double fontsize,
      [Color c = AppColors.bg1, FontWeight fontWeight = FontWeight.w500]) {
    return Text(
      text,
      style: FontManager().getTextStyle(context,
          lWeight: fontWeight, fontSize: fontsize, color: c),
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<Widget> linkedaccoutnData(FinvuFIPInfo bankData, int index) async {
    String fipId = bankData.fipId;
    FinvuFIPInfo finvuFIPInfo = bankData;
    FinvuFIPDetails fipDetails;
    List<FinvuDiscoveredAccountInfo> info = [];
    try {
      var fetchFIPDetails = await finvuManager.fetchFIPDetails(fipId);
      var typeIdentifiers = fetchFIPDetails.typeIdentifiers;
      List<FinvuTypeIdentifierInfo> finvuTypeIdentifierInfo = [];
      typeIdentifiers.forEach((e) {
        e.identifiers.forEach((ele) {
          FinvuTypeIdentifierInfo obj = FinvuTypeIdentifierInfo(
              category: ele.category, type: ele.type, value: number.value);
          finvuTypeIdentifierInfo.add(obj);
        });
      });
      fipDetails = FinvuFIPDetails(
          fipId: fipId, typeIdentifiers: fetchFIPDetails.typeIdentifiers);
      FinvuFIPDetailsList[fipId] = fipDetails;
      info = discoverAccountMap.containsKey(fipId)
          ? discoverAccountMap[fipId]!
          : await finvuManager.discoverAccounts(fipDetails.fipId,
              finvuFIPInfo.fipFitypes, finvuTypeIdentifierInfo);
      if (index == 0) {
        count.value = 0;
      }
      discoverAccountMap[fipId] = info;
      count.value += info.length;
      count.refresh();
    } catch (e) {
      loopCount++;
      return getNoBankAccount();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: getListOfFinvuBanksAccounts(info, fipDetails, bankData),
    );
  }

  Widget getBankNameAndImage(FinvuFIPInfo bankData, [bool flag = true]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * textScale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36 * textScale,
                height: 36 * textScale,
                padding: EdgeInsets.all(4 * textScale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10 * textScale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Image.network(bankData.productIconUri.toString(),
                    fit: BoxFit.contain),
              ),
              SizedBox(width: 10 * textScale),
              Text(
                bankData.productName.toString(),
                style: FontManager().getTextStyle(context,
                    fontSize: 15 * textScale,
                    lWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E)),
              ),
            ],
          ),
          Obx(() => (!listOfAccountAdded.containsKey(bankData.fipId) || !flag)
              ? SizedBox(width: 0)
              : GestureDetector(
                  onTap: () {
                    otpController = TextEditingController();
                    LinkingBank(FinvuFIPDetailsList[bankData.fipId]!,
                        bankData.fipId, bankData);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14 * textScale, vertical: 7 * textScale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20 * textScale),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_rounded,
                            size: 13 * textScale, color: Colors.white),
                        SizedBox(width: 4 * textScale),
                        Text(
                          FinvuStrings().linkNow,
                          style: FontManager().getTextStyle(context,
                              fontSize: 12 * textScale,
                              lWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void addAccountToMap(String fipId, String accountReferenceNumber,
      FinvuDiscoveredAccountInfo bankData, FinvuFIPInfo bankInfo) {
    bool flag = accountAdded.contains(accountReferenceNumber);

    if (flag) {
      accountAdded.remove(accountReferenceNumber);
      if (listOfAccountAdded.containsKey(fipId)) {
        listOfAccountAdded[fipId]!.removeWhere((account) =>
            account.accountReferenceNumber == accountReferenceNumber);
        if (listOfAccountAdded[fipId]!.isEmpty)
          listOfAccountAdded.remove(fipId);
      }
    } else {
      accountAdded.add(accountReferenceNumber);
      if (!listOfAccountAdded.containsKey(fipId))
        listOfAccountAdded[fipId] = [];
      listOfAccountAdded[fipId]?.add(bankData);
    }
    listOfAccountAdded.refresh();
    accountAdded.refresh();
  }

  Widget getcheckBox(String fipId, FinvuFIPInfo bankInfo) {
    return Container(
      width: 50 * textScale,
      height: 50 * textScale,
      child: Checkbox(
        value: seletedAccountIds.contains(fipId),
        activeColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4 * textScale)),
        onChanged: (value) {
          if (seletedAccountIds.contains(fipId)) {
            seletedAccountIds.remove(fipId);
            bankImgMap.remove(bankInfo.fipId);
          } else {
            seletedAccountIds.add(fipId);
            bankImgMap[bankInfo.fipId] = bankInfo.productIconUri.toString();
          }
          addAccount.value = !addAccount.value;
        },
      ),
    );
  }

  Future<void> getAccountShared() async {
    try {
      fetchAccountData = await finvuManager.fetchLinkedAccounts();
      finvuConsentRequestDetailInfo =
          await finvuManager.getConsentRequestDetails(handleId.value);
      seletedAccountInfomations.clear();
      fetchAccountData.forEach((FinvuLinkedAccountDetailsInfo finvuInfo) {
        try {
          if (seletedAccountIds.contains(finvuInfo.accountReferenceNumber)) {
            seletedAccountInfomations.add(finvuInfo);
          }
        } catch (e) {}
      });
    } catch (e) {}
  }

  Widget getNoBankAccount() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8 * textScale),
      padding: EdgeInsets.all(16 * textScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * textScale),
        border: Border.all(color: const Color(0xFFEEEEF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18 * textScale, color: const Color(0xFF8A8A9A)),
              SizedBox(width: 8 * textScale),
              Text(BankText.text1,
                  style: FontManager().getTextStyle(context,
                      fontSize: 14 * textScale,
                      lWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
            ],
          ),
          SizedBox(height: 8 * textScale),
          ...[BankText.text2, BankText.text3, BankText.text4, BankText.text5]
              .map((t) => Padding(
                    padding: EdgeInsets.only(bottom: 4 * textScale),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ',
                            style: FontManager().getTextStyle(context,
                                fontSize: 13 * textScale,
                                color: const Color(0xFF8A8A9A))),
                        Expanded(
                          child: Text(t,
                              style: FontManager().getTextStyle(context,
                                  fontSize: 13 * textScale,
                                  color: const Color(0xFF6B6B80),
                                  lWeight: FontWeight.w400)),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget getButton(BuildContext context, String text, double screenWidth) {
    return _buildContinueButton(screenWidth, enabled: true);
  }
}
