
import 'dart:convert';

import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

List<FinvuLinkedAccountDetailsInfo> fetchAccountData=[];
RxBool getBanks=false.obs;

class FetchLinkedAccounts extends StatefulWidget {
  const FetchLinkedAccounts({ Key? key }) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<FetchLinkedAccounts> {

    @override
  void initState() {
    super.initState();
    getData();
  }

  void getData()async
  {
     fetchAccountData=await finvuManager.fetchLinkedAccounts();
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


// fetchAccountData
  Widget getListOfFinvuBanks()
  {
      return Column(
        children: [
          Column(
               children: fetchAccountData.map((bankData)=>getBackUi(bankData)).toList(),
          ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: (){
                    
                        approveConsentRequest();
                },
                child: Text('Approve consent'),
              ),
            ),
          
        ],
      );     
  }

  void approveConsentRequest() async {
    
    try{
        
         FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo=await finvuManager.getConsentRequestDetails(handleId.value);
        //  print('handleId.value');
         FinvuProcessConsentRequestResponse response=await finvuManager.approveConsentRequest(finvuConsentRequestDetailInfo,fetchAccountData);
        //  print(handleId.value);
        //  print(response.consentIntentId);
         response.consentInfo!.forEach((e){
              // print("e.consentId----------------");
              // print(e.consentId);
              // print(e.fipId);
         });
       
          snackBarCalled(context, "approved ConsentRequest");
             Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FetchTransaction(),
                                  ),
                                );  
        

    }catch(e){
         snackBarCalled(context, "Error while approving ConsentRequest");
         print("d.consentIntentId error");
         
    }
    debugPrint('approveConsentRequest');
  }

  Widget getBackUi(FinvuLinkedAccountDetailsInfo bankData){
     return InkWell(
      onTap: ()async{
            

      },
       child: Container(
           width: MediaQuery.of(context).size.width,
           padding: EdgeInsets.symmetric(vertical: 20),
           child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  Text(bankData.fipName.toString(),style: TextStyle(fontSize: 15,),),
                  Text(bankData.accountType.toString(),style: TextStyle(fontSize: 15,),),
                  Text(bankData.accountReferenceNumber.toString(),style: TextStyle(fontSize: 15,),),
            ],
           ) ,
       ),
     );
  }


  

}



//  String fipId=bankData.fipId;
//              FinvuFIPInfo finvuFIPInfo=bankData;
 
//           try{
//         var fetchFIPDetails=await finvuManager.fetchFIPDetails(fipId); //dhanagarbank
//         // var fetchFIPDetails=await finvuManager.fetchFIPDetails("dhanagarbank");
//         var typeIdentifiers=fetchFIPDetails.typeIdentifiers;

//         List<FinvuTypeIdentifierInfo> finvuTypeIdentifierInfo=[];

//          typeIdentifiers.forEach((e){
//              e.identifiers.forEach((ele){
//                  FinvuTypeIdentifierInfo obj=FinvuTypeIdentifierInfo(
//                    category: ele.category,
//                    type: ele.type,
//                    value:number , // dou
//                  );
//                   finvuTypeIdentifierInfo.add(obj);       
//              });

//          });
//           FinvuFIPDetails fipDetails=FinvuFIPDetails(fipId:fipId , typeIdentifiers: fetchFIPDetails.typeIdentifiers);
   
//           List<FinvuDiscoveredAccountInfo> info=await finvuManager.discoverAccounts(
//             fipDetails,finvuFIPInfo.fipFitypes,finvuTypeIdentifierInfo);

//            info.forEach((e){
//               print('e.accountType');
//               print(e.accountType);
//               print(e.fiType);
//            }); 

//            Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => LinkingAccount(account: info,fipDetails: fipDetails,),
//               ),
//             );

//       }catch(e){
//            snackBarCalled(context,"No Account Found...");   
//       } 