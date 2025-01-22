
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
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

List<FinvuFIPInfo> fipDis=[];
List<FinvuFIPInfo> fipDisOrginal=[];
RxList isSeletedBankAccout=[].obs;
RxList<FinvuFIPInfo> listOfBankAccount=<FinvuFIPInfo>[].obs;
// RxBool getBanks=false.obs;
RxBool addBank=false.obs;

class DiscoverAccount extends StatefulWidget {
  const  DiscoverAccount({ Key? key }) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<DiscoverAccount> {

    TextEditingController search = TextEditingController();

    @override
  void initState() {
    super.initState();
    getData();
    getFetch.value=false;
  }

  void getData()async
  {
     fipDis=await finvuManager.fipsAllFIPOptions();
     fipDisOrginal.clear();
     fipDisOrginal.addAll(fipDis);
     getBanks.value=!getBanks.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Select Bank" ,style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold, fontSize: 18, color: Colorcodes.black),),
        ),
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
                    child: Text("Pick atleast one bank to proceed..." ,style: FontManager().getTextStyle(context,
                         lWeight: FontWeight.bold, fontSize: 18, color: Colorcodes.black),),
                  ),

                  InputDate("Search", TextInputType.name, search),

                    Obx(()=>getBanks.value? getListOfFinvuBanks(): getListOfFinvuBanks()),

                    InkWell(
                      onTap: () {
                           getBankAccount();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: getButton(context, "Fetch Bank Account"),
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
      // return Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height/1.5,
      //   child: SingleChildScrollView(
      //     child: Expanded(
      //       child: Column(
      //            mainAxisAlignment: MainAxisAlignment.start,
      //            crossAxisAlignment: CrossAxisAlignment.start,
      //            children: fipDis.map((bankData)=>getBackUi(bankData)).toList(),
      //       ),
      //     ),
      //   ),
      // );
      return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: ListView.builder(
                      itemCount: fipDis.length,
                      itemBuilder: (context, index) {
                        return getBackUi(fipDis[index]); 
                      },
                    ),
          );     
  }

  void addBackToList(boolVale,bankData)
  { 
                if(boolVale!){
                          listOfBankAccount.removeWhere((item) => item.fipId == bankData.fipId);
                          isSeletedBankAccout.remove(bankData.fipId);

                    }else{
                             listOfBankAccount.add(bankData);
                             isSeletedBankAccout.add(bankData.fipId);
                }
                          addBank.value=!addBank.value;
  }

  Widget getBackUi(FinvuFIPInfo bankData){
     return Container(
         width: MediaQuery.of(context).size.width,
         padding: EdgeInsets.symmetric(vertical: 5,horizontal: 13),
         child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Obx(()=>
              Checkbox(
                value: addBank.value?isSeletedBankAccout.contains(bankData.fipId):isSeletedBankAccout.contains(bankData.fipId),
                 onChanged: (boolVale)
                {  
                   
                     addBackToList(boolVale,bankData);
                },
          
                
                )
              ),
                 SizedBox(width: 10,),
                Container(
                  width: 50,
                  height: 50,
                  child: Image.network(bankData.productIconUri.toString())
                ),
                SizedBox(width: 10,),
                InkWell(
                  onTap: (){
                     addBackToList(isSeletedBankAccout.contains(bankData.fipId),bankData);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width/1.8,
                    child: Text(bankData.productName.toString(),style: TextStyle(
                      fontSize: 15,
                      overflow:TextOverflow.ellipsis
                    ),),
                  ),
                ),
          ],
         ) ,
     );
  }

  void searchFinvuAccount()async{
       if(search.text.isEmpty){
       
                fipDis.clear();
                fipDis.addAll(fipDisOrginal);
              
       }else{
          fipDis.clear();
      
          fipDisOrginal.forEach((fipAccount){
                  print(fipDis);
                  if(fipAccount.productName.toString().toLowerCase().contains(search.text.toLowerCase())){
                        fipDis.add(fipAccount);
                  }
          });
      }
       getBanks.value=!getBanks.value;
  }


  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
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
                   searchFinvuAccount();
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              //prefixIconColor: Colorcodes.budgetDarkGreen,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              hintText: lableText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                // borderSide: BorderSide(color: Colorcodes.budgetDarkGreen
                //     // color: Color.fromRGBO(249, 246, 238, 1)
                //     )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                //borderSide: BorderSide(color: Colorcodes.budgetDarkGreen)
              ),
              fillColor: AppColors.button,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
  
  void getBankAccount() {
        if(listOfBankAccount.isEmpty){
             snackBarCalled(context, "Pick atleast one Bank to proceed...",Colorcodes.red);
             return;
        }else{
            //  listOfBankAccount
                    Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LinkingAccount(listOfBankAccount: listOfBankAccount,),
              ),
            );
        }
  }


 void linkedaccoutnData(bankData)async
 {

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
                   
                   value:number.value , // dou
                   
                 );
                  finvuTypeIdentifierInfo.add(obj);       
             });

         });
          FinvuFIPDetails fipDetails=FinvuFIPDetails(fipId:fipId , typeIdentifiers: fetchFIPDetails.typeIdentifiers);
   
          List<FinvuDiscoveredAccountInfo> info=await finvuManager.discoverAccounts(
            fipDetails,finvuFIPInfo.fipFitypes,finvuTypeIdentifierInfo);


          //  Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => LinkingAccount(account: info,fipDetails: fipDetails,),
          //     ),
          //   );


      }catch(e){
           snackBarCalled(context,"No Account Found...");   
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