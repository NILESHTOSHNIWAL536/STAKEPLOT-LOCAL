import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchLinkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/main.dart';

String bankImage="https://static.vecteezy.com/system/resources/thumbnails/023/364/757/small_2x/3d-illustration-of-bank-building-and-money-bag-png.png";


class ShareAccountLogin extends StatefulWidget {
  bool flag = false;
  ShareAccountLogin({Key? key, this.flag = false}) : super(key: key);

  @override
  _ShareAccountLoginState createState() => _ShareAccountLoginState();
}

class _ShareAccountLoginState extends State<ShareAccountLogin> {



 
    @override
  void initState() {
    super.initState();
    if(widget.flag)getData();
  }

  void getData()async
  {
     fipDis=await finvuManager.fipsAllFIPOptions();
     List<FinvuLinkedAccountDetailsInfo> data=await finvuManager.fetchLinkedAccounts();
     listofLinkedAccount.clear();
     if(data.isNotEmpty){
                      data.forEach((finvu){
                             listofLinkedAccount.add(finvu.accountReferenceNumber.toString());
                      });
     }
     fipDisOrginal.clear();
     fipDisOrginal.addAll(fipDis);
     getBanks.value=!getBanks.value;
  }


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
                Text(
                  ("Stakeplot"),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.bg1),
                ),
              ],
            ),
          )),
      bottomSheet: bottomSheet(context),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppColors.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 1.2,
              // color: Colorcodes.barGraphOrange,
              child: Image.network(bankImage),
            ),
            // SizedBox.shrink(),
            InkWell(
                onTap: () {
                  //  Otpscreen
                  // loginToAutoTractions(context);
                  if(!widget.flag)LOGOUT();
                  if(!widget.flag)initFinvuManager();
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          widget.flag ? DiscoverAccount() : MobileNumber(),
                    ),
                  );

                },
                child:  getButton(context,
                    widget.flag ? getFetch.value? "Loading...":"Fetch Bank Account" : "Share Account")),
          ],
        ),
      ),
    );
  }
}

Widget getButton(context, str) {
  return Container(
    width: MediaQuery.of(context).size.width / 1.2,
    // height:MediaQuery.of(context).size.height,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(
        color: AppColors.primaryColor, borderRadius: BorderRadius.circular(24)),
    child: Center(
      child: Text(
        str,
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold, fontSize: 15, color: AppColors.bg5),
      ),
    ),
  );
}



Widget bottomSheet(context){
   return Container(
            width: MediaQuery.of(context).size.width,
            height: 20,
            decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                     color: Colorcodes.greyLight
                  ),
                )
            ),
            child: Center(
                child: Text("Powered By RBI-Regulated AA",style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold
                ),),
            ),
      );
}