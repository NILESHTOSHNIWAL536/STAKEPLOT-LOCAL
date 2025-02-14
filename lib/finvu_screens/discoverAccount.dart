import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchLinkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';


class DiscoverAccount extends StatefulWidget {
  const DiscoverAccount({Key? key}) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<DiscoverAccount> {
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
    getFetch.value = false;
  }

  void getData() async {
    fipDis = await finvuManager.fipsAllFIPOptions();
    fipDisOrginal.clear();
    fipDisOrginal.addAll(fipDis);
    getBanks.value = !getBanks.value;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        bottomNavigationBar: BottomBar(),
       
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // decoration: BoxDecoration(
            //     color: AppColors.mt, borderRadius: BorderRadius.circular(16)),
            //padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(children: [
                Padding(
                  padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Pick atleast one to proceed",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.bg1),
                    ),
                  ),
                ),
                // SizedBox(height: 5),
                InputDate("Search for banks", TextInputType.name, search),
                Obx(() => getBanks.value
                    ? getListOfFinvuBanks()
                    : getListOfFinvuBanks()),
                InkWell(
                  onTap: () {
                    count.value=0;
                    count.refresh();
                    getBankAccount();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: getButton(context, "Continue"),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget getListOfFinvuBanks() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.43,
      child: ListView.builder(
        itemCount: fipDis.length,
        itemBuilder: (context, index) {
          return getBackUi(fipDis[index]);
        },
      ),
    );
  }

  //modified code for checkbox
  void addBackToList(bool? boolVale, FinvuFIPInfo bankData) {
    if (boolVale == true) {
      // Add to the selected list
      if (!isSeletedBankAccout.contains(bankData.fipId)) {
        isSeletedBankAccout.add(bankData.fipId);
        listOfBankAccount.add(bankData);
      }
    } else {
      // Remove from the selected list
      isSeletedBankAccout.remove(bankData.fipId);
      listOfBankAccount.removeWhere((item) => item.fipId == bankData.fipId);
    }
    addBank.value = !addBank.value; // Trigger UI update
  }


  
  //modified code for checkbox
  Widget getBackUi(FinvuFIPInfo bankData) {
     bankImageAndid[bankData.fipId]=bankData.productIconUri.toString();
     
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         
         
          InkWell(
            onTap: (){
               addBackToList(isSeletedBankAccout.contains(bankData.fipId), bankData);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 50,
                height: 50,
                child: Image.network(
                  bankData.productIconUri.toString(),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          Expanded(
            child:   InkWell(
            onTap: (){
               addBackToList(isSeletedBankAccout.contains(bankData.fipId), bankData);
            },
              child: Text(
                bankData.productName.toString(),
                // style: TextStyle(
                //   fontSize: 15,
                //   overflow: TextOverflow.ellipsis,
                // ),
                style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 15,
                          color: AppColors.bg1,
                          overflow: TextOverflow.ellipsis)
              ),
            ),
          ),

           Obx(() => Checkbox(
                value: isSeletedBankAccout.contains(bankData.fipId),
                activeColor: AppColors.primaryColor,
                
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2), // Apply border radius
                ),
                onChanged: (bool? boolVale) {
                  // Toggle the checkbox selection
                  addBackToList(boolVale, bankData);
                },
          )),

        ],
      ),
    );
  }

  void searchFinvuAccount() async {
    if (search.text.isEmpty) {
      fipDis.clear();
      fipDis.addAll(fipDisOrginal);
    } else {
      fipDis.clear();

      fipDisOrginal.forEach((fipAccount) {
      
        if (fipAccount.productName
            .toString()
            .toLowerCase()
            .contains(search.text.toLowerCase())) {
          fipDis.add(fipAccount);
        }
      });
    }
    getBanks.value = !getBanks.value;
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Padding(
      padding: const EdgeInsets.only(top:4,bottom: 10),
      child: Center(
        child: Container(
          // margin: EdgeInsets.symmetric(vertical: 5),
          // color:  Color.fromRGBO(246, 246, 246, 1),
          // height: 50,
          width: MediaQuery.of(context).size.width / 1.1,
          child: Center(
            child: TextFormField(
              keyboardType: keyBoard,
              controller: Textcontroller,
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  searchFinvuAccount();
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                prefixIconColor: AppColors.primaryColor,
                //prefixIconColor: Colorcodes.budgetDarkGreen,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                hintText: lableText,
                hintStyle:  FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 14,
                          color: AppColors.bg3),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border
                      // color: Color.fromRGBO(249, 246, 238, 1)
                      )
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border)
                ),
                fillColor: AppColors.button,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getBankAccount() {
    if (listOfBankAccount.isEmpty) {
      snackBarCalled(
          context, "Pick atleast one Bank to proceed", Colorcodes.red);
      return;
    } else {
      //  listOfBankAccount
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LinkingAccount(
            listOfBankAccount: listOfBankAccount,
          ),
        ),
      );
    }
  }

  void linkedaccoutnData(bankData) async {
    String fipId = bankData.fipId;
    FinvuFIPInfo finvuFIPInfo = bankData;

    try {
      var fetchFIPDetails =
          await finvuManager.fetchFIPDetails(fipId); //dhanagarbank
      // var fetchFIPDetails=await finvuManager.fetchFIPDetails("dhanagarbank");
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
      FinvuFIPDetails fipDetails = FinvuFIPDetails(
          fipId: fipId, typeIdentifiers: fetchFIPDetails.typeIdentifiers);

      List<FinvuDiscoveredAccountInfo> info =
          await finvuManager.discoverAccounts(
              fipId, finvuFIPInfo.fipFitypes, finvuTypeIdentifierInfo);


      //  Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => LinkingAccount(account: info,fipDetails: fipDetails,),
      //     ),
      //   );
    } catch (e) {
      snackBarCalled(context, "No Account Found...");
    }
  }
}




//        String fipId=bankData.fipId;
      //        FinvuFIPInfo finvuFIPInfo=bankData;
 
      //     try{
      //   var fetchFIPDetails=await finvuManager.fetchFIPDetails(fipId); //dhanagarbank
      //   // var fetchFIPDetails=await finvuManager.fetchFIPDetails("dhanagarbank");
      //   var typeIdentifiers=fetchFIPDetails.typeIdentifiers;

      //   List<FinvuTypeIdentifierInfo> finvuTypeIdentifierInfo=[];

      //    typeIdentifiers.forEach((e){
      //        e.identifiers.forEach((ele){
      //            FinvuTypeIdentifierInfo obj=FinvuTypeIdentifierInfo(
      //              category: ele.category,
      //              type: ele.type,
      //              value:number.value , // dou
      //            );
      //             finvuTypeIdentifierInfo.add(obj);       
      //        });

      //    });
      //     FinvuFIPDetails fipDetails=FinvuFIPDetails(fipId:fipId , typeIdentifiers: fetchFIPDetails.typeIdentifiers);
   
      //     List<FinvuDiscoveredAccountInfo> info=await finvuManager.discoverAccounts(
      //       fipDetails,finvuFIPInfo.fipFitypes,finvuTypeIdentifierInfo);


          //  Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => LinkingAccount(account: info,fipDetails: fipDetails,),
          //     ),
          //   );


      // }catch(e){
      //      snackBarCalled(context,"No Account Found...");   
      // } 