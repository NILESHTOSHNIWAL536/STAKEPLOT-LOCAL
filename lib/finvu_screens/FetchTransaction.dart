import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
  // fetch(context);

class FetchTransaction extends StatelessWidget {
const FetchTransaction({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
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
                  ("Fetch Bank Transactions"),
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
        color: AppColors.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 1.2,
              color: Colorcodes.barGraphOrange,
              child: Image.network(""),
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(24),
              //     border: Border.all(color: Colors.black)),
            ),
            // SizedBox.shrink(),
            InkWell(
                onTap: () {
                  //  Otpscreen
                  // loginToAutoTractions(context);
                   fetch(context);

                },
                child: getButton(context,"Fetch Trasactions")),
          ],
        ),
      ),
    );

  }  // fetch(context);
}