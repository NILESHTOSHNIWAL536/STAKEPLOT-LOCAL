import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/main.dart';

// Reactive variables (unchanged)
RxMap<String, List<FinvuDiscoveredAccountInfo>> listOfAccountAdded = <String, List<FinvuDiscoveredAccountInfo>>{}.obs;
RxMap<String, FinvuFIPDetails> FinvuFIPDetailsList = <String, FinvuFIPDetails>{}.obs;
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

class _LinkingAccountState extends State<LinkingAccount> {
  final int _otpCodeLength = 6;
  RxString _otpCode = "".obs;
  RxBool _isOtpValid = false.obs;
  TextEditingController otpController = TextEditingController();
  late double textScale;

  @override
  void initState() {
    super.initState();
    count.value = 0;
    otpCount.value = 0;
    loopCount.value = 0;
    getData();
    getinfo();
    getFetch.value = false;
  }

  void getinfo() async {
    finvuConsentRequestDetailInfo = await finvuManager.getConsentRequestDetails(handleId.value);
  }

  void getData() async {
    fipDis = await finvuManager.fipsAllFIPOptions();
    fipDisOrginal.clear();
    fipDisOrginal.addAll(fipDis);
    getBanks.value = !getBanks.value;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    textScale = screenWidth / 375;
    count.value=0;

    return Scaffold(
      bottomNavigationBar: BottomBar(),
      appBar: getAppBar(context),
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          padding: EdgeInsets.symmetric(horizontal: 16 * textScale, vertical: 3 * textScale),
          child: SingleChildScrollView( // Wrap Column in SingleChildScrollView to prevent overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6 * textScale),
                  child: Text(
                    "Select accounts to share",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 22 * textScale,
                      color: AppColors.bg1,
                    ),
                  ),
                ),
                SizedBox(height: 5 * textScale),
                BankInfoUiContainer(),
                bankAccountList(screenWidth, screenHeight),
                SizedBox(height: 10 * textScale),
                buttonLinkNow(screenWidth),
                SizedBox(height: 10 * textScale), // Extra padding to ensure button visibility
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonLinkNow(double screenWidth) {
    return Obx(() {
      // Debugging: Print state to verify conditions
      // Simplified condition: Show button if there are linked accounts or all banks are processed
      bool shouldShowButton = (accountLinked.isNotEmpty || loopCount.value == widget.listOfBankAccount.length) && count.value > 0;

      if (!shouldShowButton) {
        return SizedBox(height: 0);
      }

      return InkWell(
        onTap: () {
          if (accountAdded.isNotEmpty) {return;}
          showModalBottomSheet(
            context: context,
            builder: (context) => accountLinkedUi(screenWidth),
          );
        },
        child: Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.symmetric(vertical: 14 * textScale),
          margin: EdgeInsets.only(bottom: 10 * textScale),
          decoration: BoxDecoration(
            color: accountAdded.isNotEmpty ? AppColors.bg3 : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12 * textScale),
          ),
          child: Center(
            child: Text(
              "Authorise",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 18 * textScale,
                color: Colorcodes.white,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget accountLinkedUi(double screenWidth) {
    return Container(
      width: screenWidth,
      height: MediaQuery.of(context).size.height / 3,
      padding: EdgeInsets.all(12 * textScale),
      child: accountAdded.isNotEmpty
          ? getLinkNow(BankText.linkNow, BankText.linkNowproceeding, "Link Now", screenWidth)
          : seletedAccountIds.isEmpty
              ? getLinkNow(BankText.checkNow, BankText.checkNowproceeding, "check Now", screenWidth)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${seletedAccountIds.length} Bank Accounts are shared",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 14 * textScale,
                        color: Colorcodes.black,
                      ),
                    ),
                    SizedBox(height: 20 * textScale),
                    InkWell(
                      onTap: () async {
                        directFetch.value = false;
                        await getAccountShared();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Access()),
                        );
                      },
                      child: getButton(context, "Continue", screenWidth),
                    ),
                    SizedBox(height: 20 * textScale),
                    textStyle("We will fetch this account transactions", 8 * textScale),
                  ],
                ),
    );
  }

