
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

List<FinvuFIPInfo> fipDis=[];
RxList isSeletedBankAccout=[].obs;
RxList<FinvuFIPInfo> listOfBankAccount=<FinvuFIPInfo>[].obs;
RxBool getBanks=false.obs;
RxBool addBank=false.obs;

class DiscoverAccount extends StatefulWidget {
  const DiscoverAccount({ Key? key }) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<DiscoverAccount> {

    @override
  void initState() {
    super.initState();
    getData();
  }

  void getData()async
  {
     fipDis=await finvuManager.fipsAllFIPOptions();
     getBanks.value=!getBanks.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selete Bank..." ,style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold, fontSize: 18, color: Colorcodes.black),),
        backgroundColor: Colorcodes.white,
      ),
      body: Container(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           child: Expanded(
             child: SingleChildScrollView(
               child:Column(children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    child: Text("Pick atleast one to proceed..." ,style: FontManager().getTextStyle(context,
                         lWeight: FontWeight.bold, fontSize: 18, color: Colorcodes.black),),
                  ),

                    Obx(()=>getBanks.value? getListOfFinvuBanks(): getListOfFinvuBanks()),

                    InkWell(
                      onTap: () {
                           getBankAccount();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: getButton(context, "Fetch Bank Account.."),
                      ),
                    ),

               ]),
             ),
           ),
      ),
    );
  }



  Widget getListOfFinvuBanks()
  {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/1.4,
        child: SingleChildScrollView(
          child: Expanded(
            child: Column(
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: fipDis.map((bankData)=>getBackUi(bankData)).toList(),
            ),
          ),
        ),
      );     
  }

  Widget getBackUi(FinvuFIPInfo bankData){
     return InkWell(
      onTap: ()async{
             String fipId=bankData.fipId;
             FinvuFIPInfo finvuFIPInfo=bankData;
 
          try{
        var fetchFIPDetails=await finvuManager.fetchFIPDetails(fipId); //dhanagarbank
        // var fetchFIPDetails=await finvuManager.fetchFIPDetails("dhanagarbank");
        var typeIdentifiers=fetchFIPDetails.typeIdentifiers;

        List<FinvuTypeIdentifierInfo> finvuTypeIdentifierInfo=[];

         typeIdentifiers.forEach((e){
             e.identifiers.forEach((ele){
                 FinvuTypeIdentifierInfo obj=FinvuTypeIdentifierInfo(
                   category: ele.category,
                   type: ele.type,
                   value:number , // dou
                 );
                  finvuTypeIdentifierInfo.add(obj);       
             });

         });
          FinvuFIPDetails fipDetails=FinvuFIPDetails(fipId:fipId , typeIdentifiers: fetchFIPDetails.typeIdentifiers);
   
          List<FinvuDiscoveredAccountInfo> info=await finvuManager.discoverAccounts(
            fipDetails,finvuFIPInfo.fipFitypes,finvuTypeIdentifierInfo);


           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LinkingAccount(account: info,fipDetails: fipDetails,),
              ),
            );


      }catch(e){
           snackBarCalled(context,"No Account Found...");   
      } 

      },
       child: Container(
           width: MediaQuery.of(context).size.width,
           padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
           child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Obx(()=>Checkbox(value: addBank.value?isSeletedBankAccout.contains(bankData.fipId):isSeletedBankAccout.contains(bankData.fipId), onChanged: (boolVale)
                  {     
                      
                       
                        if(boolVale!){
                               listOfBankAccount.removeWhere((item) => item.fipId == bankData.fipId);
                                isSeletedBankAccout.remove(bankData.fipId);
                        }else{
                             listOfBankAccount.add(bankData);
                             isSeletedBankAccout.add(bankData.fipId);
                        }
                          addBank.value=!addBank.value;
                        // boolVale! ? isSeletedBankAccout.add(bankData.fipId):isSeletedBankAccout.remove(bankData.fipId);
                  })),
                   SizedBox(width: 10,),
                  Container(
                    width: 50,
                    height: 50,
                    child: Image.network(bankData.productIconUri.toString())
                  ),
                  SizedBox(width: 10,),
                  Text(bankData.productName.toString(),style: TextStyle(
                    fontSize: 15,
                  ),),
            ],
           ) ,
       ),
     );
  }
  
  void getBankAccount() {
        if(listOfBankAccount.isEmpty){
             snackBarCalled(context, "Pick atleast one to proceed...",Colorcodes.red);
             return;
        }
  }




}