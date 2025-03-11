import 'dart:convert';

import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
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
             "R6wXZnQsKKyg56qFKQNytvygyr/o4Mkq1VXL5LenBYI=",
             "bdrBhpj38ffhxpubzkINl0rG+UyossdhcBYj+Zx2fcc="
      ],
    ),
  );

  await finvuManager.connect();
   snackBarCalled(context,finvuManager.connect().toString());
  var isConnected = await finvuManager.isConnected();

  if (!isConnected) {
    isConnected = await finvuManager.isConnected();
  }
}

Future<void> loginWithServer(context) async {
  final String apiUrl =
      "${url}/finvu/login"; // Change to your actual server URL
  final String custId =
      "${number.value}@finvu"; // Replace with dynamic value if needed
  
   final SharedPreferences _pref = await SharedPreferences.getInstance();
   var accessToken = _pref.getString("accessToken");
  

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "$accessToken",
      },
      body: jsonEncode({"custId": custId,'number':number.value}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = "";//data["token"];
      // number.value="8459177562@finvu";
      String consentHandleId = data["consentHandleId"];

      // Store token and consentHandleId in SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("tokenFinvu", token);
      await prefs.setString("consentHandleId", consentHandleId);

    
   
      handleId.value = consentHandleId;
      snackBarCalled(context, consentHandleId);
      login(handleId.value,context);

      // Proceed with next steps, e.g., calling another API
      // ConsentStatus(context, token, consentHandleId, custId);
    } else {
    
    }
  } catch (error) {
   
  }
}
Future<void> FetchTransactionFromFinvuApi(BuildContext context) async {
 try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl ="${url}/finvu/fetchData"; // Change to your actual server URL
    final String custId ="${number.value}@finvu"; // Replace with dynamic value if needed
    
    String? handleId = prefs.getString("consentHandleId");

    if (handleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Missing required credentials!")),
      );
      return;
    }

   final SharedPreferences pref = await SharedPreferences.getInstance();
   String accessToken=pref.getString("accessToken").toString() ; 
  
     
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json", "Authorization": "$accessToken",},
      body: jsonEncode({
        "token": "",
        "handleId": handleId,
        "custId": custId,
      }),
    );
   
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
   
      sessionId.value=true;
      // Store values in SharedPreferences for later use
      prefs.setString("sessionId", data["sessionId"]);
      prefs.setString("from", data["from"]);
      prefs.setString("to", data["to"]);
      prefs.setString("custId", data["custId"]);
      prefs.setString("consentId", data["consentId"]);

      fetchedTrsacntionList.clear();
      fetchedTrsacntionList.add([data.toString()]);
      fetchedTrsacntionList.refresh();

      String accessToken="Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3N2UxMjBhNzVhYWZiYWMyNTQ2NGFkNCIsImlhdCI6MTczODc1Nzc3OSwiZXhwIjoxNzQzOTQxNzc5fQ.5XeQtIM2CmFdyrfXiCcA5neACgSRuYScFa5ArcYhe34";
      final SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("accessToken",accessToken);


      sessionId.value=false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data fetched successfully....!")),
      );
      
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
  
}

Future<void> FetchTransactionBysessionId(BuildContext context,String sessionId) async {
  try {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl ="${url}/finvu/session/${sessionId}"; 
   
    var response=await getDataApiCall(apiUrl);
   
   
    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
    
      await storeDataOfTransactions(context, data['data'], data['handleId'], data["from"],
          data["to"], "",  data["custId"],data['consentId'], data["sessionId"]);
   

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data fetched successfully!")),
      );

    } else {
     
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch data")),
      );
    }
  } catch (e) {
  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred")),
    );
  }
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