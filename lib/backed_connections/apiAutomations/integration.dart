import 'dart:convert';

import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
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

void initFinvuManager() async {
  finvuManager.initialize(
    FinvuConfig(
      finvuEndpoint: 'wss://webvwdev.finvu.in/consentapi',
      certificatePins: [],
    ),
  );

  await finvuManager.connect();
  var isConnected = await finvuManager.isConnected();

  print("websocket connected : ");
  print(isConnected);

  if (!isConnected) {
    isConnected = await finvuManager.isConnected();
    print(isConnected);
  }
}

Future<void> loginWithServer() async {
  final String apiUrl =
      "${url}/finvu/login"; // Change to your actual server URL
  final String custId =
      "${number.value}@finvu"; // Replace with dynamic value if needed
    print("apiUrl-------------------------------------");
    print(apiUrl);

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"custId": custId}),
    );
    printData(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = "";//data["token"];
      String consentHandleId = data["consentHandleId"];

      // Store token and consentHandleId in SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("tokenFinvu", token);
      await prefs.setString("consentHandleId", consentHandleId);

      print("Login successful!");
      print("Token: $token");
      print("Consent Handle ID: $consentHandleId");

      handleId.value = consentHandleId;
      login(handleId.value);

      // Proceed with next steps, e.g., calling another API
      // ConsentStatus(context, token, consentHandleId, custId);
    } else {
      print("Login failed: ${response.body}");
    }
  } catch (error) {
    print("Error logging in: $error");
  }
}

Future<void> FetchTransactionFromFinvuApi(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl ="${url}/finvu/fetchData"; // Change to your actual server URL
    final String custId ="${number.value}@finvu"; // Replace with dynamic value if needed
    
    String? handleId = prefs.getString("consentHandleId");
    // String? custId = prefs.getString("custId");

      print(apiUrl);
      print(custId);

    if (handleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Missing required credentials!")),
      );
      return;
    }
     
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "token": "",
        "handleId": handleId,
        "custId": custId,
        "userId":"675c0afbfcb1710765ab8e90"
      }),
    );
     printData(response);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Data Fetched: ${data}");
     sessionId.value=true;
      // Store values in SharedPreferences for later use
      prefs.setString("sessionId", data["sessionId"]);
      prefs.setString("from", data["from"]);
      prefs.setString("to", data["to"]);
      prefs.setString("custId", data["custId"]);
      prefs.setString("consentId", data["consentId"]);

      await storeDataOfTransactions(context, data, handleId, data["from"],
          data["to"], "", custId, data["custId"], data["sessionId"]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data fetched successfully....!")),
      );
    } else {
      print("Error fetching data: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch data. We will notify you once we retrieve it.")),
      );
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bank server issue detected. We'll notify you once your data is retrieved")),
    );
  }
    clearStack(context);
    clearStackLocalInfo();
    Navigator.pushNamed(context, "/");
}

Future<void> FetchTransactionBysessionId(BuildContext context,String sessionId) async {
  try {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl ="${url}/finvu/session/${sessionId}"; 
   
    var response=await getDataApiCall(apiUrl);
   
   
    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
      print("storeDataOfTransactions 1");
      await storeDataOfTransactions(context, data['data'], data['handleId'], data["from"],
          data["to"], "",  data["custId"],data['consentId'], data["sessionId"]);
      print("storeDataOfTransactions 2");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data fetched successfully!")),
      );

    } else {
      print("Error fetching data: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch data")),
      );
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred")),
    );
  }
}
