import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// // fetch(context);

// RxBool sessionId = false.obs;

// class FetchTransaction extends StatefulWidget {
//   const FetchTransaction({Key? key}) : super(key: key);

//   @override
//   State<FetchTransaction> createState() => _FetchTransactionState();
// }

// class _FetchTransactionState extends State<FetchTransaction> {
//   @override
//   void initState() {
//     super.initState();
//     getSess();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // bottomNavigationBar: BottomNavigations(data: sizeRoom?3:2),
//       extendBody: true,
//       bottomNavigationBar: BottomBar(),
      
//       //bottomSheet: bottomSheet(context),
//       appBar: AppBar(
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//           title: Container(
//             width: MediaQuery.of(context).size.width,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // const Spacer(),
//                 Center(
//                   child: Text(
//                     ("Fetch Bank Transactions"),
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 17,
//                         color: AppColors.bg1),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         color: AppColors.backgroundColor,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height / 3,
//               width: MediaQuery.of(context).size.width / 1.2,
//               // color: Colorcodes.barGraphOrange,
//               child: Image.network(bankImage),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             // fetchedTrsacntionList

//             Obx(() => fetchedTrsacntionList.isEmpty
//                 ? Text("Data is Not Yet Fetched")
//                 : Container(
//                     child: getTranSactions(context),
//                   )),

//             SizedBox(height: 20,),
          
//             InkWell(
//                 onTap: ()async {
//                   //  Otpscreen
//                   SharedPreferences prefs = await SharedPreferences.getInstance();
//                   // loginToAutoTractions(context);
//                  if(directFetch.value){
//                        String urlPath = "${url}/transactionauto/";
//                         var response=await getDataApiCall(urlPath);
//                          if (getFlagOfResponse(response)) {
//                             trasactionsData.clear();
//                             var his = jsonDecode(response.body);
//                             fetchedTrsacntionList.clear();
//                             fetchedTrsacntionList.addAll(his['data']);
//                             // changeTrasactiondata();
//                           } else {}

//                  }else {
                    
//                       if(prefs.containsKey("sessionId"))
//                       {
//                              //sessionId
//                         FetchTransactionBysessionId(context,prefs.getString("sessionId")!);

//                       }else{
//                         FetchTransactionFromFinvuApi(context);
//                       }

//                  }

               

//                 },
//              child: Obx(()=>   sessionId.value ?getButton(context,"Fetch Trasactions BY sessionId") :  getButton(context,"Fetch Trasactions")) 
//             ),

            
//           ],
//         ),
//       ),
//     );
//   }

//   // fetch(context);
//   Widget getTranSactions(context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 5,
//       child: SingleChildScrollView(
//         child: Expanded(
//           child: Column(
//             children: fetchedTrsacntionList.map((e) {
//               print(e);
//               return Container(
//                 child: Text(e.toString()),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   void getSess() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     sessionId.value = prefs.containsKey("sessionId");
//   }
// }




RxBool sessionId=false.obs;
RxBool flagToFetchData=false.obs;
class FetchTransaction extends StatefulWidget {
const FetchTransaction({ Key? key }) : super(key: key);

  @override
  State<FetchTransaction> createState() => _FetchTransactionState();
}

class _FetchTransactionState extends State<FetchTransaction> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    getSess();
    socket = IO.io(urlWithLocallHost,IO.OptionBuilder().setTransports(['websocket']).build());
     setUpSocketListener();
  }

  setUpSocketListener(){
     socket.onConnect((_) {
      print("${number.value}@finvu");
      socket.emit("registerUser", '${number.value}@finvu');
    });

     socket.on("registerUser",(data) => {
            print(data['data']['data']),
            flagToFetchData.value=false,
            fetchedTrsacntionList.clear(),
            fetchedTrsacntionList.addAll(data['data']['data']),
            clearStack(context),
            Navigator.pushNamed(context, "/home")
        });

    socket.onConnectError((data) {
       print("error-----------");
       print(data);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: BottomBar(),
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
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  // loginToAutoTractions(context);
                 if(directFetch.value){
                       String urlPath = "${url}/transactionauto/";
                        var response=await getDataApiCall(urlPath);
                       
                         if (getFlagOfResponse(response)) {
                            trasactionsData.clear();
                            var his = jsonDecode(response.body);
                            fetchedTrsacntionList.clear();
                            fetchedTrsacntionList.addAll(his['data']);
                            // changeTrasactiondata();
                          } else {}

                 }else {
                    
                      if(prefs.containsKey("sessionId"))
                      {
                             FetchTransactionBysessionId(context,prefs.getString("sessionId")!);
                      }else
                      {
                         flagToFetchData.value=true;
                         FetchTransactionFromFinvuApi(context);
                      }
                 }

                },
             child: Obx(()=>  flagToFetchData.value ?getspinner(context,"Fetch Trasactions BY sessionId") :  getButton(context,"Fetch Trasactions")) 
            ),
          ],
        ),
      ),
    );

  }  
  // fetch(context);
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
  
void getSess() async{
       SharedPreferences prefs = await SharedPreferences.getInstance();  
      sessionId.value = prefs.containsKey("sessionId");
  }  
}

// class FetchTransaction extends StatelessWidget {
// const FetchTransaction({ Key? key }) : super(key: key);

//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//         bottomSheet: BottomBar(),
//       // bottomNavigationBar: BottomNavigations(data: sizeRoom?3:2),
//       extendBody: true,
//       //bottomSheet: bottomSheet(context),
//       appBar: AppBar(
//           centerTitle: true,
//           backgroundColor: AppColors.backgroundColor,
//           automaticallyImplyLeading: false,
//           title: Container(
//             width: MediaQuery.of(context).size.width,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // const Spacer(),
//                 Center(
//                   child: Text(
//                     ("Fetch Bank Transactions"),
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 17,
//                         color: AppColors.bg1),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         color: AppColors.backgroundColor,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//              Container(
//               height: MediaQuery.of(context).size.height / 3,
//               width: MediaQuery.of(context).size.width / 1.2,
//               // color: Colorcodes.barGraphOrange,
//               child: Image.network(bankImage),
//             ),
//             SizedBox(height: 20,),
//             // fetchedTrsacntionList

//            Obx(()=> fetchedTrsacntionList.isEmpty?Text("Data is Not Yet Fetched"):Container(
//                 child: getTranSactions(context),
//            )),

//             SizedBox(height: 20,),
          
//             InkWell(
//                 onTap: ()async {
//                   //  Otpscreen
//                   // loginToAutoTractions(context);
//                  if(directFetch.value){
//                        String urlPath = "${url}/transactionauto/";
//                         var response=await getDataApiCall(urlPath);
//                          if (getFlagOfResponse(response)) {
//                             trasactionsData.clear();
//                             var his = jsonDecode(response.body);
//                             fetchedTrsacntionList.clear();
//                             fetchedTrsacntionList.addAll(his['data']);
//                             // changeTrasactiondata();
//                           } else {}

//                  }else  FetchTransactionFromFinvuApi(context);

//                 },
//              child: getButton(context,"Fetch Transactions")),
//           ],
//         ),
//       ),
//     );

//   }  



//  Widget getTranSactions(context){
//       return Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height/5,
//         child: SingleChildScrollView(
//           child: Expanded(
//             child: Column(
//                 children: fetchedTrsacntionList.map((e){
//                   // print(e);
//                     return Container(
//                          child: Text(e.toString()),
//                     );
//                 }).toList(),
//             ),
//           ),
//         ),
//       );
//   }

