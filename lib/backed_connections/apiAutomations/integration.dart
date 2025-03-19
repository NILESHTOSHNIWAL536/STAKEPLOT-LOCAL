import 'dart:convert';

import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/ApproveConsentRequest.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchData.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void initFinvuManager(BuildContext context) async {
  finvuManager.initialize(
    FinvuConfig(
      // finvuEndpoint: 'wss://wsslive.finvu.in/consentapi',
      finvuEndpoint: 'wss://webvwdev.finvu.in/consentapi',
      certificatePins: 
      [
            //  "R6wXZnQsKKyg56qFKQNytvygyr/o4Mkq1VXL5LenBYI=",
            //  "bdrBhpj38ffhxpubzkINl0rG+UyossdhcBYj+Zx2fcc="
      ],
    ),
  );

  await finvuManager.connect();
  var isConnected = await finvuManager.isConnected();

  if (!isConnected) {
    isConnected = await finvuManager.isConnected();
  }
}

void getConsentHandleId(context) async 
{

  final String apiUrl ="${url}/finvu/login"; // Change to your actual server URL
  final String custId ="${number.value}@finvu"; // Replace with dynamic value if needed

   final SharedPreferences _pref = await SharedPreferences.getInstance();
   var accessToken = _pref.getString("accessToken");
   print("-----------------------------------------");
   print(apiUrl);
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "$accessToken",
      },
      body: jsonEncode({"custId": custId,'number':number.value}),
    );
   printData(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String consentHandleId = data["consentHandleId"];
      handleId.value=consentHandleId;
      print(handleId.value);
      login(consentHandleId,context);
    } 
  } catch (error) {
       print(error);
       snackBarCalled(context, error.toString());
  }
}
Future<void> FetchTransactionFromFinvuApi(BuildContext context) async {
 try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl ="${url}/finvu/fetchData"; // Change to your actual server URL
    final String custId ="${number.value}@finvu"; // Replace with dynamic value if needed
  
    if (handleId.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Missing required credentials!")),
      );
      return;
    }

   final SharedPreferences pref = await SharedPreferences.getInstance();
   String accessToken=pref.getString("accessToken").toString(); 

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json", "Authorization": "$accessToken",},
      body: jsonEncode({
        "token": "",
        "handleId": handleId.value,
        "custId": custId,
      }),
    );

    if (response.statusCode == 200) 
    {
      final data = json.decode(response.body);
    } else {
    
      sessionId.value=true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data is not ready to fetch yet. We will notify you once it's available.")),
      );
    }
  } catch (e) {
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bank server issue detected. We'll notify you once your data is retrieved")),
    );
  }

   clearStackShared(context);
   Navigator.pushNamed(context, "/OnboardingScreen"); 

}



 void getLinkedAccountInfo() async {
    fipDis = await finvuManager.fipsAllFIPOptions();
    List<FinvuLinkedAccountDetailsInfo> data =
        await finvuManager.fetchLinkedAccounts();
    listofLinkedAccount.clear();
    if (data.isNotEmpty) {
      data.forEach((finvu) {
        listofLinkedAccount.add(finvu.accountReferenceNumber.toString());
      });
    }
    fipDisOrginal.clear();
    fipDisOrginal.addAll(fipDis);
    getBanks.value = !getBanks.value;
  }