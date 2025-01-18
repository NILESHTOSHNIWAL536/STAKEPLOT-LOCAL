import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';

class ShareAccountLogin extends StatefulWidget { 
  bool flag = false;
   ShareAccountLogin({Key? key,this.flag=false}) : super(key: key);

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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 1.2,
              color: Colorcodes.barGraphOrange,
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(24),
              //     border: Border.all(color: Colors.black)),
            ),
            // SizedBox.shrink(),
            InkWell(
                onTap: () {
                  //  Otpscreen
                  // loginToAutoTractions(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.flag? DiscoverAccount():Otpscreen(),
                    ),
                  );
                },
                child: getButton(context,widget.flag? "Fetch Bank Account":"Share Account")),
          ],
        ),
      ),
    );
  }
}

Widget getButton(context, str) {
  return Container(
    width: MediaQuery.of(context).size.width / 1.4,
    // height:MediaQuery.of(context).size.height,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
    decoration: BoxDecoration(
        color: AppColors.bg6, borderRadius: BorderRadius.circular(10)),
    child: Center(
      child: Text(
        str,
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold, fontSize: 24, color: Colorcodes.white),
      ),
    ),
  );
}
