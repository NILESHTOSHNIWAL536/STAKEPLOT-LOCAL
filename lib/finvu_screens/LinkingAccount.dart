import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/verifyLinkAccount.dart';
import 'package:flutter_application_code_stakeplot/main.dart';


class LinkingAccount extends StatefulWidget {
  List<FinvuDiscoveredAccountInfo> account;
  FinvuFIPDetails fipDetails;
   LinkingAccount({ Key? key,required this.account , required this.fipDetails}) : super(key: key);

  @override
  _LinkingAccountState createState() => _LinkingAccountState();
}

class _LinkingAccountState extends State<LinkingAccount> {
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Bank Account..."),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Container(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           child: Expanded(
             child: SingleChildScrollView(
               child:getListOfFinvuBanks(widget.account)
               )
           ),
      ),
    );
  }


  
  Widget getListOfFinvuBanks( List<FinvuDiscoveredAccountInfo> account)
  {
      return Column(
           children: account.map((bankData)=>getBackUi(bankData)).toList(),
      );     
  }

  Widget  getBackUi(FinvuDiscoveredAccountInfo bankData){
      return InkWell(
        onTap: ()async{
            //  FinvuFIPDetails fipDetails,
            //   List<FinvuDiscoveredAccountInfo> accounts,
           try{
            FinvuAccountLinkingRequestReference linkingReference=await finvuManager.linkAccounts(widget.fipDetails,[bankData]);
           
                Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyLinkAccount(linkingReference:linkingReference ),
              ),
            );
           }catch(e){
               print(e);
               snackBarCalled(context, "Account Already linked....");
           }

        },
        child: Container(
             width: MediaQuery.of(context).size.width,
             padding: EdgeInsets.symmetric(vertical: 20),
             child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                    Text(bankData.fiType.toString(),style: TextStyle(fontSize: 20,),),
                    const SizedBox(width: 10,),
                    Text(bankData.accountType.toString(),style: TextStyle(fontSize: 20,),),
              ],
             ) ,
        ),
      );
  }

}