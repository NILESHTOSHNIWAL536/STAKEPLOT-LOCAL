
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

List<FinvuFIPInfo> fipDis=[];
RxBool getBanks=false.obs;

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
        title: Text("Bank Account..."),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Container(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           child: Expanded(
             child: SingleChildScrollView(
               child: Obx(()=>getBanks.value? getListOfFinvuBanks(): getListOfFinvuBanks())
             ),
           ),
      ),
    );
  }



  Widget getListOfFinvuBanks()
  {
      return Column(
           children: fipDis.map((bankData)=>getBackUi(bankData)).toList(),
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

          //  info.forEach((e){
          //     print('e.accountType');
          //     print(e.accountType);
          //     print(e.fiType);
          //  }); 

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
           padding: EdgeInsets.symmetric(vertical: 20),
           child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  Text(bankData.productName.toString(),style: TextStyle(
                    fontSize: 20,
                  ),),
            ],
           ) ,
       ),
     );
  }




}