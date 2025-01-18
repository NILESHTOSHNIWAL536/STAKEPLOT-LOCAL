import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/verifyLinkAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/verifyOTP.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

RxInt count=0.obs;

RxMap<String,List> listOfAccount=<String,List>{}.obs;

class LinkingAccount extends StatefulWidget {
  List<FinvuFIPInfo> listOfBankAccount;
   LinkingAccount({ Key? key , required this.listOfBankAccount}) : super(key: key);

  @override
  _LinkingAccountState createState() => _LinkingAccountState();
}

class _LinkingAccountState extends State<LinkingAccount> {
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Share Account"),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Container(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           child: Container(
            width: MediaQuery.of(context).size.width/1.1,
              child: Column(
                children: [
                  Text("Select Account To Share",style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold, fontSize: 18, color: Colorcodes.black),),
                  
                  SizedBox(width: 10,),
           
                  BankInfoUiContainer(),
                      
                  getButton(context, "Authorise"),
                 
                ],
              ),
           ),
      ),
    );
  }


  Widget   BankInfoUiContainer(){
     return Container(
        width: MediaQuery.of(context).size.width/1.2,
        child:Column(
          children: [
            Row(
                 children: [
                            CircleAvatar(
                              child: Icon(Icons.breakfast_dining_rounded,size: 20,color: Colors.cyan,)
                          ),
                          SizedBox(width: 10,),
                           Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text("Bank Accounts",style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400, fontSize: 16, color: Colorcodes.black),),
                              
                               Text("${count.value} Account discovered",style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400, fontSize: 16, color: Colorcodes.black),),
                             ],
                           ),
                  
        
        
            
                 ],
            ),
        
               Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text("Select Atleast One Account To Share",style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.bold, fontSize: 15, color: Colorcodes.black),),
                  ),
        
                  bankAccountList(),
          ],
        ) ,
     );
  }




  Widget bankAccountList(){
      return  Container(
        height: MediaQuery.of(context).size.height/1.5,
        child: SingleChildScrollView(
          child: Expanded(
            child: Column(
                              children: widget.listOfBankAccount.map((account) {
                                return FutureBuilder<Widget>(
                                  future: linkedaccoutnData(account),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Show loading indicator
                                    } else if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      return snapshot.data ?? SizedBox.shrink(); // Return the widget from Future
                                    }
                                  },
                                );
                              }).toList(),
            ),
          ),
        ),
      );
                    
  }



 

  
  Widget getListOfFinvuBanks( List<FinvuDiscoveredAccountInfo> account,FinvuFIPDetails fipDetails)
  {
      return Column(
           children: account.map((bankData)=>getBackUi(bankData,fipDetails)).toList(),
      );     
  }

  Widget  getBackUi(FinvuDiscoveredAccountInfo bankData,FinvuFIPDetails fipDetails){
      return InkWell(
        onTap: ()async{
            //  FinvuFIPDetails fipDetails,
            //   List<FinvuDiscoveredAccountInfo> accounts,
           try{
            FinvuAccountLinkingRequestReference linkingReference=await finvuManager.linkAccounts(fipDetails,[bankData]);
           
            //     Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => VerifyLinkAccount(linkingReference:linkingReference ),
            //   ),
            // );
                     showModalBottomSheet(context: context, builder: (context)
                    {
                          return VerifyOtp(linkingReference: linkingReference,flag: 1,);
                     },);


           }catch(e){
               print(e);
               snackBarCalled(context, "Account Already linked....");
           }

        },
        child: Container(
              
             width: MediaQuery.of(context).size.width,
             padding: EdgeInsets.symmetric(vertical: 10),
             child: Wrap(
               spacing: 2,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
            //  mainAxisAlignment: MainAxisAlignment.start,
            //  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Checkbox(value: bankData.isBlank, onChanged: (x){}),
                    const SizedBox(width: 10,),
                    Text(bankData.fiType.toString(),style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w500, fontSize: 15, color: Colorcodes.black),),
                    const SizedBox(width: 10,),
                    Text(bankData.accountType.toString(),style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w500, fontSize: 15, color: Colorcodes.black),),
                    const SizedBox(width: 10,),
                    Text(bankData.accountReferenceNumber.toString(),style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w500, fontSize: 15, color: Colorcodes.black),),
              ],
             ) ,
        ),
      );
  }

  
 Future<Widget> linkedaccoutnData(bankData)async
 {

             String fipId=bankData.fipId;
             FinvuFIPInfo finvuFIPInfo=bankData;
             FinvuFIPDetails fipDetails;
              List<FinvuDiscoveredAccountInfo> info=[];
 
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
                   value:number.value , // dou
                 );
                  finvuTypeIdentifierInfo.add(obj);       
             });

         });
           fipDetails=FinvuFIPDetails(fipId:fipId , typeIdentifiers: fetchFIPDetails.typeIdentifiers);
   
          info=await finvuManager.discoverAccounts(
            fipDetails,finvuFIPInfo.fipFitypes,finvuTypeIdentifierInfo);

          count += info.length;
          //  Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => LinkingAccount(account: info,fipDetails: fipDetails,),
          //     ),
          //   );


      }catch(e){
          //  snackBarCalled(context,"No Account Found...");   
          return SizedBox.shrink();
      } 

    return Container(
        width: MediaQuery.of(context).size.width,
         child: Column(
           children: [
              getBankNameAndImage(bankData),
              getListOfFinvuBanks(info,fipDetails),
           ],
         ),
    );
 }


 Widget getBankNameAndImage(bankData){
    return  Row(
                 children: [
                      Container(
                        width: 30,
                        height: 30,
                        child: Image.network(bankData.productIconUri.toString())
                      ),
                      SizedBox(width: 10,),
                      Text(bankData.productName.toString(),style: TextStyle(
                        fontSize: 15,
                      ),),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: ()
                        {
                                
                        },
                        child: Container(
                          decoration: BoxDecoration(
                             color: Colorcodes.cardShade5,
                             borderRadius: BorderRadiusDirectional.circular(10)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                          child: Text("Link".toString(),style: TextStyle(fontSize: 14,color: Colorcodes.white),),
                      ),
                  ),
                ],
             );
 }

}