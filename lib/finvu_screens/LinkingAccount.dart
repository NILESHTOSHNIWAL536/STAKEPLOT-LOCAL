import 'dart:convert';

import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

RxMap<String, List<FinvuDiscoveredAccountInfo>> listOfAccountAdded =
    <String, List<FinvuDiscoveredAccountInfo>>{}.obs;
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
// RxBool getBanks=false.obs;
RxBool addBank = false.obs;
RxBool addCheck = false.obs;
List<FinvuLinkedAccountDetailsInfo> fetchAccountData = [];
List<FinvuLinkedAccountDetailsInfo> seletedAccountInfomations = [];
List<String> seletedAccountIds = [];
RxBool getBanks = false.obs;
RxBool addAccount = false.obs;
RxBool getFetch = false.obs;
RxBool directFetch = false.obs;

RxInt  otpCount=0.obs;

class LinkingAccount extends StatefulWidget {
  List<FinvuFIPInfo> listOfBankAccount;
  LinkingAccount({Key? key, required this.listOfBankAccount}) : super(key: key);

  @override
  _LinkingAccountState createState() => _LinkingAccountState();
}

class _LinkingAccountState extends State<LinkingAccount> {
  final int _otpCodeLength = 6; // OTP length
  RxString _otpCode = "".obs; // Captured OTP code
  RxBool _isOtpValid = false.obs; // Validate OTP length
  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    count.value = 0;
    otpCount.value = 0;
    getData();
    getinfo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(),
      appBar:getAppBar(context),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Select accounts to share",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.bg1),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              BankInfoUiContainer(),
              bankAccountList(),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                  onTap: () {
                    if(accountAdded.isNotEmpty){
                         snackBarCalledSignup(context, "Please link All seleted Account", Colorcodes.red);
                         return;
                    };

                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return accountLinkedUi();
                      },
                    );

                  },
                  child: Obx(()=> accountAdded.isNotEmpty? getButton(context, "Authorise",AppColors.bg3,Colorcodes.white):getButton(context, "Authorise"))),
            ],
          ),
        ),
      ),
    );
  }


  
 
  Widget accountLinkedUi() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: seletedAccountIds.length == 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  textStyle(
                      "Please tap on 'Link Now' to link your bank account", 14),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    // padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        "Your selected bank is not yet linked. Before proceeding, ensure that the specified bank is linked"
                            .toString(),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colorcodes.red),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Icon(
                    Icons.warning_outlined,
                    color: Colorcodes.red,
                    size: 30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: getButton(context, "Link Now")),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${seletedAccountIds.length} Bank Accounts are shared",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colorcodes.black)),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                      onTap: () async {
                        directFetch.value = false;
                        await getAccountShared();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Access(),
                          ),
                        );
                      },
                      child: getButton(context, "Continue")),
                  const SizedBox(
                    height: 20,
                  ),
                  textStyle("We will fetch this account transactions", 8),
                ],
              ));
  }

  Widget fetchDataOfLinkedAccount() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: seletedAccountIds.length == 0
            ? MediaQuery.of(context).size.height / 3.5
            : MediaQuery.of(context).size.height / 3,
        child: seletedAccountIds.length == 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),

            
                  Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    // padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        "Your selected bank is not yet linked. Before proceeding, ensure that the specified bank is linked By clicking on Fecth Now U can Fetch Your Linked Account Trsactions"
                            .toString(),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colorcodes.red),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Icon(
                    Icons.warning_outlined,
                    color: Colorcodes.red,
                    size: 30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        directFetch.value = true;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FetchTransaction(),
                          ),
                        );

                        // }else{

                        // }
                      },
                      child: getButton(context, "Fetch Now")),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${seletedAccountIds.length} Banks Linked..",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colorcodes.black)),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Access(),
                          ),
                        );
                      },
                      child: getButton(context, "continue")),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ));
  }

  Widget BankInfoUiContainer() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: AppColors.mt,
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 25,
                    color: AppColors.primaryColor,
                  )),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //textStyle("Bank Accounts", 16),
                  Text(
                    "Bank Accounts",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.bg1),
                  ),
                  Obx(() => textStyle("${count.value} accounts discovered", 12,
                      Colorcodes.graphColor1)),
                ],
              ),
            ],
          ),
          //const Divider(thickness: 1, height: 20),
          const SizedBox(height: 10),
          textStyle("Select atleast 1 Account to share from", 14),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget bankAccountList() {
    double height = MediaQuery.of(context).size.height;
    count.value = 0;
    return Container(
      //padding: const EdgeInsets.fromLTRB(14, 5, 16, 5),
      //here we can change height
      width: MediaQuery.of(context).size.width / 1.1,
      height: height / 1.7,
      // color: AppColors.bg3,
      child: SingleChildScrollView(
        child: Column(
          children: widget.listOfBankAccount.map((account) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display bank name and image before calling linkedaccoutnData
                getBankNameAndImage(account),
                FutureBuilder<Widget>(
                  future: linkedaccoutnData(account),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      return snapshot.data ??
                          SizedBox.shrink(); // Return the widget from Future
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

  Widget getListOfFinvuBanksAccounts(
      List<FinvuDiscoveredAccountInfo> account, FinvuFIPDetails fipDetails) {
    return account.isEmpty
        ? getNoBankAccount()
        : Column(
            children: account
                .map((bankData) => getBackUi(bankData, fipDetails))
                .toList(),
          );
  }

  void LinkingBank(
      FinvuFIPDetails fipDetails, String fipId, FinvuFIPInfo info) async {
    try {
      List<FinvuDiscoveredAccountInfo> bankData =
          listOfAccountAdded[fipId] ?? [];
      if (bankData.isEmpty) {
        snackBarCalled(
            context,
            "The account has been successfully added for linking.",
            Colorcodes.red);
        return;
      }
         linkingReference = await finvuManager.linkAccounts(fipDetails, bankData);
         isOtpWrong.value = false;
          startOtpTimer();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return verify(fipId, fipDetails, info, context);
        },
      );
    } catch (e) {
      snackBarCalledSignup(context, "Maximum Retries Exceeded. Please try again after sometime.");
    }
  }

  Widget verify(fid, FinvuFIPDetails fipDetails,
      FinvuFIPInfo info, context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context)
          .viewInsets, // Adjusts padding when keyboard appears
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.5,
        decoration: const BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                  child: textStyle("Securely authorize each selected account",
                      14, Colorcodes.black, FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: getBankNameAndImage(info, false),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: textStyle(
                  "OTP Verification", 20, AppColors.bg1, FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: textStyle("Enter the OTP sent to ${number.value}", 15,
                  AppColors.bg1, FontWeight.w400),
            ),
            const SizedBox(
              height: 10,
            ),
            
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                onSubmitted: (value)
                {
                    otpCount.value++;
                    linkAccount(_otpCode.value, fid, context,fipDetails);
                },
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.black12)),
                ),
                onChanged: (value) {
                  _otpCode.value = value;
                  _isOtpValid.value = value.toString().length>4; 
                  isOtpWrong.value = false;

                },
              ),
            ),
             Obx(
              () => isOtpWrong.value
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 0, 5),
                      child: Text(
                        "Incorrect OTP entered",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w300,
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : SizedBox.shrink(), // Empty widget when OTP is not wrong
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      "Didn't you receive the OTP?  ",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w200,
                        fontSize: 12,
                        color: AppColors.bg3,
                      ),
                    ),
                  ),
                   Obx(
                    () => GestureDetector(
                      onTap: canResendOtp.value
                          ? ()async
                          {
                              reSendOtp(fipDetails,fid);
                          }
                          : null,
                      child: Text(
                        canResendOtp.value
                            ? "Resend OTP"
                            : "Resend in ${otpCountdown.value} seconds",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 12,
                          color: canResendOtp.value
                              ? AppColors.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: InkWell(
                onTap: () {

                         if(_otpCode.value.length<6){
                          snackBarCalledSignup(context, "enter valid otp");
                         }else{
                          otpCount.value++;
                          linkAccount(_otpCode.value, fid, context,fipDetails);
                         }
                      
                      },
                child: Obx(
                  () => _isOtpValid.value ? getColorVerify() : getColorVerify(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getColorVerify() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: _isOtpValid.value
            ? AppColors.primaryColor
            : Colors.grey, // Button color based on validity
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "Verify",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.bg5,
          ),
        ),
      ),
    );
  }


void reSendOtp(fipDetails,fid)async{

      otpCount.value=0;
      List<FinvuDiscoveredAccountInfo> bankData = listOfAccountAdded[fid] ?? [];
      linkingReference =await finvuManager.linkAccounts(fipDetails, bankData);
      startOtpTimer();
      isOtpWrong.value = false;

}
 
void linkAccount( String otp, String fid, BuildContext context,FinvuFIPDetails fipDetails) async {
    try {
      isOtpWrong.value = false;
      FinvuConfirmAccountLinkingInfo data = await finvuManager.confirmAccountLinking(linkingReference, otpController.text.toString().trim());
      snackBarCalled(context, "Linked Bank account Successfully...");
      Navigator.pop(context);
      data.linkedAccounts.forEach((finvu) {
        listofLinkedAccount.add(finvu.accountReferenceNumber.toString());
      });
      //  listOfAccountAdded.containsKey(bankData.fipId)
      listOfAccountAdded.remove(fid);
      listofLinkedAccount.refresh();
      accountLinked.add(fid);
      //otpController = TextEditingController();
      otpController.clear();
      _otpCode.value = "";
        accountAdded.clear();
      _isOtpValid.value = false;
    } catch (e)
    {
     
      isOtpWrong.value = true;
     if(otpCount.value==2)reSendOtp(fipDetails,fid);

    }
  }

  Widget getBackUi(
      FinvuDiscoveredAccountInfo bankData, FinvuFIPDetails fipDetails) {
    String id = bankData.accountReferenceNumber.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                formatMaskedAccount(bankData),
                const SizedBox(
                  height: 2,
                ),
                Obx(() => listofLinkedAccount.contains(id)
                    ? textStyle("Linked", 13, Colorcodes.graphColor2)
                    : SizedBox.shrink())
              ],
            ),
            const Spacer(),
            checkBoxForAccountLink(bankData, fipDetails, id),
          ],
        ),
      ),
    );
  }

  Widget formatMaskedAccount(FinvuDiscoveredAccountInfo bankData) {
    int lenght = bankData.maskedAccountNumber.toString().length;
    return Row(
      children: [
        textStyle(
            toUpperCase(bankData.accountType.toLowerCase()) + " Account ", 14),
        (bankData.maskedAccountNumber.toString().length > 4)
            ? textStyle(
                '•' + bankData.maskedAccountNumber.substring(lenght - 4), 14)
            : textStyle('•' + bankData.maskedAccountNumber),
      ],
    );
  }

  Widget checkBoxForAccountLink(bankData, fipDetails, id) {
    return Obx(() => listofLinkedAccount.contains(id)
        ? Obx(() => addAccount.value ? getcheckBox(id) : getcheckBox(id))
        : Checkbox(
            value: accountAdded.contains(bankData.accountReferenceNumber),
            onChanged: (b) {
              addAccountToMap(
                  fipDetails.fipId, bankData.accountReferenceNumber, bankData);
            },
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // Apply border radius
            ),
          ));
  }

  Widget textStyle(text,
      [double fontsize = 12,
      Color c = AppColors.bg1,
      FontWeight fontWeight = FontWeight.w500]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 7,
        ),
        Text(
          text.toString(),
          style: FontManager().getTextStyle(context,
              lWeight: fontWeight, fontSize: fontsize, color: c),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<Widget> linkedaccoutnData(bankData) async {
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
            category: ele.category,
            type: ele.type,
            value: number.value, // dou
          );
          finvuTypeIdentifierInfo.add(obj);
        });
      });
      fipDetails = FinvuFIPDetails(
          fipId: fipId, typeIdentifiers: fetchFIPDetails.typeIdentifiers);
      FinvuFIPDetailsList[fipId] = fipDetails;
      info = await finvuManager.discoverAccounts(
          fipDetails.fipId, finvuFIPInfo.fipFitypes, finvuTypeIdentifierInfo);

      count.value += info.length;
      count.refresh();
    } catch (e) {
      return getNoBankAccount();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: getListOfFinvuBanksAccounts(info, fipDetails),
    );
  }

  Widget getBankNameAndImage(FinvuFIPInfo bankData, [bool flag = true]) {
    // List<FinvuDiscoveredAccountInfo> bankDataList = listOfAccountAdded[ bankData.fipId] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: 30,
                  height: 30,
                  child: Image.network(bankData.productIconUri.toString())),
              const SizedBox(
                width: 10,
              ),
              Container(
                  width: MediaQuery.of(context).size.width / 1.7,
                  child: textStyle(bankData.productName.toString(), 16,
                      AppColors.bg1, FontWeight.bold)),
            ],
          ),
          Obx(() => (!listOfAccountAdded.containsKey(bankData.fipId) || !flag)
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    otpController = TextEditingController(text: "");
                    LinkingBank(FinvuFIPDetailsList[bankData.fipId]!,
                        bankData.fipId, bankData);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadiusDirectional.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: Text(
                      "Link now".toString(),
                      style: TextStyle(fontSize: 12, color: Colorcodes.white),
                    ),
                  )
                  // ),
                  )),
        ],
      ),
    );
  }

  void addAccountToMap(String fipId, String accountReferenceNumber,
      FinvuDiscoveredAccountInfo bankData) {
    bool flag = accountAdded.contains(accountReferenceNumber);

    if (flag) {
      // If already added, remove from `accountAdded` and `listOfAccountAdded`
      accountAdded.remove(accountReferenceNumber);

      if (listOfAccountAdded.containsKey(fipId)) {
        listOfAccountAdded[fipId]!.removeWhere((account) =>
            account.accountReferenceNumber == accountReferenceNumber);

        // If the list is empty, remove the key from the map
        if (listOfAccountAdded[fipId]!.isEmpty) {
          listOfAccountAdded.remove(fipId);
        }
      }
    } else {
      // If not present, add it
      accountAdded.add(accountReferenceNumber);

      if (!listOfAccountAdded.containsKey(fipId)) {
        listOfAccountAdded[fipId] = [];
      }

      listOfAccountAdded[fipId]?.add(bankData);
    }
    // Update the observables
    listOfAccountAdded.refresh();
    accountAdded.refresh();
  }

  Widget getcheckBox(String fipId) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        width: 50,
        height: 50,
        child: Checkbox(
            value: seletedAccountIds.contains(fipId),
            // checkColor: AppColors.primaryColor,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // Apply border radius
            ),
            onChanged: (value) {
              if (seletedAccountIds.contains(fipId)) {
                seletedAccountIds.remove(fipId);
              } else {
                seletedAccountIds.add(fipId);
              }

              addAccount.value = !addAccount.value;
            }),
      ),
    );
  }

  Future<void> getAccountShared() async {
    try{
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
    }catch(e){
        print(e);
    }
  }
  
  Widget getNoBankAccount() {
    return textStyle("No accounts found please try with another bank",15);
  }
}


