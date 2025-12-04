import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/integration.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../loginservices/login.dart';

RxBool sessionId = false.obs;
RxBool flagToFetchData = false.obs;

class FetchTransaction extends StatefulWidget {
  const FetchTransaction({Key? key}) : super(key: key);

  @override
  State<FetchTransaction> createState() => _FetchTransactionState();
}

class _FetchTransactionState extends State<FetchTransaction> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: BottomBar()),
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
                Center(
                  child: Text(
                    ( FinvuStrings().fetchAccountTransactions),
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
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 1.2,
              // color: Colorcodes.barGraphOrange,
              child: Image.network(bankImage),
            ),
            SizedBox(
              height: 20,
            ),
            // fetchedTrsacntionList

            //  Obx(()=> fetchedTrsacntionList.isEmpty?Text("Data is Not Yet Fetched"):Container(
            //       child: getTranSactions(context),
            //  )),

            SizedBox(
              height: 20,
            ),

            InkWell(
                onTap: () async {
                  FetchTransactionFromFinvuApi(context);
                },
                child: getButton(context, "Fetch Transactions")),
          ],
        ),
      ),
    );
  }

  // fetch(context);
  Widget getTranSactions(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 5,
      child: SingleChildScrollView(
        child: Expanded(
          child: Column(
            children: fetchedTrsacntionList.map((e)
            {
              
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
