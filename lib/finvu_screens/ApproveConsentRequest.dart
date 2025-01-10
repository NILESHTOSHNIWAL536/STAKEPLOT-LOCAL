import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

class ApproveConsent extends StatelessWidget {
  const ApproveConsent({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: BottomNavigations(data: sizeRoom?3:2),
       extendBody: true,
        appBar: AppBar(
       centerTitle: true,
       automaticallyImplyLeading: false,
       
       title: Container(
        width: MediaQuery.of(context).size.width,
         child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
           children: [
            const Spacer(),
                     Text(("Finvu"),
                     style: FontManager().getTextStyle(context,
                       lWeight: FontWeight.bold,
                       fontSize: 24,
                       color: Colorcodes.services),
                  
             
                 ),
                   
            ],
         ),
       )),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                
                InkWell(
                  onTap: ()async{
                         getConsentRequestDetails();
                         fetchLinkedAccounts();
                        approveConsentRequest(context);
                  },
                  child: getButton(context,"Approve consent")
                ),
      
              SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }
}







