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
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/verifyOTP.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


RxMap<String, List<FinvuDiscoveredAccountInfo>> listOfAccountAdded =
    <String, List<FinvuDiscoveredAccountInfo>>{}.obs;
RxMap<String, FinvuFIPDetails> FinvuFIPDetailsList =
    <String, FinvuFIPDetails>{}.obs;
RxList accountAdded = [].obs;
RxList accountLinked = [].obs;
RxInt count = 0.obs;

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
    count.value=0;
    getLinkedAccountList();
  }


  void getLinkedAccountList()async{
          // var data=await  FinvuManager().fetchLinkedAccounts();
  }


  @override
  Widget build(BuildContext context) {
    // final double boxSize = MediaQuery.of(context).size.width * 0.12;

    return Scaffold(
      appBar: AppBar(
        title: Text("Link Accounts"),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/1.2,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    "Select account to share",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.bg1),
                  ),
                ),
                // SizedBox(
                //   width: 10,
                // ),
                BankInfoUiContainer(),
                // const Spacer(),
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
      padding: const EdgeInsets.all(12.0),
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
          textStyle("Select atleast One Account To Share", 15),
          const SizedBox(height: 10),
          bankAccountList(),
        ],
      ),
    );
  }

  Widget bankAccountList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 5, 16, 5),
      height: MediaQuery.of(context).size.height / 1.7,
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
          return verify(linkingReference,fipId);
          // return VerifyOtp(
          //   linkingReference: linkingReference,
          //   flag: 1,
          //   fid: fipId,
          // );
        },
      );
    } catch (e) {
      print(e);
      snackBarCalled(context, "Added check has Some Linked Account....");
    }
  }



 Widget verify(linkingReference,fid){
    return  Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/2,
      decoration: BoxDecoration(
         color: Colorcodes.white,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20,),
          Text("Verify Otp"),
          const SizedBox(height: 20,),
          PinCodeTextField(
                    appContext: context,
                    length: _otpCodeLength,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: MediaQuery.of(context).size.width * 0.12,
                      fieldWidth: MediaQuery.of(context).size.width * 0.12,
                      activeFillColor: Colors.white,
                      activeColor: Colors.blue,
                      selectedFillColor: Colors.white,
                      selectedColor: Colors.blue,
                      inactiveFillColor: Colors.grey[200],
                      inactiveColor: Colors.grey,
                    ),
                    enableActiveFill: true,
                    textStyle: TextStyle(fontSize: 18, color: Colors.black),
                    onChanged: (value) {
                    
                        _otpCode.value = value;
                        _isOtpValid.value = value.length == _otpCodeLength;
                    },
                    // onCompleted: (value) {
                    //   _onOtpSubmit();
                    // },
                ),
           const SizedBox(height: 20,),

           GestureDetector(
              onTap: _isOtpValid.value
                  ? () {
                        if(_isOtpValid.value){
                         linkAccount(_otpCode.value,linkingReference,fid);
                        }else{
                           snackBarCalled(context, "pls enter otp of length 6");
                        }
                    
                    }
                  : null,
              child:Obx(()=> _isOtpValid.value ? getColorVerify():getColorVerify(),
           )),
        ],
      ),
    );
 }

 Widget getColorVerify(){
     return Container(
                width: MediaQuery.of(context).size.width / 1.1,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  color: _isOtpValid.value
                      ? AppColors.accentColor
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


   void linkAccount(String otp,linkingReference,String fid) async {
      try {
      
        var data = await finvuManager.confirmAccountLinking(
            linkingReference!, otp);
        snackBarCalled(context, "Linked Bank SuccessFully...");
        Navigator.pop(context);
       
        accountLinked.add(fid);
        otpController=TextEditingController();
        _otpCode.value="";
        _isOtpValid.value=false;
      } catch (e) {
        print(e);
        snackBarCalled(context,
            "Error while Linking verify Otp/ Or Already Linked...", Colors.red);
      }
  }


  Widget getBackUi(
      FinvuDiscoveredAccountInfo bankData, FinvuFIPDetails fipDetails) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 4),
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
              textStyle(bankData.maskedAccountNumber),
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
          child: 
          // Obx(() => accountLinked.contains(bankData.fipId)
          //     ? SizedBox.shrink()
          //     : 
              Container(
                  decoration: BoxDecoration(
                      color: Colorcodes.cardShade5,
                      borderRadius: BorderRadiusDirectional.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Text(
                    "Link".toString(),
                    style: TextStyle(fontSize: 14, color: Colorcodes.white),
                  ),
                )
                // ),
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
