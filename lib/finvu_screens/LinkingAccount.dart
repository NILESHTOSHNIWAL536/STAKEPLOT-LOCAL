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
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/verifyOTP.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

RxInt count = 0.obs;

RxMap<String, List<FinvuDiscoveredAccountInfo>> listOfAccountAdded =
    <String, List<FinvuDiscoveredAccountInfo>>{}.obs;
RxMap<String, FinvuFIPDetails> FinvuFIPDetailsList =
    <String, FinvuFIPDetails>{}.obs;
RxList accountAdded = [].obs;
RxList accountLinked = [].obs;

class LinkingAccount extends StatefulWidget {
  List<FinvuFIPInfo> listOfBankAccount;
  LinkingAccount({Key? key, required this.listOfBankAccount}) : super(key: key);

  @override
  _LinkingAccountState createState() => _LinkingAccountState();
}

class _LinkingAccountState extends State<LinkingAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Link Accounts"),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          //width: MediaQuery.of(context).size.width / 1.1,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Select account to share",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.bg1),
                  ),
                ),
              ),
              // SizedBox(
              //   width: 10,
              // ),
              BankInfoUiContainer(),
              const Spacer(),
              InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return accountLinkedUi();
                      },
                    );
                  },
                  child: getButton(context, "Authorise")),
            ],
          ),
        ),
      ),
    );
  }

  Widget accountLinkedUi() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: accountLinked.isEmpty
            ? MediaQuery.of(context).size.height / 4
            : MediaQuery.of(context).size.height / 3,
        child: accountLinked.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  textStyle("Please tap on 'Link Now' to link your bank", 12),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: getButton(context, "okay")),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              )
            : Column(
                children: [
                  Text("${accountLinked.length} Banks Linked..",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 11,
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
      //width: MediaQuery.of(context).size.width / 1.2,
      //padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                  child: Icon(
                Icons.breakfast_dining_rounded,
                size: 20,
                color: Colors.cyan,
              )),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyle("Bank Accounts", 16),
                  textStyle("${count.value} Account(s) discovered", 16),
                ],
              ),
            ],
          ),
          //const Divider(thickness: 1, height: 20),
          const SizedBox(height: 10),
          textStyle("Select atleast One Account To Share", 15),
          const SizedBox(height: 10),
          bankAccountList(),
        ],
      ),
    );
  }

  Widget bankAccountList() {
    return Container(
      //padding: const EdgeInsets.fromLTRB(14, 5, 16, 5),
      height: MediaQuery.of(context).size.height / 2,
      child: SingleChildScrollView(
        child: Expanded(
          child: Column(
            children: widget.listOfBankAccount.map((account) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }

  Widget getListOfFinvuBanksAccounts(
      List<FinvuDiscoveredAccountInfo> account, FinvuFIPDetails fipDetails) {
    return account.isEmpty
        ? Text("No Accounts Found..")
        : Column(
            children: account
                .map((bankData) => getBackUi(bankData, fipDetails))
                .toList(),
          );
  }

  void LinkingBank(FinvuFIPDetails fipDetails, String fipId) async {
    try {
      List<FinvuDiscoveredAccountInfo> bankData =
          listOfAccountAdded[fipId] ?? [];

      FinvuAccountLinkingRequestReference linkingReference =
          await finvuManager.linkAccounts(fipDetails, bankData);
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return VerifyOtp(
            linkingReference: linkingReference,
            flag: 1,
            fid: fipId,
          );
        },
      );
    } catch (e) {
      snackBarCalled(context, "Account already linked....");
    }
  }

  Widget getBackUi(
      FinvuDiscoveredAccountInfo bankData, FinvuFIPDetails fipDetails) {
    return Container(
      width: MediaQuery.of(context).size.width,
      //padding: EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Expanded(
          child: Row(
            children: [
              Obx(() => Checkbox(
                  value: accountAdded.contains(bankData.accountReferenceNumber),
                  onChanged: (b) {
                    addAccountToMap(fipDetails.fipId,
                        bankData.accountReferenceNumber, bankData);
                  })),
              textStyle(bankData.fiType),
              textStyle(bankData.accountType),
              textStyle(bankData.accountReferenceNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget textStyle(text, [double fontsize = 12]) {
    return Column(
      children: [
        const SizedBox(
          width: 7,
        ),
        Text(
          text.toString(),
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500,
              fontSize: fontsize,
              color: AppColors.bg1),
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
          fipDetails, finvuFIPInfo.fipFitypes, finvuTypeIdentifierInfo);

      count += info.length;
    } catch (e) {
      return SizedBox.shrink();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: getListOfFinvuBanksAccounts(info, fipDetails),
    );
  }

  Widget getBankNameAndImage(FinvuFIPInfo bankData) {
    return Row(
      children: [
        Container(
            width: 30,
            height: 30,
            child: Image.network(bankData.productIconUri.toString())),
        const SizedBox(
          width: 10,
        ),
        textStyle(bankData.productName, 15),
        SizedBox(
          width: 10,
        ),
        InkWell(
          onTap: () {
            LinkingBank(FinvuFIPDetailsList[bankData.fipId]!, bankData.fipId);
          },
          child: Obx(() => accountLinked.contains(bankData.fipId)
              ? SizedBox.shrink()
              : Container(
                  decoration: BoxDecoration(
                      color: Colorcodes.cardShade5,
                      borderRadius: BorderRadiusDirectional.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Text(
                    "Link".toString(),
                    style: TextStyle(fontSize: 14, color: Colorcodes.white),
                  ),
                )),
        ),
      ],
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
}
