import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

class FetchBankData extends StatefulWidget {
  const FetchBankData({ Key? key }) : super(key: key);

  @override
  _ShareAccountLoginState createState() => _ShareAccountLoginState();
}

class _ShareAccountLoginState extends State<FetchBankData> {
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
                  onTap: (){
                    //  Otpscreen
                      // fetch(context);
                     
                  },
                  child: getButton(context,"Fetch Data")
                ),
      
              SizedBox(height: 100,),
            Obx(()=> Text(fetchedData.value ?"Data is Fetched successfully....":"waiting for response from bank.....")),
              SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }
}