  Widget getLinkNow(String title, String des, String btnText, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20 * textScale),
        textStyle(title, 14 * textScale),
        SizedBox(height: 20 * textScale),
        Container(
          width: screenWidth * 0.9,
          child: Center(
            child: Text(
              des,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 14 * textScale,
                color: Colorcodes.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 10 * textScale),
        Icon(Icons.warning_outlined, color: Colorcodes.red, size: 30 * textScale),
        SizedBox(height: 10 * textScale),
        btnText == "check Now"
            ? SizedBox(height: 0)
            : InkWell(
                onTap: () => Navigator.pop(context),
                child: getButton(context, btnText, screenWidth),
              ),
        SizedBox(height: btnText == "check Now" ? 0 : 20 * textScale),
      ],
    );
  }

  Widget BankInfoUiContainer() {
    return Container(
      padding: EdgeInsets.all(12 * textScale),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16 * textScale)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.mt,
                radius: 20 * textScale,
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 25 * textScale,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 10 * textScale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bank Accounts",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16 * textScale,
                      color: AppColors.bg1,
                    ),
                  ),
                  Obx(() => textStyle("${count.value} accounts discovered", 12 * textScale, Colorcodes.graphColor1)),
                ],
              ),
            ],
          ),
          SizedBox(height: 10 * textScale),
          textStyle("Select at least 1 Account to share from", 14 * textScale),
          SizedBox(height: 10 * textScale),
        ],
      ),
    );
  }

  Widget bankAccountList(double screenWidth, double screenHeight) {
    count.value = 0;
    loopCount.value = 0;
    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.6,
      child: SingleChildScrollView(
        child: Column(
          children: widget.listOfBankAccount.asMap().entries.map((entry) {
              int index = entry.key;
              var account = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getBankNameAndImage(account),
                FutureBuilder<Widget>(
                  future: linkedaccoutnData(account,index),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.all(8 * textScale),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 2 * textScale,
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
        ),
      ),
    );
  }

  Widget getListOfFinvuBanksAccounts(List<FinvuDiscoveredAccountInfo> account, FinvuFIPDetails fipDetails) {
    loopCount.value++;
    return account.isEmpty
        ? getNoBankAccount()
        : Column(children: account.map((bankData) => getBackUi(bankData, fipDetails)).toList());
  }

  void LinkingBank(FinvuFIPDetails fipDetails, String fipId, FinvuFIPInfo info) async {
    try {
      List<FinvuDiscoveredAccountInfo> bankData = listOfAccountAdded[fipId] ?? [];
      if (bankData.isEmpty) {
        snackBarCalled(context, "The account has been successfully added for linking.", Colorcodes.red);
        return;
      }
      linkingReference = await finvuManager.linkAccounts(fipDetails, bankData);
      isOtpWrong.value = false;
      startOtpTimer();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) => verify(fipId, fipDetails, info, context),
      );
    } catch (e) {
      snackBarCalledSignup(context, "Maximum Retries Exceeded. Please try again after sometime.");
    }
  }

  Widget verify(String fid, FinvuFIPDetails fipDetails, FinvuFIPInfo info, BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * textScale)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10 * textScale),
              child: Center(
                child: textStyle("Securely authorize each selected account", 14 * textScale, Colorcodes.black, FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * textScale),
              child: getBankNameAndImage(info, false),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10 * textScale, horizontal: 20 * textScale),
              child: textStyle("OTP Verification", 20 * textScale, AppColors.bg1, FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4 * textScale, horizontal: 20 * textScale),
              child: textStyle("Enter the OTP sent to ${number.value}", 15 * textScale, AppColors.bg1, FontWeight.w400),
            ),
            SizedBox(height: 10 * textScale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * textScale),
              child: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  otpCount.value++;
                  linkAccount(_otpCode.value, fid, context, fipDetails);
                },
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * textScale)),
                ),
                onChanged: (value) {
                  _otpCode.value = value;
                  _isOtpValid.value = value.length > 4;
                  isOtpWrong.value = false;
                },
              ),
            ),
            Obx(() => isOtpWrong.value
                ? Padding(
                    padding: EdgeInsets.fromLTRB(40 * textScale, 0, 0, 5 * textScale),
                    child: Text(
                      "Incorrect OTP entered",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w300,
                        fontSize: 10 * textScale,
                        color: Colors.red,
                      ),
                    ),
                  )
                : SizedBox(height: 0)),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 4 * textScale, 0, 10 * textScale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 5 * textScale),
                    child: Text(
                      "Didn't you receive the OTP?  ",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w200,
                        fontSize: 12 * textScale,
                        color: AppColors.bg3,
                      ),
                    ),
                  ),
                  Obx(() => GestureDetector(
                        onTap: canResendOtp.value ? () async => reSendOtp(fipDetails, fid) : null,
                        child: Text(
                          canResendOtp.value ? "Resend OTP" : "Resend in ${otpCountdown.value} seconds",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w400,
                            fontSize: 12 * textScale,
                            color: canResendOtp.value ? AppColors.primaryColor : Colors.grey,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: 5 * textScale),
            Center(
              child: InkWell(
                onTap: () {
                  if (_otpCode.value.length < 6) {
                    snackBarCalledSignup(context, "enter valid otp");
                  } else {
                    otpCount.value++;
                    linkAccount(_otpCode.value, fid, context, fipDetails);
                  }
                },
                child: Obx(() => getColorVerify()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getColorVerify() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.symmetric(horizontal: 10 * textScale, vertical: 14 * textScale),
      decoration: BoxDecoration(
        color: _isOtpValid.value ? AppColors.primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(12 * textScale),
      ),
      child: Center(
        child: Text(
          "Verify",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18 * textScale,
            color: AppColors.bg5,
          ),
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

  void linkAccount(String otp, String fid, BuildContext context, FinvuFIPDetails fipDetails) async {
    try {
      isOtpWrong.value = false;
      FinvuConfirmAccountLinkingInfo data = await finvuManager.confirmAccountLinking(linkingReference, otpController.text.trim());
      snackBarCalled(context, "Linked Bank account Successfully...");

      Navigator.pop(context);
      count.value=0;
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

  Widget getBackUi(FinvuDiscoveredAccountInfo bankData, FinvuFIPDetails fipDetails) {

    String id = bankData.accountReferenceNumber.toString();
    String maskedAccountNumber = bankData.maskedAccountNumber.toString();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * textScale),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                formatMaskedAccount(bankData),
                SizedBox(height: 2 * textScale),
                Obx(() =>( listofLinkedAccount.contains(id))
                    ? textStyle(FipIdsConnected.contains(maskedAccountNumber)? "Shared":"Linked", 13 * textScale, Colorcodes.graphColor2)
                    : SizedBox(height: 0)),
              ],
            ),
            Spacer(),
            checkBoxForAccountLink(bankData, fipDetails, id,maskedAccountNumber),
          ],
        ),
      ),
    );
  }

  Widget formatMaskedAccount(FinvuDiscoveredAccountInfo bankData) {
    int length = bankData.maskedAccountNumber.toString().length;
    return Row(
      children: [
        textStyle("${toUpperCase(bankData.accountType.toLowerCase())} Account ", 14 * textScale),
        (length > 4)
            ? textStyle('•${bankData.maskedAccountNumber.substring(length - 4)}', 14 * textScale)
            : textStyle('•${bankData.maskedAccountNumber}', 14 * textScale),
      ],
    );
  }

  Widget checkBoxForAccountLink(bankData,FinvuFIPDetails fipDetails, id,String maskedAccountNumber) {
    return Obx(() =>
        FipIdsConnected.contains(maskedAccountNumber)? SizedBox.shrink():
        listofLinkedAccount.contains(id)
        ? Obx(() => addAccount.value ? getcheckBox(id) : getcheckBox(id))
        : Checkbox(
            value: accountAdded.contains(bankData.accountReferenceNumber),
            onChanged: (b) => addAccountToMap(fipDetails.fipId, bankData.accountReferenceNumber, bankData),
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * textScale)),
          )

        );
  }

  Widget textStyle(String text, double fontsize, [Color c = AppColors.bg1, FontWeight fontWeight = FontWeight.w500]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 7),
        Text(
          text,
          style: FontManager().getTextStyle(context, lWeight: fontWeight, fontSize: fontsize, color: c),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<Widget> linkedaccoutnData(bankData,int index) async {
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
          FinvuTypeIdentifierInfo obj = FinvuTypeIdentifierInfo(category: ele.category, type: ele.type, value: number.value);
          finvuTypeIdentifierInfo.add(obj);
        });
      });
      fipDetails = FinvuFIPDetails(fipId: fipId, typeIdentifiers: fetchFIPDetails.typeIdentifiers);
      FinvuFIPDetailsList[fipId] = fipDetails;
      info = await finvuManager.discoverAccounts(fipDetails.fipId, finvuFIPInfo.fipFitypes, finvuTypeIdentifierInfo);
      if(index==0){
        count.value = 0;
      }
      count.value += info.length;
       count.refresh();
    } catch (e) {
      loopCount++;
      return getNoBankAccount();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: getListOfFinvuBanksAccounts(info, fipDetails),
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
                width: 30 * textScale,
                height: 30 * textScale,
                child: Image.network(bankData.productIconUri.toString(), fit: BoxFit.cover),
              ),
              SizedBox(width: 10 * textScale),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: textStyle(bankData.productName.toString(), 16 * textScale, AppColors.bg1, FontWeight.bold),
              ),
            ],
          ),
          Obx(() => (!listOfAccountAdded.containsKey(bankData.fipId) || !flag)
              ? SizedBox(width: 0)
              : InkWell(
                  onTap: () {
                    otpController = TextEditingController();
                   
                    LinkingBank(FinvuFIPDetailsList[bankData.fipId]!, bankData.fipId, bankData);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * textScale, vertical: 3 * textScale),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12 * textScale),
                    ),
                    child: Text(
                      "Link now",
                      style: TextStyle(fontSize: 12 * textScale, color: Colorcodes.white),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void addAccountToMap(String fipId, String accountReferenceNumber, FinvuDiscoveredAccountInfo bankData) {
    bool flag = accountAdded.contains(accountReferenceNumber);
    if (flag) {
      accountAdded.remove(accountReferenceNumber);
      if (listOfAccountAdded.containsKey(fipId)) {
        listOfAccountAdded[fipId]!.removeWhere((account) => account.accountReferenceNumber == accountReferenceNumber);
        if (listOfAccountAdded[fipId]!.isEmpty) listOfAccountAdded.remove(fipId);
      }
    } else {
      accountAdded.add(accountReferenceNumber);
      if (!listOfAccountAdded.containsKey(fipId)) listOfAccountAdded[fipId] = [];
      listOfAccountAdded[fipId]?.add(bankData);
    }
    listOfAccountAdded.refresh();
    accountAdded.refresh();
  }

  Widget getcheckBox(String fipId) {
    return Padding(
      padding: EdgeInsets.only(left: 10 * textScale),
      child: Container(
        width: 50 * textScale,
        height: 50 * textScale,
        child: Checkbox(
          value: seletedAccountIds.contains(fipId),
          activeColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * textScale)),
          onChanged: (value) {
            if (seletedAccountIds.contains(fipId)) {
              seletedAccountIds.remove(fipId);
            } else {
              seletedAccountIds.add(fipId);
            }
            addAccount.value = !addAccount.value;
          },
        ),
      ),
    );
  }

  Future<void> getAccountShared() async {
    try {
      fetchAccountData = await finvuManager.fetchLinkedAccounts();
      finvuConsentRequestDetailInfo = await finvuManager.getConsentRequestDetails(handleId.value);
      seletedAccountInfomations.clear();
      fetchAccountData.forEach((FinvuLinkedAccountDetailsInfo finvuInfo) {
        try {
          if (seletedAccountIds.contains(finvuInfo.accountReferenceNumber)) {
            seletedAccountInfomations.add(finvuInfo);
          }
        } catch (e) {
          print(e);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Widget getNoBankAccount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2 * textScale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textNoAccountFound(BankText.text1, 16 * textScale, FontWeight.bold),
          textNoAccountFound(BankText.text2, 15 * textScale, FontWeight.w400),
          textNoAccountFound(BankText.text3, 13 * textScale),
          textNoAccountFound(BankText.text4, 13 * textScale),
          textNoAccountFound(BankText.text5, 13 * textScale),
        ],
      ),
    );
  }

  Widget textNoAccountFound(String text, double fontsize, [FontWeight fontWeight = FontWeight.w500, Color c = AppColors.bg1]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * textScale),
      child: Text(
        text,
        style: FontManager().getTextStyle(context, lWeight: fontWeight, fontSize: fontsize, color: c),
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget getButton(BuildContext context, String text, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.symmetric(vertical: 14 * textScale),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12 * textScale),
      ),
      child: Center(
        child: Text(
          text,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18 * textScale,
            color: Colorcodes.white,
          ),
        ),
      ),
    );
  }
}