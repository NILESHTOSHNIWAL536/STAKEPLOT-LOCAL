import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';

class ShareAccountLogin extends StatefulWidget {
  const ShareAccountLogin({ Key? key }) : super(key: key);

  @override
  _ShareAccountLoginState createState() => _ShareAccountLoginState();
}

class _ShareAccountLoginState extends State<ShareAccountLogin> {
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
            // const Spacer(),
                     Text(("Stakeplot"),
                     style: FontManager().getTextStyle(context,
                       lWeight: FontWeight.bold,
                       fontSize: 24,
                       color: AppColors.bg1),
                  
             
                 ),
                   
            ],
         ),
       )),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                
                InkWell(
                  onTap: (){
                    //  Otpscreen
                    // loginToAutoTractions(context);
                     Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Otpscreen(),
                      ),
                  );
                  },
                  child: getButton(context,"Share Account")
                ),
      
              SizedBox(height: 100,),

              
            ],
          ),
        ),
      ),
    );
  }
}



Widget getButton(context,str){

    return Container(
                  width: MediaQuery.of(context).size.width/3,
                  // height:MediaQuery.of(context).size.height,
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                  ),
                  child: Text(str),
          );
}



