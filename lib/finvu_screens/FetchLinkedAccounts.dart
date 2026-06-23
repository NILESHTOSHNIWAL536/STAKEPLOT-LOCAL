import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';
import '../loginservices/login.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';





class FetchLinkedAccounts extends StatefulWidget {
  const FetchLinkedAccounts({Key? key}) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<FetchLinkedAccounts> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    // FinvuLinkedAccountDetailsInfo
    fetchAccountData = await finvuManager.fetchLinkedAccounts();
    getBanks.value = !getBanks.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Account"),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Expanded(
          child: SingleChildScrollView(
              child: Obx(() => getBanks.value
                  ? getListOfFinvuBanks()
                  : getListOfFinvuBanks())),
        ),
      ),
    );
  }

// fetchAccountData
  Widget getListOfFinvuBanks() {
    return Column(
      children: [
        Column(
          children:
              fetchAccountData.map((bankData) => getBackUi(bankData)).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.p8),
          child: ElevatedButton(
            onPressed: () {
              approveConsentRequest();
            },
            child: Text(FinvuStrings().approveConsent),
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
        snackBarCalledfail(
            context, "No account was selected. Please add an account.");
      }
      fetchAccountData.forEach((FinvuLinkedAccountDetailsInfo finvuInfo) {
        if (seletedAccountIds.contains(finvuInfo.fipId)) {
          seletedAccountInfomations.add(finvuInfo);
        }
      });

      FinvuProcessConsentRequestResponse response =
          await finvuManager.approveConsentRequest(
              finvuConsentRequestDetailInfo, seletedAccountInfomations);

      snackBarCalled(context,
          "Successfully approved the consent request for ${seletedAccountInfomations.length} accounts.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FetchTransaction(),
        ),
      );
    } catch (e) {
      snackBarCalledfail(context, "Error while approving the consent request.");
    }
  }

  Widget getBackUi(FinvuLinkedAccountDetailsInfo bankData) {
    return InkWell(
      onTap: () async {},
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: AppSizes.p20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              bankData.fipName.toString(),
              style: FontManager().getTextStyle(context, fontSize: 15),
            ),
            Text(
              bankData.accountType.toString(),
              style: FontManager().getTextStyle(context, fontSize: 15),
            ),
            Text(
              bankData.accountReferenceNumber.toString(),
              style: FontManager().getTextStyle(context, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
