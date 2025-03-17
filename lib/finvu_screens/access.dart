import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchLinkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Access extends StatefulWidget {
  const Access({super.key});

  @override
  State<Access> createState() => _AccessState();
}

class _AccessState extends State<Access> {
  // late FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo;

  RxBool flag = true.obs;
  @override
  void initState() {
    super.initState();
    // flag.value = false;
    // getInfomationsAboutUser();
  }

  void getInfomationsAboutUser() async {
    try {
      // fetchAccountData = await finvuManager.fetchLinkedAccounts();
      // finvuConsentRequestDetailInfo = await finvuManager.getConsentRequestDetails(handleId.value);
    } catch (e) {}
  }

  // void getAccountShared() async
  // {

  //      fetchAccountData.forEach((FinvuLinkedAccountDetailsInfo finvuInfo){
  //                try{
  //                 if(seletedAccountIds.contains(finvuInfo.accountReferenceNumber)){
  //                     seletedAccountInfomations.add(finvuInfo);
  //                 }
  //               }
  //                 catch(e){}
  //       });
  //    flag.value = true;
  // }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMM yyyy').format(date); // Format as Aug 2024
  }

  Widget topHeader() {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 25, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Give Permission",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.bg1,
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text:
                      "To share your accounts with Stakeplot for ", // Regular text
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 17,
                    color: AppColors.bg1,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "processing your loan application.", // Highlighted text
                      style: FontManager().getTextStyle(
                        context,
                        lWeight:
                            FontWeight.w600, // Make it bold or different weight
                        fontSize: 17,
                        color: AppColors.primaryColor, // Highlight color
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          bottomNavigationBar: BottomBar(),
          backgroundColor: AppColors.backgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10.0, 16, 16, 0),
            child: Obx(
              () => !flag.value
                  ? Loader()
                  : Container(
                      height: MediaQuery.of(context).size.height / 1.1,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          topHeader(),
                          informationBankAccount(),
                          pauseOrCancle(),
                          const Spacer(),
                          givePermissionOrDecline(),
                        ],
                      ),
                    ),
            ),
          )),
    );
  }

  Widget informationBankAccount() {
    String range = formatDate(finvuConsentRequestDetailInfo
            .consentDateTimeRange.from
            .toString()) +
        " to " +
        formatDate(
            finvuConsentRequestDetailInfo.consentDateTimeRange.to.toString());
    return Column(
      children: [
        accounts(
            "Accounts Shared",
            "${seletedAccountIds.length} Account(s) are shared",
            Icons.account_balance_wallet_outlined),
        accounts("Permission Validity", range, Icons.date_range_rounded),
        accounts("Frequency of Access",
            "We can access your information one-time.", Icons.access_time),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: viewMore(),
        ),
      ],
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
    return Container(
      // color: Colorcodes.billBody,
      width: MediaQuery.of(context).size.width / 1.5,
      child: Wrap(
        runAlignment: WrapAlignment.spaceAround,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          textStyle(data.fipName),
          const SizedBox(
            width: 5,
          ),
          textStyle(data.accountType),
          const SizedBox(
            width: 5,
          ),
          textStyle(data.maskedAccountNumber),
        ],
      ),
    );
  }

  Widget viewMore() {
    return
        // Section 4: View More Details
        GestureDetector(
      onTap: () {
        // Add navigation or functionality here
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width / 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20.0, 20, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details of your approval',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.bg1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: Colorcodes.space),
                            Text(
                              "Approval Requested on",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatDate(finvuConsentRequestDetailInfo
                                  .consentDateTimeRange.from
                                  .toString()),
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: Colorcodes.space),
                            Text(
                              "Purpose",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "To process your  loan application",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: Colorcodes.space),
                            Text(
                              "Account Details",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Profile,Summary Transactions",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: Colorcodes.space),
                            Text(
                              "Data life",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              finvuConsentRequestDetailInfo
                                      .consentDataLifePeriod.value
                                      .toString() +
                                  finvuConsentRequestDetailInfo
                                      .consentDataLifePeriod.unit
                                      .toString(),
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: Colorcodes.space),
                            Text(
                              "Approval Expiry",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatDate(finvuConsentRequestDetailInfo
                                  .consentDateTimeRange.to
                                  .toString()),
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: Colorcodes.space),
                            Text(
                              "Account Types",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.bg1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Wrap(
                                children: finvuConsentRequestDetailInfo.fiTypes!
                                    .map((e) => Text(
                                          e + ",",
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: AppColors.bg1,
                                          ),
                                        ))
                                    .toList()),
                            SizedBox(height: 20),
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: getButton(context, "Understand")),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      },
      child: Center(
        child: Text(
          "View more Details",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget accounts(String title, String value, IconData icon) {
    return Container(
      // width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colorcodes.white,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.bg1,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.7,
                child: Text(
                  value,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
              title == "Accounts Shared"
                  ? accountLikedInfo()
                  : SizedBox.shrink()
            ],
          ),
        ],
      ),
    );
  }

  Widget viewInfo() {
    return InkWell(
      onTap: () {
        // showModalBottomSheet(
        //     context: context,
        //     builder: (context) {
        //       return Container(
        //         child: accountInfo(),
        //       );
        //     });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 3, top: 5),
        child: Text(
          "View More",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w400,
            fontSize: 14,
            color: Colorcodes.blue,
          ),
        ),
      ),
    );
  }

  Widget accountInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  textStyle("Linked Bank Account", 15, AppColors.primaryColor,
                      FontWeight.bold),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fetchAccountData.map((e) {
                String url = bankImageAndid.containsKey(e.fipId)
                    ? bankImageAndid[e.fipId].toString()
                    : "".toString();
                //  var d=await finvuManager.fetchFIPDetails(e.fipId);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 40,
                          height: 30,
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      textStyle(e.fipName),
                      const SizedBox(
                        width: 5,
                      ),
                      textStyle(e.accountType),
                      const SizedBox(
                        width: 5,
                      ),
                      textStyle(e.maskedAccountNumber),
                      Obx(() => addAccount.value
                          ? getcheckBox(e.accountReferenceNumber)
                          : getcheckBox(e.accountReferenceNumber))
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getcheckBox(String fipId) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        width: 50,
        height: 50,
        child: Checkbox(
            value: seletedAccountIds.contains(fipId),
            onChanged: (value) {
              if (seletedAccountIds.contains(fipId)) {
                seletedAccountIds.remove(fipId);
              } else {
                seletedAccountIds.add(fipId);
              }
              print(seletedAccountIds);
              addAccount.value = !addAccount.value;
            }),
      ),
    );
  }

  Widget textStyle(text,
      [double fontsize = 12,
      Color c = AppColors.bg1,
      FontWeight fontWeight = FontWeight.w500]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
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
      ),
    );
  }

  Widget pauseOrCancle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 10),
          Container(
            width: MediaQuery.of(context).size.width / 1.2,
            child: Text(
              "You can pause or cancel sharing anytime via your Finvu app.",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: 15,
                color: AppColors.bg3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget givePermissionOrDecline() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            approveConsentRequest();
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "Give permission",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.bg5,
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            FinvuConsentRequestDetailInfo consentInfo =
                await finvuManager.getConsentRequestDetails(handleId.value);

            try {
              finvuManager.denyConsentRequest(consentInfo);
              clearStack(context);
              snackBarCalled(context, "Successfully disapproved the request.");
              Navigator.pushNamed(context, "/ShareAccountLogin");
            } catch (e) {
              snackBarCalled(context, "Unable to disapprove the request.");
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              //color: AppColors.accentColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                "Decline",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.bg1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void approveConsentRequest() async {
    try {
      FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo =
          await finvuManager.getConsentRequestDetails(handleId.value);

      if (seletedAccountIds.isEmpty) {
        snackBarCalled(context,
            "No accounts were selected. Please add an account to approve the consent.");
        return;
      }

      FinvuProcessConsentRequestResponse response =
          await finvuManager.approveConsentRequest(
              finvuConsentRequestDetailInfo, seletedAccountInfomations);

      snackBarCalled(context, "Consent request approved successfully.");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FetchTransaction(),
        ),
      );
    } catch (e) {
      snackBarCalled(
          context, "An error occurred while approving the consent request.");
    }
    debugPrint('approveConsentRequest');
  }

  Widget getcheckBox2(String fipId) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        width: 50,
        height: 50,
        child: Checkbox(
            value: seletedAccountIds.contains(fipId),
            onChanged: (value) {
              if (seletedAccountIds.contains(fipId)) {
                seletedAccountIds.remove(fipId);
              } else {
                seletedAccountIds.add(fipId);
              }
              print(seletedAccountIds);
              addAccount.value = !addAccount.value;
            }),
      ),
    );
  }
}
