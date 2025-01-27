import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';
  // fetch(context);

class FetchTransaction extends StatelessWidget {
const FetchTransaction({ Key? key }) : super(key: key);



  @override
  Widget build(BuildContext context){
    return Scaffold(
      // bottomNavigationBar: BottomNavigations(data: sizeRoom?3:2),
      extendBody: true,
      //bottomSheet: bottomSheet(context),
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const Spacer(),
                Center(
                  child: Text(
                    ("Fetch Bank Transactions"),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.bg1),
                  ),
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
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 1.2,
              // color: Colorcodes.barGraphOrange,
              child: Image.network(bankImage),
            ),
            SizedBox(height: 20,),
            // fetchedTrsacntionList

           Obx(()=> fetchedTrsacntionList.isEmpty?Text("Data is Not Yet Fetched"):Container(
                child: getTranSactions(context),
           )),

            SizedBox(height: 20,),
          
            InkWell(
                onTap: ()async {
                  //  Otpscreen
                  // loginToAutoTractions(context);
                 if(directFetch.value){
                       String urlPath = "${url}/transactionauto/";
                        var response=await getDataApiCall(urlPath);
                        printData(response);
                         if (getFlagOfResponse(response)) {
                            trasactionsData.clear();
                            var his = jsonDecode(response.body);
                            fetchedTrsacntionList.clear();
                            fetchedTrsacntionList.addAll(his['data']);
                            // changeTrasactiondata();
                          } else {}

                 }else fetch(context);

                },
             child: getButton(context,"Fetch Trasactions")),
          ],
        ),
      ),
    );

  }  // fetch(context);



 Widget getTranSactions(context){
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/5,
        child: SingleChildScrollView(
          child: Expanded(
            child: Column(
                children: fetchedTrsacntionList.map((e){
                  print(e);
                    return Container(
                         child: Text(e.toString()),
                    );
                }).toList(),
            ),
          ),
        ),
      );
  }
}